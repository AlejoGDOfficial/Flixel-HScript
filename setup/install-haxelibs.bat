@echo off
cd ..
@echo on
echo Installing dependencies

@if not exist ".haxelib\" mkdir .haxelib

haxelib install flixel 6.1.0
haxelib install lime 8.2.2
haxelib install openfl 9.4.1
haxelib install flixel-addons 3.3.2
haxelib git hxcpp https://github.com/AlejoGDOfficial/MobilePorting-hxcpp --skip-dependencies
haxelib install rulescript 0.2.0
haxelib install tjson 1.4.0