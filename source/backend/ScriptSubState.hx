package backend;

import flixel.FlxSubState;

import hscript.HScript;

import haxe.Exception;

using StringTools;

class ScriptSubState extends FlxSubState
{
    public static var instance:ScriptSubState;

    public var hScripts:Array<HScript> = [];

    override public function create()
    {
        super.create();

        instance = this;
    }

    override public function destroy()
    {
        instance = null;

        super.destroy();
    }

    public inline function loadScript(path:String)
    {
        if (path.endsWith('.hx'))
        {
            loadHScript(path.substring(0, path.length - 3));

            return;
        }

        loadHScript(path);
    }

    public inline function loadHScript(path:String)
    {
        if (Paths.fileExists(path + '.hx'))
        {
            var script:HScript = new HScript(Paths.getPath(path + '.hx'), SUBSTATE);

            if (!script.failedParsing)
            {
                hScripts.push(script);

                Sys.println('"' + path + '.hx" has been Successfully Loaded');
            }
        }
    }

    public inline function setOnScripts(name:String, value:Dynamic)
    {
        setOnHScripts(name, value);
    }

    public inline function setOnHScripts(name:String, value:Dynamic)
    {
        if (hScripts.length > 0)
            for (script in hScripts)
                script.set(name, value);
    }

    public inline function callOnScripts(callback:String, ?arguments:Array<Dynamic> = null)
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

    public inline function destroyScripts()
    {
        destroyHScripts();
    }

    public inline function destroyHScripts()
    {
        if (hScripts.length > 0)
        {
            for (script in hScripts)
                hScripts.remove(script);
        }
    }
}