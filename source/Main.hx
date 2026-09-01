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
		addChild(new FlxGame(1280, 720, getStartState(), 60, 60, true));
		FlxG.mouse.useSystemCursor = true;
	}

	private function getStartState():Class<flixel.FlxState>
    {
        var easterEggs:Array<Class<flixel.FlxState>> = [
            DepthsState,
            MoriTitleState,
            PTState
        ];

        var chosen = SaveData.pickStartState(easterEggs);
        return chosen != null ? chosen : TitleState;
    }
}
