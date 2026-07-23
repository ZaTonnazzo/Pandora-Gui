package gameObjects.ui;

import flixel.FlxSprite;
import flixel.group.FlxSpriteContainer;
import flixel.text.FlxText;
import flixel.util.FlxColor;

using flixel.util.FlxSpriteUtil;

class MoriButton extends FlxSpriteContainer
{
    public var body:FlxSprite;
    public var label:FlxText;

    public function new(X:Float = 0, Y:Float = 0, Width:Int = 200, Height:Int = 50, Text:String)
    {
        super(X, Y);

        var bg:FlxSprite = new FlxSprite().makeGraphic(Width, Height, FlxColor.BLACK);
        add(bg);

        body = new FlxSprite().makeGraphic(Width, Height, FlxColor.BLACK);
        body.drawRect(6, 6, body.width - 12, body.height - 12, FlxColor.TRANSPARENT, {color: FlxColor.WHITE, thickness: 6, capsStyle: SQUARE, jointStyle: MITER});
        add(body);

        final textSize:Int = Std.int(body.height - 10);
        label = new FlxText(0, 0, body.width, Text.toUpperCase(), textSize);
        label.setFormat(Paths.fontTTF('omori_game'), textSize, FlxColor.WHITE, CENTER);
        add(label);
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);
    }
}