package backend;

#if cpp
import cpp.vm.Gc;
#elseif hl
import hl.Gc;
#end

import flixel.FlxG;
import flixel.FlxState;
import flixel.FlxCamera;
import flixel.util.FlxColor;

import hscript.HScript;

import haxe.Exception;

using StringTools;

class ScriptState extends FlxState
{
    public static var instance:ScriptState;

    public var hScripts:Array<HScript> = [];

    override public function create()
    {
        super.create();
        
        instance = this;
    }

    public var shouldClearMemory:Bool = true;

    override public function destroy()
    {
        instance = null;

        if (shouldClearMemory)
            cleanMemory();
        
        super.destroy();
    }

    private function cleanMemory()
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
    }

    public function loadScript(path:String)
    {
        if (path.endsWith('.hx'))
        {
            loadHScript(path.substring(0, path.length - 3));

            return;
        }

        loadHScript(path);
    }

    public function loadHScript(path:String)
    {
        var newPath:String = 'scripts/states/' + path;

        if (Paths.fileExists(newPath + '.hx'))
        {
            var script:HScript = new HScript(Paths.getPath(newPath + '.hx'), STATE, path);

            if (!script.failedParsing)
            {
                hScripts.push(script);

                Sys.println('[HSCRIPT] "' + newPath + '.hx" has been Successfully Loaded');
            }
        }
    }

    public function setOnScripts(name:String, value:Dynamic)
    {
        setOnHScripts(name, value);
    }

    public function setOnHScripts(name:String, value:Dynamic)
    {
        if (hScripts.length > 0)
            for (script in hScripts)
                script.set(name, value);
    }

    public function callOnScripts(callback:String, ?arguments:Array<Dynamic> = null)
    {
        callOnHScripts(callback, arguments);
    }

    public function callOnHScripts(callback:String, arguments:Array<Dynamic> = null)
    {
        if (hScripts.length > 0)
        {
            try
            {
                for (script in hScripts)
                {
                    if (script == null)
                        continue;

                    script.call(callback, arguments);
                }
            } catch(_) {}
        }
    }

    public function destroyScripts()
    {
        destroyHScripts();
    }

    public function destroyHScripts()
    {
        if (hScripts.length > 0)
        {
            for (script in hScripts)
                hScripts.remove(script);
        }
    }
}