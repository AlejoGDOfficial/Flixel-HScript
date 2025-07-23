package;

import flixel.util.FlxColor;

import sys.thread.Thread;

enum abstract PrintType(String)
{
    var ERROR = 'error';
    var WARNING = 'warning';
    var TRACE = 'trace';
    var HSCRIPT = 'hscript';
    var LUA = 'lua';
    var MISSING_FILE = 'missing_file';
    var CUSTOM = 'custom';
    var POP_UP = 'pop-up';

    private static var dataMap:Map<PrintType, Array<Dynamic>> = [
        ERROR => ['ERROR', 0xFFFF5555],
        WARNING => ['WARNING', 0xFFFFA500],
        TRACE => ['TRACE', 0xFFFFFFFF],
        HSCRIPT => ['HSCRIPT', 0xFF88CC44],
        MISSING_FILE => ['MISSING FILE', 0xFFFF7F00],
        POP_UP => ['POP-UP', 0xFFFF00FF]
    ];

    public static function typeToString(type:PrintType):String
        return dataMap.get(type)[0];

    public static function typeToColor(type:PrintType):FlxColor
        return dataMap.get(type)[1];
}

class CoolUtil
{
	public static function debugTrace(text:Dynamic, ?type:PrintType = TRACE, ?customType:String = '', ?customColor:FlxColor = FlxColor.GRAY, ?pos:haxe.PosInfos)
	{
		text = haxe.Log.formatOutput(text, pos);

		var theText:String = ansiColorString(type == CUSTOM ? customType : PrintType.typeToString(type), type == CUSTOM ? customColor : PrintType.typeToColor(type)) + ansiColorString(' | ' + Date.now().toString().split(' ')[1] + ' | ', 0xFF505050) + (pos == null ? '' : ansiColorString(pos.fileName + ': ', 0xFF888888)) + text;

		Sys.println(theText);
	}

	public static function ansiColorString(text:String, color:FlxColor):String
		return '\x1b[38;2;' + color.red + ';' + color.green + ';' + color.blue + 'm' + text + '\x1b[0m';

	public static function createSafeThread(func:Void -> Void):Thread
	{
		return Thread.create(function()
		{
			try {
				func();
			} catch(e) {
				debugTrace(e.details(), ERROR);
			}
		});
	}
}