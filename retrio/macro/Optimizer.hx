package retrio.macro;

import haxe.macro.Expr;
import haxe.macro.ExprTools;
import haxe.macro.Context;


class Optimizer
{
	static var _inlinedFunctions:Map<String, FieldType>;
	public static function findInlinedFunctions(fields:Array<Field>)
	{
		_inlinedFunctions = new Map();

		// find all inlined functions
		for (field in fields)
		{
			if (field.access.indexOf(AInline) > -1)
			{
				_inlinedFunctions[field.name] = field.kind;
			}
		}
	}

	public static function build()
	{
		var buildFields = haxe.macro.Context.getBuildFields();

		findInlinedFunctions(buildFields);

		return buildFields.map(transformField);
	}

	/**
	 * Propogate constant values forward to eliminate unnecessary branching.
	 * This function is run on expressions marked with @simplify or other
	 * manipulated expressions such as unrolled loops.
	 */
	public static function simplify(expr:Expr):Expr
	{
		switch(expr.expr)
		{
			case EIf(cond, yes, no):
				// pre-compute if branch if possible
				try
				{
					var value = ExprTools.getValue(cond);
					if (value)
					{
						return ExprTools.map(yes, simplify);
					}
					else
					{
						return ExprTools.map(no, simplify);
					}
				}
				catch(e:Dynamic)
				{
					return ExprTools.map(expr, simplify);
				}

			case ESwitch(cond, cases, def):
				// pre-compute switch branch if possible
				try
				{
					var value = ExprTools.getValue(cond);
					for (caseExpr in cases)
					{
						var values = caseExpr.values;
						for (value in values)
						{
							try
							{
								var caseValue = ExprTools.getValue(value);
								if (value == caseValue)
								{
									// this is the correct case
									return ExprTools.map(caseExpr.expr, simplify);
								}
							}
							catch (e:Dynamic)
							{
								// couldn't evaluate this value, so we can't eliminate this switch
								return ExprTools.map(expr, simplify);
							}
						}
					}
					return ExprTools.map(def, simplify);
				}
				catch(e:Dynamic)
				{
					return ExprTools.map(expr, simplify);
				}

			/*case ECall(f, params):
				// replace inlined function call with simplified function body
				switch(f.expr)
				{
					case EConst(CIdent(n)):
						if (_inlinedFunctions.exists(n))
						{
							var func:Function = switch(_inlinedFunctions[n])
							{
								case FFun(f):
									f;
								default:
									null;
							}
							var newExpr = func.expr;
							var values:Array<Expr> = [];
							for (p in params)
							{
								try
								{
									var value = ExprTools.getValue(p);
									values.push(${p});
								}
								catch (e:Dynamic)
								{
									values.push(null);
								}
							}
							for (i in 0 ... values.length)
							{
								if (values[i] != null)
								{
									newExpr = substituteVariable(newExpr, func.args[i].name, values[i]);
								}
							}
							return ExprTools.map(newExpr, simplify);
						}
						else
						{
							return expr;
						}

					default:
						return expr;
				}*/

			default:
				return ExprTools.map(expr, simplify);
		}
	}

	/**
	 * Substitute all occurrences of variable `varName` with constant `value`.
	 */
	public static function substituteVariable(expr:Expr, varName:String, value:Expr)
	{
		switch(expr.expr)
		{
			case EConst(CIdent(x)):
				if (x == varName)
				{
					return value;
				}
				else
					return expr;
			default:
				return ExprTools.map(expr, function(e) return substituteVariable(e, varName, value));
		}
	}

	static function transformField(field:Field)
	{
		switch (field.kind)
		{
			case FFun(f):
				transformExpr(f.expr);
			default:
		}
		return field;
	}

	static function transformExpr(expr:Expr)
	{
		switch (expr.expr)
		{
			case EMeta({name:"unroll"}, e):
				unroll(e);

			case EMeta({name:"simplify"}, e):
				expr.expr = ExprTools.map(e, simplify).expr;

			default:
				ExprTools.iter(expr, transformExpr);
		}
	}

	/**
	 * Unroll for loops of the form `for (i in constant ... constant)` that are
	 * marked with the @unroll metadata.
	 */
	static function unroll(expr:Expr)
	{
		switch(expr.expr)
		{
			case EFor({expr: EIn({expr: EConst(CIdent(id))},
					{expr:EBinop(OpInterval,
						{expr: EConst(CInt(loopStart))}, {expr: EConst(CInt(loopEnd))})})},
					inner):

				var block:Array<Expr> = [];

				for (i in Std.parseInt(loopStart) ... Std.parseInt(loopEnd))
				{
					var iteration = ExprTools.map(inner, function(e) return substituteVariable(e, id, {pos: expr.pos, expr: EConst(CInt(Std.string(i)))}));
					iteration = ExprTools.map(iteration, simplify);
					block.push(iteration);
				}

				expr.expr = EBlock(block);


			default:
				throw "only for loops can be unrolled";
		}
	}
}
