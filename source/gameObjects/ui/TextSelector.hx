package gameObjects.ui;

import flixel.FlxObject;
import flixel.group.FlxSpriteContainer;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;

class TextSelector extends FlxSpriteContainer
{
    private var selL:FlxText;
    private var selR:FlxText;
    private var spacing:Float = 10;

    public var attachedObject:FlxObject;

    public function new(X:Float = 0, Y:Float = 0, attachedObject:FlxObject, spacing:Float = 10)
    {
        super(X, Y);
        this.attachedObject = attachedObject;
        this.spacing = spacing;

        selL = new FlxText(0, 0, 0, ">>", 32);
        selL.setFormat(null, 32, FlxColor.YELLOW, CENTER, OUTLINE_FAST, FlxColor.ORANGE);
        add(selL);

        selR = new FlxText(0, 0, 0, "<<", 32);
        selR.setFormat(null, 32, FlxColor.YELLOW, CENTER, OUTLINE_FAST, FlxColor.ORANGE);
        add(selR);
    }

    public function updateSelectors(?tween:Bool = false, ?ease:EaseFunction):Void
    {
        selL.size = Std.int(attachedObject.height);
        selR.size = Std.int(attachedObject.height);

        var dx1:Float = attachedObject.x - selL.width - spacing;
        var dx2:Float = attachedObject.x + attachedObject.width + spacing;
        var dy:Float = attachedObject.getMidpoint().y - selL.height / 2;

        FlxTween.cancelTweensOf(selL);
        FlxTween.cancelTweensOf(selR);

        if (tween)
        {
            FlxTween.tween(selL, {x: dx1, y: dy}, 0.15, {ease: ease});
            FlxTween.tween(selR, {x: dx2, y: dy}, 0.15, {ease: ease});
            return;
        }

        selL.setPosition(dx1, dy);
        selR.setPosition(dx2, dy);
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);
    }
}