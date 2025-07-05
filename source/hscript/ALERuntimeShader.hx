package hscript;

import flixel.addons.display.FlxRuntimeShader;

import lime.graphics.opengl.GLProgram;
import lime.app.Application;

class ALERuntimeShader extends FlxRuntimeShader
{
    public var shaderName:String = '';

    public function new (?shaderName:String, ?fragmentSource:String, ?vertexSource:String)
    {
        this.shaderName = shaderName;
        
        super(fragmentSource, vertexSource);
    }

	override function __createGLProgram(vertexSource:String, fragmentSource:String):GLProgram
	{
		try
		{
			final res = super.__createGLProgram(vertexSource, fragmentSource);

			return res;
		} catch (error) {
			Sys.print('[ ERROR ] Error when Starting Shader "' + shaderName + '":\n' + error);

			return null;
		}
	}
}