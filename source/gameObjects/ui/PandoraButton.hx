package gameObjects.ui;

import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.group.FlxSpriteContainer;
import flixel.input.mouse.FlxMouseEvent;
import flixel.util.FlxColor;

using flixel.util.FlxSpriteUtil;

class PandoraButton extends FlxSpriteContainer
{
    public var box:FlxSprite;
    public var label:FlxSprite;
    public var clickCallback:Void->Void;

    public function new(X:Float = 0, Y:Float = 0, Width:Int = 10, Height:Int = 10, InsideColor:FlxColor = FlxColor.GRAY, OutlineColor:FlxColor = FlxColor.WHITE, OutlineThickness:Int = 5, ?label:FlxSprite)
    {
        super(X, Y);

        box = new FlxSprite().makeGraphic(Width, Height, FlxColor.TRANSPARENT);
        box = box.drawRect(0, 0, box.width, box.height, InsideColor, {color: OutlineColor, thickness: OutlineThickness});
        add(box);

        if (label != null)
        {
            updateLabel(label);
            add(this.label);
        }
        else
        {
            this.label = new FlxSprite(box.getMidpoint().x, box.getMidpoint().y);
            this.label.visible = false;
            add(this.label);
        }

        FlxMouseEvent.add(this, onDown, onUp, onOver, onOut);
    }

    private function onDown(obj:FlxObject):Void
    {
        forEachOfType(FlxSprite, function(spr:FlxSprite)
        {
            spr.color.black += 0.2;
        });
    }

    private function onUp(obj:FlxObject):Void
    {
        forEachOfType(FlxSprite, function(spr:FlxSprite)
        {
            spr.color.black -= 0.2;
        });

        if (clickCallback != null)
            clickCallback();
    }

    private function onOver(obj:FlxObject):Void
    {
        forEachOfType(FlxSprite, function(spr:FlxSprite)
        {
            spr.color.black += 0.2;
        });
    }

    private function onOut(obj:FlxObject):Void
    {
        forEachOfType(FlxSprite, function(spr:FlxSprite)
        {
            spr.color.black -= 0.2;
        });
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);
    }

    public function updateLabel(newLabel:FlxSprite):Void
    {
        if (label != null && label.graphic == null)
            label.visible = true;

        label = newLabel;
        label.setPosition(box.getMidpoint().x - label.width / 2, box.getMidpoint().y - label.height / 2);
        label.updateHitbox();
    }
}