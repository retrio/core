package retrio.macro;

import haxe.macro.Expr;
import haxe.macro.ExprTools;
import haxe.macro.Context;
import haxe.macro.Type;


class SaveStateMacro
{
	/**
	 * Builds the saveState and loadState functions for an IState object by
	 * finding all params marked with @:state metadata.
	 */
	public static function build()
	{
		var buildFields = haxe.macro.Context.getBuildFields();

		var cls:ClassType = Context.getLocalClass().get();
		var overrides:Bool = false;
		while (cls.superClass != null)
		{
			cls = cls.superClass.t.get();
			for (i in cls.interfaces)
			{
				if (i.t.get().name == 'IState')
				{
					// parent class is an IState, so methods need to override
					overrides = true;
					break;
				}
			}
		}

		var saveStateFields = makeSaveState(buildFields, overrides);
		var loadStateFields = makeLoadState(buildFields, overrides);

		return buildFields.concat(saveStateFields).concat(loadStateFields);
	}

	static function makeSaveState(fields:Array<Field>, ?overrides:Bool=false):Array<Field>
	{
		var saveStateExprs:Array<Expr> = [];
		var pos = Context.currentPos();

		// initialize byte buffer
		saveStateExprs.push(Context.parse("var state:haxe.io.BytesOutput = new haxe.io.BytesOutput()", pos));
		if (overrides)
		{
			saveStateExprs.push(Context.parse("state.write(super.saveState())", pos));
		}

		// find all state fields and child objects
		var children:Array<String> = [];
		var stateVersion:Int = 0;
		for (field in fields)
		{
			if (Reflect.hasField(field, 'meta'))
			{
				for (meta in field.meta)
				{
					if (meta.name == ':state')
					{
						// this variable or property should be part of the state
						switch (field.kind)
						{
							case FVar(t, e):
#if debug
								saveStateExprs.push(Context.parse("trace('" + field.name + "', " + field.name + ")", pos));
#end
								saveStateExprs.push(Context.parse(serializeValue("state", field.name, t), pos));

							case FProp(get, set, t, e):
#if debug
								saveStateExprs.push(Context.parse("trace('" + field.name + "', " + field.name + ")", pos));
#end
								saveStateExprs.push(Context.parse(serializeValue("state", field.name, t), pos));

							default:
								throw "Can't use @:state on field of kind " + field.kind;
						}
					}
					else if (meta.name == ':stateChildren')
					{
						switch (field.kind)
						{
							case FVar(t, e):
								try
								{
									var val:Array<String> = cast ExprTools.getValue(e);
									for (child in val)
										children.push(child);
								}
								catch (e:Dynamic)
								{
									throw "Couldn't evaluate @:stateChildren at compile time";
								}
							default:
								throw "@:stateChildren should be used on a constant variable expression";
						}
					}
					else if (meta.name == ':stateVersion')
					{
						switch (field.kind)
						{
							case FVar(t, e):
								try
								{
									stateVersion = cast ExprTools.getValue(e);
									saveStateExprs.push(Context.parse('state.writeInt32($stateVersion)', pos));
								}
								catch (e:Dynamic)
								{
									throw "Couldn't evaluate @:stateVersion at compile time";
								}
							default:
								throw "@:stateVersion should be used on a constant variable expression";
						}
					}
				}
			}
		}

		for (child in children)
		{
			saveStateExprs.push(Context.parse('if (Std.is(this.$child, IState)) state.write(cast(this.$child, IState).saveState())', pos));
		}

		// return the serialized byte buffer
		saveStateExprs.push(Context.parse("return state.getBytes()", pos));

#if debug
		trace("SAVE", ExprTools.toString({expr: EBlock(saveStateExprs), pos:pos}));
#end

		var saveStateFunction:Function = {
			args: [],
			expr: {expr: EBlock(saveStateExprs), pos:pos},
			ret: TPath({pack: ["retrio"], name: "SaveState"}),
		};
		var access = [APublic];
		if (overrides) access.push(AOverride);
		return [{
			name: "saveState",
			access: access,
			kind: FFun(saveStateFunction),
			pos: pos,
		}];
	}

	static function makeLoadState(fields:Array<Field>, ?overrides:Bool=false):Array<Field>
	{
		var loadStateExprs:Array<Expr> = [];
		var pos = Context.currentPos();

		if (overrides)
		{
			loadStateExprs.push(Context.parse("super.loadState(input)", pos));
		}

		// find all state fields and child objects
		var children:Array<String> = [];
		var stateVersion:Int = 0;
		for (field in fields)
		{
			if (Reflect.hasField(field, 'meta'))
			{
				for (meta in field.meta)
				{
					if (meta.name == ':state')
					{
						// this variable or property should be part of the state
						switch (field.kind)
						{
							case FVar(t, e):
								loadStateExprs.push(Context.parse(unserializeValue("input", field.name, t), pos));
#if debug
								loadStateExprs.push(Context.parse("trace('" + field.name + "', " + field.name + ")", pos));
#end

							case FProp(get, set, t, e):
								loadStateExprs.push(Context.parse(unserializeValue("input", field.name, t), pos));
#if debug
								loadStateExprs.push(Context.parse("trace('" + field.name + "', " + field.name + ")", pos));
#end

							default:
								throw "Can't use @:state on field of kind " + field.kind;
						}
					}
					else if (meta.name == ':stateChildren')
					{
						switch (field.kind)
						{
							case FVar(t, e):
								try
								{
									var val:Array<String> = cast ExprTools.getValue(e);
									for (child in val)
										children.push(child);
								}
								catch (e:Dynamic)
								{
									throw "Couldn't evaluate @:stateChildren at compile time";
								}
							default:
								throw "@:stateChildren should be used on a constant variable expression";
						}
					}
					else if (meta.name == ':stateVersion')
					{
						switch (field.kind)
						{
							case FVar(t, e):
								try
								{
									stateVersion = cast ExprTools.getValue(e);
									loadStateExprs.push(Context.parse('var version = input.readInt32()', pos));
								}
								catch (e:Dynamic)
								{
									throw "Couldn't evaluate @:stateVersion at compile time";
								}
							default:
								throw "@:stateVersion should be used on a constant variable expression";
						}
					}
				}
			}
		}

		for (child in children)
		{
			loadStateExprs.push(Context.parse('if (Std.is(this.$child, IState)) cast(this.$child, IState).loadState(input)', pos));
		}

#if debug
		trace("LOAD", ExprTools.toString({expr: EBlock(loadStateExprs), pos:pos}));
#end

		var loadStateFunction:Function = {
			args: [{name: "input", type: TPath({pack: ["haxe", "io"], name: "BytesInput"})}],
			expr: {expr: EBlock(loadStateExprs), pos:pos},
			ret: null,
		};
		var access = [APublic];
		if (overrides) access.push(AOverride);
		return [{
			name: "loadState",
			access: access,
			kind: FFun(loadStateFunction),
			pos: pos,
		}];
	}

	static function serializeValue(bufferName:String, fieldName:String, type:Null<ComplexType>, ?recursions:Int=1):String
	{
		return switch(type)
		{
			case TPath({name:"Byte"}):
				'$bufferName.writeByte(this.$fieldName)';

			case TPath({name:"Short"}):
				'$bufferName.writeInt16(this.$fieldName)';

			case TPath({name:"Int"}):
				'$bufferName.writeInt32(this.$fieldName)';

			case TPath({name:"Float"}):
				'$bufferName.writeFloat(this.$fieldName)';

			case TPath({name:"String"}):
				'{$bufferName.writeInt32(this.$fieldName.length); $bufferName.writeString(this.$fieldName);}';

			case TPath({name:"Bool"}):
				'$bufferName.writeByte(this.$fieldName ? 1 : 0)';

			case TPath({name:"ByteString"}):
				'{$bufferName.writeInt32(this.$fieldName.length); for (i${recursions} in 0 ... this.$fieldName.length) $bufferName.writeByte(this.$fieldName.get(i${recursions}));}';

			case TPath({name:"Date"}):
				'$bufferName.writeFloat(this.$fieldName.getTime())';

			case TPath({name:"Bytes"}):
				'{$bufferName.writeInt32(this.$fieldName.length); $bufferName.write(this.$fieldName);}';

			case TPath({name:"Vector", params:[TPType(TPath({name: subtype}))]}):
				'{$bufferName.writeInt32(this.$fieldName.length); for (i${recursions} in 0 ... this.$fieldName.length) ' + serializeValue(bufferName, fieldName + '.get(i${recursions})', TPath({pack: [], name: subtype}), recursions + 1) + ';}';

			default:
				// fall back to JSON
				'{var json:String = haxe.Json.stringify(this.$fieldName); $bufferName.writeInt32(json.length); $bufferName.writeString(json);}';
		}
	}

	static function unserializeValue(bufferName:String, fieldName:String, type:Null<ComplexType>, ?recursions:Int=1):String
	{
		return switch(type)
		{
			case TPath({name:"Byte"}):
				'this.$fieldName = $bufferName.readByte()';

			case TPath({name:"Short"}):
				'this.$fieldName = $bufferName.readInt16()';

			case TPath({name:"Int"}):
				'this.$fieldName = $bufferName.readInt32()';

			case TPath({name:"Float"}):
				'this.$fieldName = $bufferName.readFloat()';

			case TPath({name:"String"}):
				'{var length:Int = $bufferName.readInt32(); this.$fieldName = $bufferName.readString(length);}';

			case TPath({name:"Bool"}):
				'this.$fieldName = $bufferName.readByte() > 0';

			case TPath({name:"ByteString"}):
				'{var length:Int = $bufferName.readInt32(); this.$fieldName = new retrio.ByteString(length); for (i$recursions in 0 ... length) this.$fieldName.set(i$recursions, $bufferName.readByte());}';

			case TPath({name:"Date"}):
				'this.$fieldName = Date.fromTime($bufferName.readFloat())';

			case TPath({name:"Bytes"}):
				'{var length:Int = $bufferName.readInt32(); this.$fieldName = $bufferName.read(length);}';

			case TPath({name:"Vector", params:[TPType(TPath({name: subtype}))]}):
				'{var length:Int = $bufferName.readInt32(); for (i$recursions in 0 ... length) ' + unserializeValue(bufferName, fieldName + '[i$recursions]', TPath({pack: [], name: subtype}), recursions + 1) + ';}';

			default:
				// fall back to JSON
				'{var length:Int = $bufferName.readInt32(); this.$fieldName = haxe.Json.parse($bufferName.readString(length));}';
		}
	}
}
