package hscript;

import tjson.TJSON as Json;

import haxe.format.JsonPrinter;

class ALEJson
{
    public static function parse(raw:String)
        return Json.parse(raw);

    public static function stringify(object:Dynamic, ?separator:String = '\t')
        return JsonPrinter.print(object, null, separator);
}