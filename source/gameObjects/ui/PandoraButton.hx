package gameObjects.ui;

import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.group.FlxSpriteContainer;
import flixel.input.mouse.FlxMouseEvent;
import flixel.util.FlxColor;

using flixel.util.FlxSpriteUtil;

class PandoraButton extends FlxSpriteContainer
{
    public var body:FlxSprite;
    public var label:FlxSprite;
    public var clickCallback:Void->Void;

    private var overlay:FlxSprite;

    public function new(X:Float = 0, Y:Float = 0, Width:Int = 10, Height:Int = 10, Color:FlxColor = FlxColor.GRAY, ?label:FlxSprite)
    {
        super(X, Y);

        body = new FlxSprite().makeGraphic(Width, Height, Color);
        // body.drawRoundRectComplex(0, 0, body.width, body.height, 10, 10, 0, 0, Color);
        add(body);

        if (label != null)
        {
            updateLabel(label);
            add(this.label);
        }
        else
        {
            this.label = new FlxSprite(body.getMidpoint().x, body.getMidpoint().y);
            this.label.visible = false;
            add(this.label);
        }

        overlay = new FlxSprite().makeGraphic(Std.int(body.width), Std.int(body.height), FlxColor.WHITE);
        overlay.alpha = 0;
        add(overlay);

        FlxMouseEvent.add(this, onDown, onUp, onOver, onOut);
    }

    private function onDown(obj:FlxObject):Void
    {
        overlay.color = FlxColor.BLACK;
    }

    private function onUp(obj:FlxObject):Void
    {
        overlay.color = FlxColor.WHITE;

        if (clickCallback != null)
            clickCallback();
    }

    private function onOver(obj:FlxObject):Void
    {
        overlay.alpha = 0.3;
    }

    private function onOut(obj:FlxObject):Void
    {
        if (overlay.color != FlxColor.WHITE)
            overlay.color = FlxColor.WHITE;
        overlay.alpha = 0;
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);
    }

    public function updateLabel(newLabel:FlxSprite):Void
    {
        if (label != null && label.graphic != null)
            label.visible = true;

        label = newLabel;
        label.setPosition(body.width / 2 - label.width / 2, body.height / 2 - label.height / 2);
        label.updateHitbox();
    }
}