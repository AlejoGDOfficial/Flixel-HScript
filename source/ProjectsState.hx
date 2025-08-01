package;

#if cpp
import cpp.vm.Gc;
#elseif hl
import hl.Gc;
#end

import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;

import flixel.math.FlxMath;

import flixel.group.FlxGroup.FlxTypedGroup;

import flixel.text.FlxText;

import flixel.tweens.FlxTween;

import flixel.effects.FlxFlicker;

import flixel.util.FlxColor;
import flixel.util.FlxTimer;

import lime.app.Application;

import sys.FileSystem;

class ProjectsState extends FlxState
{
    var selInt:Int = 0;

    var camPos:Dynamic = {
        x: 0.0,
        y: 0.0
    };

    var folders:Array<String> = [];

    var texts:FlxTypedGroup<FlxText>;

    var canSelect:Bool = false;

    override function create()
    {
        super.create();

        FlxG.fullscreen = false;

        FlxG.initialWidth = 1280;
        FlxG.initialHeight = 720;

        FlxG.resizeGame(1280, 720);

        FlxG.resizeWindow(1280, 720);

        Application.current.window.x = Std.int((Application.current.window.display.bounds.width - Application.current.window.width) / 2);
        Application.current.window.y = Std.int((Application.current.window.display.bounds.height - Application.current.window.height) / 2);

        for (camera in FlxG.cameras.list)
        {
            camera.width = 1280;
            camera.height = 720;
        }

        var bg:FlxBackdrop = new FlxBackdrop(FlxGridOverlay.createGrid(80, 80, 160, 160, true, FlxColor.fromRGB(50, 0, 75), FlxColor.fromRGB(25, 0, 50)));
        add(bg);
        bg.scrollFactor.set();
        bg.alpha = 0.75;
        bg.velocity.x = bg.velocity.y = 100;

        texts = new FlxTypedGroup<FlxText>();
        add(texts);

        var upShit:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, 175, FlxColor.BLACK);
        add(upShit);
        upShit.alpha = 0.5;
        upShit.scrollFactor.set();

        var title:FlxText = new FlxText(0, 0, 0, 'Flixel HScripts | Projects', 70);
        add(title);
        title.scrollFactor.set();
        title.x = FlxG.width / 2 - title.width / 2;
        title.y = upShit.y + upShit.height / 2 - title.height / 2;

        if (FileSystem.exists('projects') && FileSystem.isDirectory('projects'))
            for (folder in FileSystem.readDirectory('projects'))
                if (FileSystem.isDirectory('projects/' + folder))
                {
                    texts.add(new FlxText(25 * folders.length, 100 * folders.length, 0, folder, 75));

                    folders.push(folder);
                }

        if (folders.length >= 1)
        {
            canSelect = true;

            changeShit();
        } else {
            var ad:FlxText = new FlxText(5, 0, FlxG.width - 10, '', 30);
            add(ad);
            ad.scrollFactor.set();
            ad.screenCenter();
            ad.alignment = CENTER;
            ad.applyMarkup('There are *no* projects installed\nPlease _place_ your projects in the “projects” folder and  the program again',
                [
                    new FlxTextFormatMarkerPair(new FlxTextFormat(FlxColor.RED), '*'),
                    new FlxTextFormatMarkerPair(new FlxTextFormat(FlxColor.CYAN), '_'),
                    new FlxTextFormatMarkerPair(new FlxTextFormat(FlxColor.MAGENTA), '|')
                ]
            );
        }
    }

    function changeShit()
    {
        for (index => text in texts)
        {
            text.alpha = index == selInt ? 1 : 0.5;

            if (index == selInt)
            {
                camPos.x = text.x - 200;
                camPos.y = text.y + text.height / 2 - FlxG.height / 2;
            }
        }
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        if (FlxG.keys.justPressed.R)
            FlxG.resetGame();

        if (canSelect)
        {
            if (FlxG.keys.justPressed.UP || FlxG.keys.justPressed.DOWN)
            {
                if (FlxG.keys.justPressed.UP)
                    if (selInt == 0)
                        selInt = texts.members.length - 1;
                    else
                        selInt--;

                if (FlxG.keys.justPressed.DOWN)
                    if (selInt >= texts.members.length - 1)
                        selInt = 0;
                    else
                        selInt++;

                changeShit();
            }

            if (FlxG.keys.justPressed.ENTER || FlxG.keys.justPressed.SPACE)
            {
                canSelect = false;

                for (index => text in texts)
                {
                    if (index == selInt)
                        FlxFlicker.flicker(text, 1);
                    else
                        FlxTween.tween(text, {alpha: 0}, 0.5);
                    
                    Paths.folder = folders[selInt];

                    FlxG.save.data.flixelhscriptsavedataselectedproject = Paths.folder;
                    FlxG.save.flush();

                    FlxTimer.wait(1, () -> { FlxG.resetGame(); });
                }
            }
        }

        FlxG.camera.scroll.x = fpsLerp(FlxG.camera.scroll.x, camPos.x, 0.15);
        FlxG.camera.scroll.y = fpsLerp(FlxG.camera.scroll.y, camPos.y, 0.15);
    }

    override function destroy()
    {
        Paths.clearEngineCache();

        #if cpp
        var killZombies:Bool = true;
        
        while (killZombies) {
            var zombie = Gc.getNextZombie();
        
            if (zombie == null) {
                killZombies = false;
            } else {
                var closeMethod = Reflect.field(zombie, "close");
        
                if (closeMethod != null && Reflect.isFunction(closeMethod))
                    closeMethod.call(zombie, []);
            }
        }
        
        Gc.run(true);
        Gc.compact();
        #end
        
        #if hl
        Gc.major();
        #end
        
        FlxG.bitmap.clearUnused();
        FlxG.bitmap.clearCache();
        
        super.destroy();
    }

    function fpsLerp(v1:Float, v2:Float, ratio:Float):Float
    {
        return FlxMath.lerp(v1, v2, FlxMath.bound(ratio * FlxG.elapsed * 60, 0, 1));
    }
}