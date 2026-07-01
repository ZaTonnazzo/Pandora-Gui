package gameObjects.ui;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteContainer;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import flixel.util.FlxColor;

using flixel.util.FlxSpriteUtil;

class FileFrame extends FlxSpriteContainer
{
    public var box:FlxSprite;
    public var creatorText:FlxText;
    public var timeText:FlxText;
    public var placeText:FlxText;
    public var choiceTxts:Array<FlxText> = [];
    public var hovered:Bool = false;
    public var selected:Bool = false;

    // private var alphadBlack:FlxColor = FlxColor.fromRGB(0, 0, 0, 150);
    private var alphadWhite:FlxColor = FlxColor.fromRGB(0, 127, 14);
    private var boxOutline:FlxSprite;
    private var startText:FlxText;
    private var backText:FlxText;

    public function new(X:Float = 0, Y:Float = 0)
    {
        super(X, Y);

        box = new FlxSprite().makeGraphic(Std.int(640 / 6 * 4), 90, FlxColor.TRANSPARENT);
        add(box);

        boxOutline = new FlxSprite().makeGraphic(Std.int(box.width), Std.int(box.height), FlxColor.TRANSPARENT);
        boxOutline = boxOutline.drawRect(0, 0, boxOutline.width, boxOutline.height, FlxColor.TRANSPARENT, {color: FlxColor.LIME, thickness: 6});
        boxOutline.color = alphadWhite;
        add(boxOutline);

        creatorText = new FlxText(box.width / 10, box.y + 10, box.width - (box.width / 10 * 2), "[EMPTY]", 32);
        creatorText.setFormat(Paths.fontTTF('determination'), 32, alphadWhite, LEFT, SHADOW, FlxColor.BLACK);
        creatorText.shadowOffset.set(2, 2);
        add(creatorText);

        timeText = new FlxText(box.width / 10, box.y + 10, box.width - (box.width / 10 * 2), "--:--", 32);
        timeText.setFormat(Paths.fontTTF('determination'), 32, alphadWhite, RIGHT, SHADOW, FlxColor.BLACK);
        timeText.shadowOffset.set(2, 2);
        add(timeText);

        placeText = new FlxText(box.width / 10, box.y + 45, box.width - (box.width / 10 * 2), "____________", 32);
        placeText.setFormat(Paths.fontTTF('determination'), 32, alphadWhite, LEFT, SHADOW, FlxColor.BLACK);
        placeText.shadowOffset.set(2, 2);
        add(placeText);

        //

        startText = new FlxText(box.getMidpoint().x, placeText.y, 0, "Esegui", 32);
        startText.setFormat(Paths.fontTTF('determination'), 32, alphadWhite, LEFT, SHADOW, FlxColor.BLACK);
        startText.shadowOffset.set(2, 2);
        startText.x -= startText.size * startText.text.length - 20;
        startText.visible = false;
        add(startText);

        backText = new FlxText(box.getMidpoint().x + 50, placeText.y, 0, "Annulla", 32);
        backText.setFormat(Paths.fontTTF('determination'), 32, alphadWhite, LEFT, SHADOW, FlxColor.BLACK);
        backText.shadowOffset.set(2, 2);
        backText.visible = false;
        add(backText);

        choiceTxts.push(startText);
        choiceTxts.push(backText);
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);
    }

    public function hover():Void
    {
        hovered = true;
        boxOutline.color = FlxColor.LIME;
        creatorText.color = FlxColor.LIME;
        timeText.color = FlxColor.LIME;
        placeText.color = FlxColor.LIME;
    }

    public function unhover():Void
    {
        hovered = true;
        boxOutline.color = alphadWhite;
        creatorText.color = alphadWhite;
        timeText.color = alphadWhite;
        placeText.color = alphadWhite;
    }

    public function select():Void
    {
        selected = true;
        placeText.visible = false;
        startText.visible = true;
        backText.visible = true;
    }

    public function unselect():Void
    {
        selected = false;
        placeText.visible = true;
        startText.visible = false;
        backText.visible = false;
    }
}