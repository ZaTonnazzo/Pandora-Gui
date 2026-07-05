package gameObjects.ui;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteContainer;
import flixel.input.mouse.FlxMouseEvent;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;

class PandoraScrollbar extends FlxSpriteContainer
{
	public var bg:FlxSprite;
	public var bar:FlxSprite;
	@:readOnly public var scrollPercent(default, set):Float = 0;
	public var onScroll:Float->Void;
	public var canScroll:Bool = true;

	private var dragging:Bool = false;
	private var dragOffset:Float = 0;
	private var trackHeight:Float;
	private var barHeight:Float;

	public function new(X:Float = 0, Y:Float = 0, Height:Float = 0, BarHeightRatio:Float = 0.1,
		BackgroundColor:FlxColor = FlxColor.GRAY, BarColor:FlxColor = FlxColor.WHITE)
	{
		super(X, Y);

		var h:Float = Height > 0 ? Height : camera.height;
		var w:Float = Std.int(h / 30) > 0 ? h / 30 : 20;

		bg = new FlxSprite().makeGraphic(Std.int(w), Std.int(h), BackgroundColor);
		add(bg);

		barHeight = h * BarHeightRatio;
		bar = new FlxSprite().makeGraphic(Std.int(bg.width), Std.int(barHeight), BarColor);
		bar.alpha = 0.6;
		add(bar);

		trackHeight = bg.height - bar.height;

		FlxMouseEvent.add(bar, onBarDown, null, onBarOver, onBarOut);
		FlxMouseEvent.add(bg, onTrackDown);

		updateBarPosition();
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		handleInput();
	}

	private function handleInput():Void
	{
		if (!canScroll)
			return;

		if (dragging)
		{
			if (!FlxG.mouse.pressed)
			{
				dragging = false;
			}
			else
			{
				var localY:Float = FlxG.mouse.getScreenPosition(camera).y - y - dragOffset;
				var clamped:Float = FlxMath.bound(localY, 0, trackHeight);
				scrollPercent = trackHeight > 0 ? clamped / trackHeight : 0;
			}
		}

		if (FlxG.mouse.wheel != 0)
		{
			var delta:Float = -FlxG.mouse.wheel * 0.05;
			scrollPercent = FlxMath.bound(scrollPercent + delta, 0, 1);
		}
	}

	private function overlapsMouse():Bool
	{
		return FlxG.mouse.overlaps(bg);
	}

	private function onBarDown(sprite:FlxSprite):Void
	{
		dragging = true;
		dragOffset = FlxG.mouse.getScreenPosition(camera).y - (y + bar.y);
	}

	private function onBarOver(sprite:FlxSprite):Void
	{
		bar.alpha = 0.9;
	}

	private function onBarOut(sprite:FlxSprite):Void
	{
		if (!dragging)
			bar.alpha = 0.6;
	}

	private function onTrackDown(sprite:FlxSprite):Void
	{
		var localY:Float = FlxG.mouse.getScreenPosition(camera).y - y - (bar.height / 2);
		var clamped:Float = FlxMath.bound(localY, 0, trackHeight);
		scrollPercent = trackHeight > 0 ? clamped / trackHeight : 0;
		dragging = true;
		dragOffset = bar.height / 2;
	}

	public function set_scrollPercent(value:Float):Float
	{
		value = FlxMath.bound(value, 0, 1);
		scrollPercent = value;
		updateBarPosition();

		if (onScroll != null)
			onScroll(value);

		return value;
	}

	public function updateBarPosition():Void
	{
		bar.y = trackHeight * scrollPercent;
	}

	public function setBarRatio(ratio:Float):Void
	{
		ratio = FlxMath.bound(ratio, 0.05, 1);
		var newBarHeight:Float = bg.height * ratio;
		bar.setGraphicSize(Std.int(bar.width), Std.int(newBarHeight));
		bar.updateHitbox();
		trackHeight = bg.height - bar.height;
		updateBarPosition();
	}

	/*
	public function scrollByWheel(wheelDelta:Int, speed:Float = 0.05):Void
	{
		var delta:Float = -wheelDelta * speed;
		scrollPercent = FlxMath.bound(scrollPercent + delta, 0, 1);
	}
	*/

	override public function destroy():Void
	{
		FlxMouseEvent.remove(bar);
		FlxMouseEvent.remove(bg);
		super.destroy();
	}
}