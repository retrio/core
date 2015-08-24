package retrio.macro;

import haxe.macro.Expr;
import haxe.macro.ExprTools;
import haxe.macro.Context;


class ExceptionHandler
{
	public static function build()
	{
		var buildFields = Context.getBuildFields();

		return buildFields.map(transformField);
	}

	static function transformField(field:Field)
	{
#if !debug
		if (Reflect.hasField(field, 'meta'))
		{
			for (meta in field.meta)
			{
				if (meta.name == ":handler")
				{
					var handler = meta.params[0];
					switch (field.kind)
					{
						case FFun(f):
							f.expr = wrapExceptionHandler(f.expr, handler);

						default:
					}
				}
			}
		}
#end
		return field;
	}

	static function wrapExceptionHandler(e:Expr, handler:Expr):Expr
	{
		var pos = Context.currentPos();
		return {expr:ETry(e, [
			{name: "exception", type: TPath({pack:[], name:"Dynamic"}), expr: {expr:ECall(handler, [{expr:EConst(CIdent("exception")), pos:pos}]), pos:pos}}
		]), pos:pos};
	}
}
