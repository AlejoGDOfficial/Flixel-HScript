package hscript;

import haxe.ds.StringMap;
import haxe.Exception;

import flixel.FlxG;
import flixel.FlxObject;

import sys.FileSystem;
import sys.io.File;

enum abstract ScriptType(String)
{
	var STATE = 'state';
	var SUBSTATE = 'substate';
}

@:access(backend.ScriptState)
@:access(backend.ScriptSubState)
class HScript extends ALERuleScript
{
	public final type:ScriptType;

	override public function new(filePath:String, type:ScriptType)
	{
		this.type = type;

		super();

		scriptName = filePath.split('/').pop();

		if (FileSystem.exists(filePath))
			tryExecute(File.getContent(filePath), onError);
	}

	override public function preset():Void
	{
		super.preset();

		var instanceVariables:StringMap<Dynamic> = new StringMap<Dynamic>();
		
		if (type == STATE)
		{
			instanceVariables = [
				'game' => FlxG.state,
				'add' => FlxG.state.add,
				'insert' => FlxG.state.insert,
				'remove' => FlxG.state.remove,
				'openSubState' => FlxG.state.openSubState
			];
		} else if (type == SUBSTATE) {
			instanceVariables = [
				'game' => FlxG.state.subState,
				'add' => FlxG.state.subState.add,
				'insert' => FlxG.state.subState.insert,
				'remove' => FlxG.state.subState.remove,
				'close' => FlxG.state.subState.close
			];
		}

		for (insVar in instanceVariables.keys())
			set(insVar, instanceVariables.get(insVar));
	}
}