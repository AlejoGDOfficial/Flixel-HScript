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
import rulescript.scriptedClass.RuleScriptedClass.ScriptedClass;
import rulescript.interps.RuleScriptInterp;
import rulescript.types.ScriptedTypeUtil;
import rulescript.types.ScriptedAbstract;

import haxe.ds.StringMap;

import hscript.ALERuleScript;

import sys.FileSystem;
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
        
		ScriptedTypeUtil.resolveModule = function (name:String):Array<ModuleDecl>
        {
            var path:Array<String> = name.split('.');

            var pack:Array<String> = [];

            while (path[0].charAt(0) == path[0].charAt(0).toLowerCase())
                pack.push(path.shift());

            var moduleName:String = null;

            if (path.length > 1)
                moduleName = path.shift();

            var filePath = 'scripts/classes/' + (pack.length >= 1 ? pack.join('.') + '.' + (moduleName ?? path[0]) : path[0]).replace('.', '/') + '.hx';

            if (!Paths.fileExists(filePath))
                return null;

            var parser = new HxParser();
            parser.allowAll();
            parser.mode = MODULE;

            return parser.parseModule(File.getContent(Paths.getPath(filePath)));
        }

        RuleScriptedClassUtil.buildBridge = function (typePath:String, superInstance:Dynamic):RuleScript
        {
			var type:ScriptedClassType = ScriptedTypeUtil.resolveScript(typePath);

			var script = new hscript.ALERuleScript();

			script.superInstance = superInstance;

			cast(script.interp, RuleScriptInterp).skipNextRestore = true;

			if (type.isExpr)
			{
				script.execute(cast type);

				script;
			} else {
				var cl:ScriptedClass = cast type;

				RuleScriptedClassUtil.buildScriptedClass(cl, script);
			}

			return script;
        };

        ScriptedTypeUtil.resolveScript = function (name:String):Dynamic
        {
            final path:Array<String> = name.split('.');

            final pack:Array<String> = [];

            while (Tools.startsWithLowerCase(path[0]))
                pack.push(path.shift());

            var moduleName:String = null;

            if (path.length > 1)
                moduleName = path.shift();

            final module = ScriptedTypeUtil.resolveModule((pack.length >= 1 ? pack.join('.') + '.' + (moduleName ?? path[0]) : path[0]));

            if (module == null)
                return null;

            final typeName = path[0];

            final newModule:Array<ModuleDecl> = [];

            var typeDecl:Null<ModuleDecl> = null;

            for (decl in module)
            {
                switch (decl)
                {
                    case DPackage(_), DUsing(_), DImport(_):
                        newModule.push(decl);
                    case DClass(c) if (c.name == typeName):
                        typeDecl = decl;
                    case DAbstract(c) if (c.name == typeName):
                        typeDecl = decl;
                    default:
                }
            }

            newModule.push(typeDecl);

            return switch (typeDecl)
            {
                case DClass(classImpl):
                    final scriptedClass = new ScriptedClass({
                        name: moduleName ?? path[0],
                        path: pack.join('.'),
                        decl: newModule
                    }, classImpl?.name);

                    RuleScriptedClassUtil.registerRuleScriptedClass(scriptedClass.toString(), scriptedClass);

                    scriptedClass;
                case DAbstract(abstractImpl):
                    new ScriptedAbstract({
                        name: moduleName ?? path[0],
                        path: pack.join('.'),
                        decl: newModule
                    }, abstractImpl?.name);
                default: null;
            }
        };

        presetHScript();

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

    static function presetHScript()
    {
        final curPackage:Map<String, Dynamic> = RuleScript.defaultImports[''];

		var presetClasses:Array<Class<Dynamic>> = [
			flixel.FlxG,
			flixel.sound.FlxSound,
			flixel.FlxState,
			flixel.FlxSprite,
			flixel.FlxCamera,
			flixel.math.FlxMath,
			flixel.util.FlxTimer,
			flixel.text.FlxText,
			flixel.tweens.FlxEase,
			flixel.tweens.FlxTween,
			flixel.group.FlxSpriteGroup,
			flixel.group.FlxGroup.FlxTypedGroup,

			Array,
			String,
			Std,
			Math,
			Type,
			Reflect,
			Date,
			DateTools,
			Xml,
			EReg,
			Lambda,
			IntIterator,

			sys.io.Process,
			haxe.ds.StringMap,
			haxe.ds.IntMap,
			haxe.ds.EnumValueMap,
	
			sys.io.File,
			sys.FileSystem,
			Sys,

			backend.CustomState,
			backend.CustomSubState,
			Paths
		];

        for (theClass in presetClasses)
			curPackage.set(Type.getClassName(theClass).split('.').pop(), theClass);

		var presetVariables:StringMap<Dynamic> = [
			'Json' => hscript.ALEJson
		];

		for (preVar in presetVariables.keys())
			curPackage.set(preVar, presetVariables.get(preVar));
    }
}
