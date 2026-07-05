package;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxState;
import flixel.util.FlxColor;

class PandoraState extends FlxState
{
	public var transitioning:Bool = false;
	public var transitionTime:Float = 0.2;
	public var fadeColor:FlxColor = FlxColor.BLACK;

    override public function create()
	{
		super.create();
		transIn();
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}

	public function switchState(state:FlxState):Void
	{
		if (transitioning)
			return;

		transitioning = true;
		transOut(state);
	}

	public function transIn():Void
	{
		transitioning = true;

		var farthestCam:FlxCamera = FlxG.cameras.list[FlxG.cameras.list.length - 1];
		farthestCam.fade(fadeColor, transitionTime, true, function()
		{
			transitioning = false;
		});
	}

	public function transOut(state:FlxState):Void
	{
		transitioning = true;
		
		var farthestCam:FlxCamera = FlxG.cameras.list[FlxG.cameras.list.length - 1];
		farthestCam.fade(fadeColor, transitionTime, false, function()
		{
			FlxG.switchState(state);
		});
	}
}