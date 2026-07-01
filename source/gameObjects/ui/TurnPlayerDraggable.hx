package gameObjects.ui;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.group.FlxSpriteContainer;
import flixel.input.mouse.FlxMouseEvent;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import flixel.util.FlxAxes;
import flixel.util.FlxColor;
import gameObjects.data.TurnPlayer;

using flixel.util.FlxSpriteUtil;

class TurnPlayerDraggable extends FlxSpriteContainer
{
    public var player:TurnPlayer;
    public var dragStyle:FlxAxes;
    public var canDrag:Bool = true;
    public var dragging:Bool = false;
    public var maxDrag:FlxPoint;
    public var minDrag:FlxPoint;
    public var dragCallback:Void->Void;
    public var undragCallback:Void->Void;
    public var deleteCallback:Void->Void;

    var box:FlxSprite;
    var nameField:FlxText;
    var scoreField:FlxText;

    public function new(X:Float = 0, Y:Float = 0, turnPlayer:TurnPlayer, dragStyle:FlxAxes)
    {
        super(X, Y);
        player = turnPlayer;
        this.dragStyle = dragStyle;

        box = new FlxSprite().makeGraphic(700, 70, FlxColor.TRANSPARENT);
        box = box.drawRect(0, 0, box.width, box.height, FlxColor.GRAY, {color: FlxColor.WHITE, thickness: 5});
        add(box);

        nameField = new FlxText(10, 0, box.width - 20, player.name, 32);
        nameField.setFormat(null, 32, FlxColor.WHITE, LEFT, OUTLINE_FAST, FlxColor.BLACK);
        nameField.y = (get_height() / 2) - (nameField.height / 2);
        add(nameField);

        scoreField = new FlxText(nameField.x, nameField.y, nameField.fieldWidth, (player.getNat()) ? (Std.string(player.score) + "nat") : Std.string(player.score), 32);
        scoreField.setFormat(null, 32, FlxColor.WHITE, RIGHT, OUTLINE_FAST, FlxColor.BLACK);
        add(scoreField);

        FlxMouseEvent.add(this, onDown, null, null, null);
    }

    public function onDown(obj:FlxObject):Void
    {
        if (!canDrag)
            return;

        dragging = true;
        box.color = FlxColor.YELLOW;
        
        if (dragCallback != null)
            dragCallback();
    }

    public function onUp():Void
    {
        if (!canDrag)
            return;

        dragging = false;
        box.color = FlxColor.WHITE;

        if (undragCallback != null)
            undragCallback();
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        handleDrag();

        if (dragging)
        {
            if (FlxG.mouse.pressedRight)
                box.color = FlxColor.RED;
            if (FlxG.mouse.justReleasedRight)
                delete();
        }
    }

    private function handleDrag():Void
    {
        if (!canDrag)
            return;

        if (dragging)
        {
            switch (dragStyle)
            {
                case X:
                    var dx:Float = FlxG.mouse.screenX + width / 2;
                    if (maxDrag != null && minDrag != null)
                        if (dx >= maxDrag.x || dx <= minDrag.x)
                            return;

                    x = dx;
                case Y:
                    var dy:Float = FlxG.mouse.screenY - height / 2;
                    if (maxDrag != null && minDrag != null)
                        if (dy >= maxDrag.y || dy <= minDrag.y)
                            return;
                    
                    y = dy;
                default:
                    var dx:Float = FlxG.mouse.screenX + width / 2;
                    var dy:Float = FlxG.mouse.screenY - height / 2;
                    if (maxDrag != null && minDrag != null)
                        if ((dx >= maxDrag.x || dx <= minDrag.x) || (dy >= maxDrag.y || dy <= minDrag.y))
                            return;

                    setPosition(dx, dy);
            }

            if (FlxG.mouse.justReleased)
                onUp();
        }
    }

    private function delete():Void
    {
        if (deleteCallback != null)
            deleteCallback();
        if (undragCallback != null)
            undragCallback();
        
        kill();
    }
}