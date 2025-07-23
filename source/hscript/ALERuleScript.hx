package hscript;

import rulescript.RuleScript;
import rulescript.parsers.HxParser;
import rulescript.Context;

import haxe.ds.StringMap;
import haxe.Exception;

class ALERuleScript extends RuleScript
{
	public var failedParsing:Bool = false;

	override public function new()
	{
		super(new Context());

		preset();

		getParser(HxParser).allowAll();

		this.errorHandler = onError;
	}
	
	public function onError(error:Exception):Dynamic
	{
		Sys.println('[ ERROR ] ' + error);
		
		return error.details();
	}

	public function preset():Void
	{
		var presetClasses:Array<Class<Dynamic>> = [
			flixel.FlxG,
			flixel.sound.FlxSound,
			flixel.FlxState,
			flixel.FlxSprite,
			flixel.FlxCamera,
			flixel.math.FlxMath,
			flixel.util.FlxTimer,
			flixel.text.FlxText,
			flixel.tweens.FlxEase,
			flixel.tweens.FlxTween,
			flixel.group.FlxSpriteGroup,
			flixel.group.FlxGroup.FlxTypedGroup,

			Array,
			String,
			Std,
			Math,
			Type,
			Reflect,
			Date,
			DateTools,
			Xml,
			EReg,
			Lambda,
			IntIterator,

			sys.io.Process,
			haxe.ds.StringMap,
			haxe.ds.IntMap,
			haxe.ds.EnumValueMap,
	
			sys.io.File,
			sys.FileSystem,
			Sys,

			backend.CustomState,
			backend.CustomSubState,
			Paths
		];

        for (theClass in presetClasses)
			context.types.set(Type.getClassName(theClass).split('.').pop(), theClass);

		var presetVariables:StringMap<Dynamic> = [
			'FlxColor' => HScriptFlxColor,
			'FlxKey' => HScriptFlxKey,
			'Json' => hscript.ALEJson
		];

		for (preVar in presetVariables.keys())
			context.types.set(preVar, presetVariables.get(preVar));
	}

	public function call(func:String, ?args:Array<Dynamic>)
	{
		var func = variables.get(func);

		if (func != null && Reflect.isFunction(func))
		{
			try
			{
				Reflect.callMethod(null, func, args ?? []);
			} catch(error:Exception) {
				Sys.println('[ ERROR ] ' + error.message);
			}
		}
	}

	public function set(name:String, value:Dynamic)
		variables.set(name, value);
	
	public function setClass(cls:Class<Dynamic>)
	{
		set(Type.getClassName(cls).split('.').pop(), cls);
	}
}