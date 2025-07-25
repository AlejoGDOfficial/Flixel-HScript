package backend;

import haxe.ds.StringMap;

class CustomSubState extends ScriptSubState
{
    public static var instance:CustomSubState;

    public var scriptName:String = '';

    public var arguments:Array<Dynamic>;
    
    public var hsVariables:StringMap<Dynamic>;

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

        loadScripts();

        setOnScripts('arguments', arguments);

        if (hsVariables != null)
            for (key in hsVariables.keys())
                setOnHScripts(key, hsVariables.get(key));

        openCallback = function() { callOnScripts('onOpen'); };
        closeCallback = function() { callOnScripts('onClose'); };

        callOnScripts('onCreate');

        callOnScripts('postCreate');
    }

    private function loadScripts()
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
}