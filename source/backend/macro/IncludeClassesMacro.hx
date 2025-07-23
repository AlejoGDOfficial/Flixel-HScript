package backend.macro;

#if macro
import sys.io.File;
import sys.FileSystem;
import haxe.macro.Context;

using StringTools;

class IncludeClassesMacro {
	macro public static function include():Void {
		for (cPath in Context.getClassPath()) {
			// you could create a define to change the path of this. -orbl
			final filePath:String = '${cPath}include.txt';

			// Find the include text path.
			if (FileSystem.exists(filePath)) {
				final includeFile:Array<String> = File.getContent(filePath).replace(' ', '').replace('\r', '').split('\n');

				// loop thru everything and include it.
				for (v in includeFile)
					if ((v = v.trim()) != "" && !v.startsWith("//"))
						haxe.macro.Compiler.include(v);
			}
		}
	}
}
#end
