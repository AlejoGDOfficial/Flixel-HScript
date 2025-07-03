package hscript;

import rulescript.RuleScript;
import rulescript.parsers.HxParser;

import haxe.ds.StringMap;
import haxe.Exception;

import hscript.HScriptImports;

class ALERuleScript extends RuleScript
{
	public var failedParsing:Bool = false;

	override public function new()
	{
		super();

		getParser(HxParser).allowAll();

		this.errorHandler = onError;

		preset();
	}

	public function onError(error:Exception):Dynamic
	{
		failedParsing = true;
		
		return error.details();
	}

	private function preset():Void
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
			Paths,
			haxe.Json
		];

        for (theClass in presetClasses)
            setClass(theClass);

		var presetVariables:StringMap<Dynamic> = [
			'FlxColor' => HScriptFlxColor,
			'FlxKey' => HScriptFlxKey
		];

		for (preVar in presetVariables.keys())
			set(preVar, presetVariables.get(preVar));
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