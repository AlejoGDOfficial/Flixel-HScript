package backend;

import flixel.FlxG;

import haxe.ds.StringMap;

import sys.FileSystem;

class CustomState extends ScriptState
{
    public static var instance:CustomState;

    public var scriptName:String = '';

    private var arguments:Array<Dynamic>;
    
    private var hsVariables:StringMap<Dynamic>;

    @:unreflective private var reloadThread:Bool = Main.data.scriptsHotReloading && Main.data.developerMode;

    override public function new(script:String, ?arguments:Array<Dynamic>, ?hsVariables:StringMap<Dynamic>)
    {
        super();

        scriptName = script;

        this.arguments = arguments;

        this.hsVariables = hsVariables;
    }

    override public function create()
    {
        super.create();

        instance = this;

        if (Main.data.scriptsHotReloading && Main.data.developerMode)
        {
            for (file in [scriptName, 'global'])
            {
                Main.createSafeThread(() -> {
                        if (!Paths.fileExists('scripts/states/' + file + '.hx'))
                            return;

                        var lastTime = FileSystem.stat(Paths.getPath('scripts/states/' + file + '.hx')).mtime.getTime();

                        while (reloadThread)
                        {
                            if (!Paths.fileExists('scripts/states/' + file + '.hx'))
                            {
                                resetCustomState();

                                break;
                            }

                            var newTime = FileSystem.stat(Paths.getPath('scripts/states/' + file + '.hx')).mtime.getTime();

                            if (newTime != lastTime)
                            {
                                lastTime = newTime;

                                resetCustomState();
                            }
                            
                            Sys.sleep(0.1);
                        }
                });
            }
        }

        loadScripts();

        setOnScripts('arguments', arguments);

        if (hsVariables != null)
            for (key in hsVariables.keys())
                setOnHScripts(key, hsVariables.get(key));

        setOnScripts('resetCustomState', resetCustomState);
        
        callOnScripts('onCreate');

        callOnScripts('postCreate');
    }

    public function loadScripts()
    {
        loadScript(scriptName);
        loadScript('global');
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        callOnScripts('onUpdate', [elapsed]);

        callOnScripts('postUpdate', [elapsed]);
    }

    override public function destroy()
    {
        if (Main.data.scriptsHotReloading && Main.data.developerMode)
            reloadThread = false;

        super.destroy();

        callOnScripts('onDestroy');

        instance = null;

        callOnScripts('postDestroy');

        destroyScripts();
    }

    override public function onFocus()
    {
        super.onFocus();

        callOnScripts('onOnFocus');

        callOnScripts('postOnFocus');
    }

    override public function onFocusLost()
    {
        super.onFocusLost();

        callOnScripts('onOnFocusLost');

        callOnScripts('postOnFocusLost');
    }

    override public function openSubState(substate:flixel.FlxSubState):Void
    {
        super.openSubState(substate);

        callOnHScripts('onOpenSubState', [substate]);

        callOnHScripts('postOpenSubState', [substate]);
    }

    override public function closeSubState():Void
    {
        super.closeSubState();

        callOnScripts('onCloseSubState');

        callOnScripts('postCloseSubState');
    }

    public function resetCustomState()
    {
        shouldClearMemory = false;

        FlxG.switchState(() -> new CustomState(scriptName, arguments, hsVariables));
    }
}