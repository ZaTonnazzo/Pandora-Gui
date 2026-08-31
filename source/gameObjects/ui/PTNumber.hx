package gameObjects.ui;

import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup;
import flixel.tweens.FlxEase.EaseFunction;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

class PTNumber extends FlxSpriteGroup
{
	public var digitPrefixes:Array<String> = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"];
	public var spacing(default, set):Float = 0;
	public var align(default, set):PTNumberAlign = LEFT;
	public var value(default, set):Int = 0;
	public var minDigits(default, set):Int = 1;
	public var digitScale(default, set):Float = 1;

	var _tweenValue:Float = 0;
    var _valueTween:FlxTween;

	var _frames:FlxAtlasFrames;
	var _digitSprites:Array<FlxSprite> = [];

	public function new(x:Float = 0, y:Float = 0, imagePath:String, value:Int = 0)
	{
		super(x, y);

		_frames = Paths.getAtlasFrames(imagePath);

		this.value = value;
	}

	function set_value(newValue:Int):Int
	{
		if (newValue < 0)
			newValue = 0;

		value = newValue;

		if (_frames != null)
			buildDigits();

		return value;
	}

	function set_minDigits(newValue:Int):Int
	{
		minDigits = (newValue < 1) ? 1 : newValue;

		if (_frames != null)
			buildDigits();

		return minDigits;
	}

	function set_spacing(newValue:Float):Float
	{
		spacing = newValue;
		repositionDigits();
		return spacing;
	}

	function set_align(newValue:PTNumberAlign):PTNumberAlign
	{
		align = newValue;
		repositionDigits();
		return align;
	}

	function set_digitScale(newValue:Float):Float
	{
		digitScale = newValue;

		for (sprite in _digitSprites)
		{
			sprite.scale.set(digitScale, digitScale);
			sprite.updateHitbox();
		}

		repositionDigits();
		return digitScale;
	}

	function buildDigits():Void
	{
		var digitsStr:String = Std.string(value);

		while (digitsStr.length < minDigits)
			digitsStr = "0" + digitsStr;

		var digitChars:Array<String> = digitsStr.split("");

		while (_digitSprites.length > digitChars.length)
		{
			var extra:FlxSprite = _digitSprites.pop();
			remove(extra, true);
			extra.destroy();
		}

		while (_digitSprites.length < digitChars.length)
		{
			var digitSprite:FlxSprite = new FlxSprite();
			digitSprite.frames = _frames;
			digitSprite.scale.set(digitScale, digitScale);
			digitSprite.updateHitbox();
			_digitSprites.push(digitSprite);
			add(digitSprite);
		}

		for (i in 0...digitChars.length)
		{
			var digitInt:Int = Std.parseInt(digitChars[i]);
			var prefix:String = digitPrefixes[digitInt];
			var sprite:FlxSprite = _digitSprites[i];

			if (!sprite.animation.exists(prefix))
				sprite.animation.addByPrefix(prefix, prefix, 0, false);

			sprite.animation.play(prefix);
		}

		repositionDigits();
	}

	function repositionDigits():Void
	{
		if (_digitSprites.length == 0)
			return;

		var totalWidth:Float = 0;

		for (i in 0..._digitSprites.length)
		{
			var sprite:FlxSprite = _digitSprites[i];
			sprite.x = x + totalWidth;
			sprite.y = y;
			totalWidth += sprite.width + spacing;
		}

		totalWidth -= spacing;

		var offsetX:Float = switch (align)
		{
			case LEFT: 0;
			case CENTER: -totalWidth / 2;
			case RIGHT: -totalWidth;
		}

		for (sprite in _digitSprites)
			sprite.x += offsetX;
	}

	public function setCoolValue(newValue:Int, duration:Float = 0.5, ?ease:EaseFunction):Void
    {
        if (duration <= 0)
        {
            value = newValue;
            _tweenValue = newValue;
            return;
        }

        if (_valueTween != null)
            _valueTween.cancel();

        _tweenValue = value;

        _valueTween = FlxTween.tween(this, { _tweenValue: newValue }, duration,
        {
            ease: (ease != null) ? ease : FlxEase.quadOut,
            onUpdate: function(_) {
                value = Math.round(_tweenValue);
            },
            onComplete: function(_) {
                value = newValue;
            }
        });
    }
}

enum PTNumberAlign
{
	LEFT;
	CENTER;
	RIGHT;
}
