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
		super();

		getParser(HxParser).allowAll();

		this.errorHandler = onError;
	}
	
	public function onError(error:Exception):Dynamic
	{
		debugTrace(error, ERROR);
		
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
				debugTrace(error.message, ERROR);
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