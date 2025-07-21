package;

import flixel.FlxState;
import flixel.FlxG;

import lime.app.Application;

import hscript.Expr.ModuleDecl;
import hscript.Printer;

import rulescript.RuleScript;
import rulescript.Tools;
import rulescript.parsers.HxParser;
import rulescript.scriptedClass.RuleScriptedClassUtil;

import hscript.ALERuleScript;

import sys.io.File;

using StringTools;

#if (windows && cpp)
@:buildXml('
    <target id="haxe">
        <lib name="wininet.lib" if="windows" />
        <lib name="dwmapi.lib" if="windows" />
    </target>
')

@:cppFileCode('
    #include <Windows.h>
    #include <windowsx.h>
    #include <cstdio>
    #include <iostream>
    #include <tchar.h>
    #include <dwmapi.h>
    #include <winuser.h>
    #include <winternl.h>
    #include <Shlobj.h>
    #include <commctrl.h>
    #include <string>

    #define UNICODE

    #pragma comment(lib, "Shell32.lib")

    #pragma comment(lib, "Dwmapi")
    #pragma comment(lib, "ntdll.lib")
    #pragma comment(lib, "User32.lib")
    #pragma comment(lib, "gdi32.lib")
')
#end

class MainState extends FlxState
{
    override public function create()
    {
		FlxG.mouse.useSystemCursor = true;

		#if (windows && cpp)
		untyped __cpp__("SetProcessDPIAware();");

		FlxG.stage.window.borderless = true;
		FlxG.stage.window.borderless = false;

		Application.current.window.x = Std.int((Application.current.window.display.bounds.width - Application.current.window.width) / 2);
		Application.current.window.y = Std.int((Application.current.window.display.bounds.height - Application.current.window.height) / 2);

        setDarkMode(lime.app.Application.current.window.title, true);

        allocConsole();
		#end
        
		RuleScript.resolveScript = function (name:String):Dynamic
        {
            var path:String = 'scripts/classes/' + name.replace('.', '/') + '.hx';
    
            if (!Paths.fileExists(path))
                return null;
    
            var parser = new HxParser();
            parser.allowAll();
            parser.mode = MODULE;
    
            var module:Array<ModuleDecl> = parser.parseModule(File.getContent(Paths.getPath(path)));
    
            var newModule:Array<ModuleDecl> = [];
    
            var extend:String = null;
    
            for (decl in module)
            {
                switch (decl)
                {
                    case DPackage(_), DUsing(_), DImport(_):
                        newModule.push(decl);
                    case DClass(c):
                        if (name.split('.').pop() == c.name)
                        {
                            newModule.push(decl);
    
                            if (c.extend != null)
                                extend = new Printer().typeToString(c.extend);
                        }
                    default:
                }
            }
    
            var obj:Dynamic = null;
    
            if (extend == null)
            {
                var script = new ALERuleScript();
    
                script.execute(Tools.moduleDeclsToExpr(newModule));
    
                obj = {};
    
                for (key => value in script.variables)
                    Reflect.setField(obj, key, value);
            } else {
                var cl = Type.resolveClass(extend);
    
                var f = function(args:Array<Dynamic>)
                {
                    return Type.createInstance(cl, [name, args]);
                }
    
                obj = Reflect.makeVarArgs(f);
            }
    
            return obj;
        };

        RuleScriptedClassUtil.buildBridge = function (typeName:String, superInstance:Dynamic):RuleScript
        {
            var script = new ALERuleScript();

            script.getParser(HxParser).mode = MODULE;

            script.superInstance = superInstance;

            script.interp.skipNextRestore = true;

            script.execute(File.getContent(Paths.getPath('scripts/classes/' + typeName.replace('.', '/') + '.hx')));

            return script;
        };

        super.create();
        
        FlxG.switchState(() -> new backend.CustomState('Main'));
    }

    #if (windows && cpp)
    @:functionCode('
        HWND window = FindWindowA(NULL, title.c_str());
        if (window == NULL) 
            window = FindWindowExA(GetActiveWindow(), NULL, NULL, title.c_str());

        int value = enabled ? 1 : 0;

        if (window != NULL) {
            DwmSetWindowAttribute(window, 20, &value, sizeof(value));

            ShowWindow(window, 0);
            ShowWindow(window, 1);
            SetFocus(window);
        }
    ')
    @:unreflective function setDarkMode(title:String, enabled:Bool):Void {}
    
	@:functionCode('
        if (!AllocConsole())
            return;

        freopen("CONIN$", "r", stdin);
        freopen("CONOUT$", "w", stdout);
        freopen("CONOUT$", "w", stderr);

        HANDLE output = GetStdHandle(STD_OUTPUT_HANDLE);
        SetConsoleMode(output, ENABLE_PROCESSED_OUTPUT | ENABLE_VIRTUAL_TERMINAL_PROCESSING);
    ')
    public static function allocConsole() {}
    #end
}