package gameObjects.ui;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxPoint;
import lime.utils.Assets;

using StringTools;

/*
* Credit where is due.
* This class is based on Doido Engine's Alphabet class: https://github.com/DoidoTeam/FNF-Doido-Engine/blob/main/source/objects/menu/Alphabet.hx
*/

enum PizzabetAlign
{
	LEFT;
	CENTER;
	RIGHT;
}

class Pizzabeth extends FlxSpriteGroup
{
	public var align:PizzabetAlign = LEFT;
	public var text(default, set):String = "";
	public var textArray:Array<String> = [];

	public var letters:String = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";
	public var graves:String = "ÀÈÌÒÙàèìòù";
	public var numbers:String = "0123456789";
	public var symbols:String = ".:!?'\"-_[]()&#";

	public var lineWidth:Array<Float> = [];
	public var letterSpace:FlxPoint = new FlxPoint();
	public final boxHeight:Float = 70;
	public var size(default, set):Float = 1;

	public var alphabetType:String = "alphabet";

	public function new(x:Float = 0, y:Float = 0, ?text:String = "")
	{
		super(x, y);
		this.text = text;
		antialiasing = true;
	}

	public function set_text(v:String):String
	{
		text = v;
		textArray = text.split("");
		typeTxt();
		return v;
	}

	public function typeTxt()
	{
		clear();

		var lastWidth:Float = 0;
		var daRow:Int = 0;

		for (i in 0...textArray.length)
		{
			var daLetter:String = textArray[i];

			if (daLetter == "\\")
			{
				daRow++;
				lastWidth = 0;
				lineWidth[daRow] = 0;
				continue;
			}

			// trace('da letter ' + i);
			// lets make it change lol
			var spacingWidth:Int = 28;
			switch (alphabetType)
			{
				case "small_alphabet":
					spacingWidth = 16;
				default:
					// nan
			}
			if (daLetter == " ")
			{
				lastWidth += spacingWidth / 2;
				lineWidth[daRow] = lastWidth;
				continue;
			}

			var letter = new PizzaLetter(alphabetType);
			letter.row = daRow;
			add(letter);

			letter.ID = i; // using this for typing

			// letters
			if (letters.contains(daLetter.toLowerCase()))
			{
				letter.makeLetter(daLetter);
			}
			// special
			if (graves.contains(daLetter.toLowerCase()))
			{
				letter.makeGraveLetter(daLetter);
			}
			// numbers
			if (numbers.contains(daLetter))
			{
				letter.makeNumber(daLetter);
			}
			// symbols
			if (symbols.contains(daLetter))
			{
				letter.makeSymbol(daLetter);
			}

			// lets make it change lol
			var widthAdd:Int = Std.int(letter.frameHeight / -3);

			// just so the width stays consistent
			letter.scale.set(1, 1);
			letter.updateHitbox();

			letter.lastWidth = lastWidth;
			lastWidth += letter.width + widthAdd;
			lineWidth[daRow] = lastWidth;
		}

		updateHitbox();
	}

	public function set_size(v:Float):Float
	{
		size = v;
		scale.set(v, v);
		updateHitbox();
		return v;
	}

	override function updateHitbox()
	{
		super.updateHitbox();
		for (rawLetter in members)
		{
			rawLetter.scale.set(scale.x, scale.y);
			rawLetter.updateHitbox();

			if (Std.isOfType(rawLetter, PizzaLetter))
			{
				var letter = cast(rawLetter, PizzaLetter);

				letter.x = x + ((letter.lastWidth * scale.x) + (letter.letterOffset.x * scale.x));

				switch (align)
				{
					default:
					case CENTER:
						letter.x -= (lineWidth[letter.row] * scale.x) / 2;
					case RIGHT:
						letter.x -= (lineWidth[letter.row] * scale.x);
				}

				// i hate you i hate you i hate you i hate you
				letter.y = y + (boxHeight * scale.y * (letter.row + 1));
				letter.y -= letter.height - (letter.letterOffset.y * scale.y);
			}
		}
	}
}

class PizzaLetter extends FlxSprite
{
	public var alphabetType:String;
	public var lastWidth:Float = 0;
	public var row:Int = 0;

	public var letterOffset:FlxPoint = new FlxPoint();

	public function new(?alphabetType:String = "alphabet")
	{
		super();
		// makeGraphic(30, 50, 0xFFFFFFFF);
		var atlasFrames = Paths.getAtlasFrames('eggs/PT/alphabet/$alphabetType');
		frames = atlasFrames;
		this.alphabetType = alphabetType;
	}

	function addAnim(animName:String, animXml:String)
	{
		animation.addByPrefix(animName, animXml, 1, false);
		animation.play(animName);
		updateHitbox();
	}

	public function makeLetter(key:String)
	{
		var captPref:String = (key == key.toUpperCase()) ? "_bold" : "0";
		var leAnim = key.toUpperCase() + captPref;
		addAnim(key, leAnim);
		// trace(key);

		if (alphabetType == "new_small_alphabet")
		{
			switch (leAnim.toLowerCase())
			{
				case "p0" | "q0" | "g0" | "y0":
					letterOffset.y = 4;
			}
		}
	}

	public function makeGraveLetter(key:String)
	{
		var captPref:String = (key == key.toUpperCase()) ? "_bold" : "0";
		addAnim(key, key.toUpperCase() + "_grave" + captPref);
		trace(key);
	}

	public function makeNumber(key:String)
	{
		addAnim(key, '${key}');
	}

	public function makeSymbol(key:String, bold:Bool = false)
	{
		// .:!?'"-_[]()&#
		var animName:String = switch (key)
		{
			default: key;
			case ".": "DOT";
			case ":": "DOUBLE_DOT";
			case "!": "EXCLAMATION_MARK";
			case "?": "INTERROGATIVE_MARK";
			case "'": "APOSTROPHE";
			case '"': "QUOTES";
			case "-": "HYPHEN";
			case "_": "UNDERSCORE";
			case "[": "PARENTHESIS_square_open";
			case "]": "PARENTHESIS_square_close";
			case "(": "PARENTHESIS_open";
			case ")": "PARENTHESIS_close";
			case "&": "&";
			case "#": "#";
		}
		addAnim(key, animName);
	}
	/*
		// completly useless but i made it now so
		public function getFrameHeight():Int
		{
			var jsonString:String = Assets.getText(frames.parent.assetsKey);
			var jsonData = haxe.Json.parse(jsonString);

			// Loop through the frames and print their heights
			var leHeight:Int = jsonData.frames[0].frame.h;
			return leHeight;
		}
	 */
}
