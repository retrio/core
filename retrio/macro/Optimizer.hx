package retrio.macro;

import haxe.macro.Expr;
import haxe.macro.ExprTools;
import haxe.macro.Context;


class Optimizer
{
	public static function build()
	{
		return haxe.macro.Context.getBuildFields().map(transformField);
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
				try
				{
					var value = ExprTools.getValue(cond);
					if (value)
					{
						return ExprTools.map(yes, simplify);
					}
					else
					{
						return {expr: EBlock([]), pos: expr.pos};
					}
				}
				catch(e:Dynamic)
				{
					return ExprTools.map(expr, simplify);
				}

			// TODO: case ESwitch()

			default:
				return ExprTools.map(expr, simplify);
		}
	}

	/**
	 * Substitute all occurrences of variable `varName` with constant `value`.
	 */
	public static function substituteVariable(expr:Expr, varName:String, value:Constant)
	{
		switch(expr.expr)
		{
			case EConst(CIdent(x)):
				if (x == varName)
					return {expr: EConst(value), pos:expr.pos};
				else
					return ExprTools.map(expr, function(e) return substituteVariable(expr, varName, value));
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
					var iteration = ExprTools.map(inner, function(e) return substituteVariable(e, id, CInt(Std.string(i))));
					iteration = ExprTools.map(iteration, simplify);
					block.push(iteration);
				}

				expr.expr = EBlock(block);


			default:
				ExprTools.iter(expr, transformExpr);
		}
	}
}
