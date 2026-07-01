package states;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxState;
import flixel.addons.display.FlxBackdrop;
import flixel.group.FlxGroup;
import flixel.input.mouse.FlxMouseEvent;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.util.FlxColor;
import gameObjects.ui.TextSelector;

class TitleState extends PandoraState
{
	static var curSelected:Int = 0;

	var selector:TextSelector;
	var optionGroup:FlxTypedGroup<FlxText>;
	var optionShit:Array<String> = ["Turni", "Esci"];

	override public function create()
	{
		super.create();
		bgColor = 0xFF0f0f1a;

		var backdrop:FlxBackdrop = new FlxBackdrop(Paths.image('backdrop'), XY);
		backdrop.color = FlxColor.GRAY;
		backdrop.velocity.set(35, -35);
		add(backdrop);

		optionGroup = new FlxTypedGroup<FlxText>();
		add(optionGroup);

		for (i in 0...optionShit.length)
		{
			var txt:FlxText = new FlxText(0, 0, 0, optionShit[i], 32);
			txt.setFormat(null, 32, FlxColor.WHITE, CENTER, OUTLINE_FAST, FlxColor.BLACK);
			txt.screenCenter(X);
			optionGroup.add(txt);

			FlxMouseEvent.add(txt, onDown, null, onOver, null);
		}
		centerEvenlyY(optionGroup, FlxG.height / 2 - 50, FlxG.height / 2 + 50);

		selector = new TextSelector(0, 0, null, 25);
		add(selector);

		changeSelection();
	}

	private function onDown(object:FlxObject):Void
	{
		acceptSelection();
	}

	private function onOver(object:FlxObject):Void
	{
		for (idx in 0...optionGroup.members.length)
		{
			var obj = optionGroup.members[idx];
			if (obj == object)
			{
				if (idx != curSelected)
					changeSelection(idx, true);
			}
		}
	}

	private function centerEvenlyY(grp:FlxTypedGroup<FlxText>, top:Float, bottom:Float):Void
	{
		var totalHeight:Float = 0;
		grp.forEach(function(txt:FlxText)
		{
			totalHeight += txt.height;
		});

		var avHeight:Float = bottom - top;
		var spacing:Float = 0;

		if (grp.members.length > 1)
			spacing = (avHeight - totalHeight) / (grp.members.length - 1);

		var contentHeight:Float = totalHeight + spacing * (grp.members.length - 1);
		var leY:Float = top + (avHeight - contentHeight) * 0.5;

		grp.forEach(function(txt:FlxText)
		{
			txt.y = leY;
			leY += txt.height + spacing;
		});
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		handleInput();
	}

	private function handleInput():Void
	{
		if (transitioning)
			return;

		if (FlxG.keys.anyJustPressed([UP, W]))
			changeSelection(-1);
		else if (FlxG.keys.anyJustPressed([DOWN, S]))
			changeSelection(1);

		if (FlxG.keys.anyJustPressed([Z, ENTER]))
			acceptSelection();

		if (FlxG.keys.justPressed.ESCAPE)
			Sys.exit(0);
	}

	private function changeSelection(change:Int = 0, ?force:Bool = false):Void
	{
		if (force)
			curSelected = change;
		else
			curSelected = FlxMath.wrap(curSelected + change, 0, optionGroup.members.length - 1);

		var curOpt = optionGroup.members[curSelected];
		optionGroup.forEach(function(txt:FlxText)
		{
			if (txt == curOpt)
			{
				txt.color = FlxColor.YELLOW;
				txt.borderColor = FlxColor.ORANGE;
			}
			else
			{
				txt.color = FlxColor.WHITE;
				txt.borderColor = FlxColor.BLACK;
			}
		});
		selector.attachedObject = curOpt;
		selector.updateSelectors((change != 0) ? true : false, FlxEase.backOut);
	}

	private function acceptSelection():Void
	{
		switch(optionGroup.members[curSelected].text.toLowerCase())
		{
			case "turni":
				switchState(new TurnState());
			default:
				Sys.exit(0);
		}
	}
}
