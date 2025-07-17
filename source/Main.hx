package;

import flixel.FlxGame;
import flixel.FlxG;

import openfl.display.Sprite;
import openfl.events.UncaughtErrorEvent;

import haxe.CallStack;

import lime.app.Application;

import backend.CustomState;

#if cpp
import cpp.RawPointer;
#end

class Main extends Sprite
{
	public function new()
	{
		super();

		addChild(new FlxGame(0, 0, MainState, true));

		FlxG.signals.gameResized.add(
			function (width:Float, height:Float)
			{
				if (FlxG.cameras != null)
					for (cam in FlxG.cameras.list)
						if (cam != null && cam.filters != null)
							resetSpriteCache(cam.flashSprite);

				if (FlxG.game != null)
					resetSpriteCache(FlxG.game);
	   		}
	   );
	}
	
	private static function resetSpriteCache(sprite:Sprite):Void
	{
		@:privateAccess
		{
		    sprite.__cacheBitmap = null;
			sprite.__cacheBitmapData = null;
		}
	}
	
	function onCrash(e:UncaughtErrorEvent):Void
	{
		var errMsg:String = "";
		var callStack:Array<StackItem> = CallStack.exceptionStack(true);

		for (stackItem in callStack)
		{
			switch (stackItem)
			{
				case FilePos(s, file, line, column):
					errMsg += file + " (line " + line + ")\n";
				default:
					Sys.println(stackItem);
			}
		}

		errMsg += "\nUncaught Error: " + e.error;
	
		Application.current.window.alert(errMsg, 'Flixel HScript | Crash Handler');

		Sys.println('[ ERROR ] ' + errMsg);

		Sys.exit(1);
	}
}