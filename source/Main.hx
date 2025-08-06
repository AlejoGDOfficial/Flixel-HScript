package;

import flixel.FlxGame;
import flixel.FlxG;
import flixel.input.keyboard.FlxKey;

import openfl.display.Sprite;
import openfl.events.UncaughtErrorEvent;
import openfl.events.KeyboardEvent;

import haxe.CallStack;

import lime.app.Application;

import backend.CustomState;

import openfl.Lib;

import haxe.io.Path;

import sys.thread.Thread;

#if android
import extension.androidtools.content.Context;

import sys.FileSystem;
#end

typedef DataJson = {
	var developerMode:Bool;
	var scriptsHotReloading:Bool;
}

class Main extends Sprite
{
	public static var data:DataJson = {
		developerMode: false,
		scriptsHotReloading: false
	};

	@:allow(backend.CustomState)
	private static function createSafeThread(func:Void -> Void):Thread
	{
		return Thread.create(function()
		{
			try {
				func();
			} catch(e) {
				trace('[ERROR] ' + e.details());
			}
		});
	}

	public function new()
	{
		super();

	    #if android
		var dir:String = Context.getExternalFilesDir();

		if (!FileSystem.exists(dir))
			FileSystem.createDirectory(dir);

		Sys.setCwd(Path.addTrailingSlash(dir));
		#end

		addChild(new FlxGame(0, 0, MainState, true));

		Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onCrash);

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
	   
		FlxG.game.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyPressed);
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
					Sys.println('[ERROR] ' + stackItem);
			}
		}

		errMsg += "\nUncaught Error: " + e.error;
	
		Application.current.window.alert(errMsg, 'Flixel HScript | Crash Handler');

		Sys.println('[ERROR] ' + errMsg);

		Sys.exit(1);
	}
    
    function onKeyPressed(event:KeyboardEvent)
    {
        if (FlxG.keys.pressed.CONTROL && FlxG.keys.pressed.SHIFT)
        {
			if (event.keyCode == FlxKey.M)
			{
				if (FlxG.state.subState != null)
					FlxG.state.subState.close();

				FlxG.switchState(() -> new ProjectsState());
			}
        }
    }
}