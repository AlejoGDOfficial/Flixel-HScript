package;

import haxe.ds.StringMap;

import flixel.FlxG;
import flixel.sound.FlxSound;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;

import sys.io.File;
import sys.FileSystem;

import openfl.display.BitmapData;
import openfl.display3D.textures.RectangleTexture;

import openfl.media.Sound;

class Paths
{
    public static inline final IMAGE_EXT = 'png';
	public static inline final SOUND_EXT = #if web 'mp3' #else 'ogg' #end;

	public static var cachedGraphics:StringMap<FlxGraphic> = new StringMap<FlxGraphic>();
    public static var cachedSounds:StringMap<Sound> = new StringMap<Sound>();

    public static function image(file:String, missingPrint:Bool = true):FlxGraphic
    {
        var path = 'images/' + file + '.' + IMAGE_EXT;

        var bitmap:BitmapData = null;

        if (cachedGraphics.exists(path))
            return cachedGraphics.get(path);
        else if (fileExists(path))
            bitmap = BitmapData.fromFile(getPath(path));

        if (bitmap != null)
        {
            var returnValue = cacheBitmap(path, bitmap);

            if (returnValue != null)
                return returnValue;
        }

        if (missingPrint)
            Sys.println('[ MISSING FILE ] ' + path);

        return null;
    }
    
	public static function cacheBitmap(file:String, ?bitmap:BitmapData = null):FlxGraphic
	{
		if (bitmap == null)
		{
			if (FileSystem.exists(file))
				bitmap = BitmapData.fromFile(file);
            
			if (bitmap == null)
                return null;
		}

		var newGraphic:FlxGraphic = FlxGraphic.fromBitmapData(bitmap, false, file);
		newGraphic.persist = true;
		newGraphic.destroyOnNoUse = false;
        
		cachedGraphics.set(file, newGraphic);

		return newGraphic;
	}

    public static function inst(songRoute:String, missingPrint:Bool = true):Sound
        return returnSound(songRoute + '/song/Inst', missingPrint);

    public static function voices(songRoute:String, ?prefix:String = '', missingPrint:Bool = true):Sound
        return returnSound(songRoute + '/song/' + prefix + 'Voices', missingPrint);

    public static function music(file:String, missingPrint:Bool = true):Sound
        return returnSound('music/' + file, missingPrint);

    public static function sound(file:String, missingPrint:Bool = true):Sound
        return returnSound('sounds/' + file, missingPrint);

    private static function returnSound(file:String, missingPrint:Bool = true):Sound
    {
        var path = file + '.' + SOUND_EXT;

        var sound:Sound = null;

        if (cachedSounds.exists(path))
            return cachedSounds.get(path);
        else if (fileExists(path))
            sound = Sound.fromFile(getPath(path));

        if (sound != null)
        {
            var returnValue = cacheSound(path, sound);

            if (returnValue != null)
                return returnValue;
        }

        if (missingPrint)
            Sys.println('[ MISSING FILE ] ' + path);

        return null;
    }

    public static function cacheSound(file:String, ?sound:Sound = null):Sound
    {
        if (sound == null)
        {
            if (FileSystem.exists(file))
                sound = Sound.fromFile(file);

            if (sound == null)
                return null;
        }

        cachedSounds.set(file, sound);

        return sound;
    }

    public static function xml(file:String, missingPrint:Bool = true):String
    {
        var path = 'images/' + file + '.xml';

        if (!fileExists(path))
        {
            if (missingPrint)
                Sys.println('[ MISSING FILE ] ' + path);

            return null;
        }

        return File.getContent(getPath(path));
    }

    public static function imageTxt(file:String, missingPrint:Bool = true):String
    {
        var path = 'images/' + file + '.txt';

        if (!fileExists(path))
        {
            if (missingPrint)
                Sys.println('[ MISSING FILE ] ' + path);

            return null;
        }

        return File.getContent(getPath(path));
    }
    
    public static function imageJson(file:String, missingPrint:Bool = true):String
    {
        var path = 'images/' + file + '.json';

        if (!fileExists(file))
        {
            if (missingPrint)
                Sys.println('[ MISSING FILE ] ' + path);
            
            return null;
        }

        return File.getContent(getPath(path));
    }

    public static function getAtlas(file:String, missingPrint:Bool = true):FlxAtlasFrames
        return getSparrowAtlas(file, missingPrint) ?? getPackerAtlas(file, missingPrint) ?? getAsepriteAtlas(file, missingPrint) ?? null;

    public static function getSparrowAtlas(file:String, missingPrint:Bool = true):FlxAtlasFrames
    {
        var graphic = image(file, missingPrint);
        var xmlContent = xml(file, missingPrint);

        if (graphic == null || xmlContent == null)
            return null;

        return FlxAtlasFrames.fromSparrow(graphic, xmlContent);
    }
    
    public static function getPackerAtlas(file:String, missingPrint:Bool = true):FlxAtlasFrames
    {
        var graphic = image(file, missingPrint);
        var txtContent = imageTxt(file, missingPrint);

        if (graphic == null || txtContent == null)
            return null;

        return FlxAtlasFrames.fromSpriteSheetPacker(graphic, txtContent);
    }

    public static function getAsepriteAtlas(file:String, missingPrint:Bool = true):FlxAtlasFrames
    {
        var graphic = image(file, missingPrint);
        var jsonContent = imageJson(file, missingPrint);

        if (graphic == null || jsonContent == null)
            return null;

        return FlxAtlasFrames.fromTexturePackerJson(graphic, jsonContent);
    }

    public static function font(file:String, missingPrint:Bool = true):String
    {
        var path = 'fonts/' + file;

        if (!fileExists(path))
        {
            if (missingPrint)
                Sys.println('[ MISSING FILE ] ' + path);

            return null;
        }

        return getPath(path);
    }

    public static inline function getPath(file:String, missingPrint:Bool = true):String
    {
        if (fileExists(file))
            return 'assets/' + file;

        if (missingPrint)
            Sys.println('[ MISSING FILE ] ' + file);

        return null;
    }

    public static inline function fileExists(path:String):Bool
    {
        if (FileSystem.exists('assets/' + path))
            return true;
        
        return false;
    }

    public static function clearEngineCache()
    {
		@:privateAccess
		for (key in FlxG.bitmap._cache.keys())
		{
			var obj = FlxG.bitmap._cache.get(key);

			if (obj != null && !cachedGraphics.exists(key))
			{
				FlxG.bitmap._cache.remove(key);

				obj.destroy();
			}
		}

        for (key in cachedGraphics.keys())
            cachedGraphics.remove(key);

        for (key in cachedSounds.keys())
            cachedSounds.remove(key);
    }
}