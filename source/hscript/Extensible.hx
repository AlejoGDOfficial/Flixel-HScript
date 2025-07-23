package hscript;

import rulescript.scriptedClass.RuleScriptedClass;

import flixel.*;
import flixel.ui.*;
import flixel.util.*;
import flixel.text.*;
import flixel.math.*;
import flixel.group.*;
import flixel.sound.*;
import flixel.graphics.*;
import flixel.addons.ui.*;
import flixel.addons.display.*;

class Extensible {}

class ScriptObject extends FlxObject implements RuleScriptedClass {}

class ScriptSprite extends FlxSprite implements RuleScriptedClass {}

class ScriptText extends FlxText implements RuleScriptedClass {}

class ScriptGroup extends FlxGroup implements RuleScriptedClass {}

class ScriptTimer extends FlxTimer implements RuleScriptedClass {}

class ScriptSound extends FlxSound implements RuleScriptedClass {}

class ScriptRect extends FlxRect implements RuleScriptedClass {}

class ScriptButton extends FlxButton implements RuleScriptedClass {}

class ScriptBar extends FlxBar implements RuleScriptedClass {}

class ScriptGraphic extends FlxGraphic implements RuleScriptedClass {}

class ScriptSubState extends FlxSubState implements RuleScriptedClass {}

class ScriptState extends FlxState implements RuleScriptedClass {}

class ScriptBasic extends FlxBasic implements RuleScriptedClass {}