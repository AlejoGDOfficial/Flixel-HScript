@echo off
cd ..
@echo on
echo Installing dependencies

@if not exist ".haxelib\" mkdir .haxelib

haxelib install flixel 6.1.0
haxelib install flixel-ui 2.6.4
haxelib install lime 8.2.2
haxelib install openfl 9.4.1
haxelib install flixel-addons 3.3.2
haxelib git hxcpp https://github.com/AlejoGDOfficial/MobilePorting-hxcpp --skip-dependencies
haxelib git rulescript https://github.com/Kriptel/RuleScript 7bea5b4e8b137f112523f1fa41b6ac7e11f51df0 --skip-dependencies
haxelib git hscript https://github.com/HaxeFoundation/hscript 04e7d656b667f375bbe58ee10082aee2850a3f9c
haxelib install tjson 1.4.0
haxelib install extension-androidtools 2.2.1 --skip-dependencies