package;

import flixel.FlxG;
import flixel.FlxGame;
import openfl.display.Sprite;
import states.*;

class Main extends Sprite
{
	public function new()
	{
		super();
		addChild(new FlxGame(1280, 720, (FlxG.random.bool(5)) ? DepthsState : TitleState));
		FlxG.mouse.useSystemCursor = true;
	}
}
