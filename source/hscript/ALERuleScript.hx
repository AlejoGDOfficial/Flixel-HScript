package hscript;

import rulescript.RuleScript;
import rulescript.interps.RuleScriptInterp;
import hscript.ALEParser;
import rulescript.parsers.HxParser;
import rulescript.Context;

import haxe.ds.StringMap;
import haxe.Exception;

using StringTools;

class ALERuleScript extends RuleScript
{
	public var failedParsing:Bool = false;

	override public function new(scriptName:String)
	{
		super(new ALEParser(scriptName));

		getParser(HxParser).allowAll();

		cast(interp, RuleScriptInterp).scriptName = scriptName.replace('.', '/') + '.hx';

		this.errorHandler = onError;
	}
	
	public function onError(error:Exception):Dynamic
	{
		Sys.println('[ERROR] ' + error);
		
		return error.details();
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
				Sys.println('[ERROR] ' + error.message);
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