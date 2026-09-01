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
import flixel.util.FlxTimer;
import gameObjects.data.TurnPlayer;

using flixel.util.FlxSpriteUtil;

typedef FieldConfig =
{
    getValue:TurnPlayer->String,
    widthRatio:Float,
    align:FlxTextAlign
}

class TurnPlayerDraggable extends FlxSpriteContainer
{
    public var player:TurnPlayer;
    public var dragStyle:FlxAxes;
    public var canDrag:Bool = true;
    public var dragging:Bool = false;
    public var selected:Bool = false;
    public var maxDrag:FlxPoint;
    public var minDrag:FlxPoint;
    public var dragCallback:Void->Void;
    public var undragCallback:Void->Void;
    public var deleteCallback:Void->Void;
    public var doubleClickCallback:Void->Void;
    public var doubleClickThreshold:Float = 0.2;

    var box:FlxSprite;
    var fields:Array<FlxText> = [];
    var clickTimer:FlxTimer;
    var awaitingSecondClick:Bool = false;

    public static function defaultFields():Array<FieldConfig>
    {
        return [
            {
                getValue: function(p:TurnPlayer) return p.name,
                widthRatio: 0.40,
                align: LEFT
            },
            {
                getValue: function(p:TurnPlayer) return p.getNat() ? (Std.string(p.score) + "nat") : Std.string(p.score),
                widthRatio: 0.25,
                align: RIGHT
            },
            {
                getValue: function(p:TurnPlayer) return Std.string(p.hp),
                widthRatio: 0.175,
                align: CENTER
            },
            {
                getValue: function(p:TurnPlayer) return Std.string(p.ac),
                widthRatio: 0.175,
                align: CENTER
            }
        ];
    }

    public function new(X:Float = 0, Y:Float = 0, turnPlayer:TurnPlayer, dragStyle:FlxAxes, ?fieldConfigs:Array<FieldConfig>)
    {
        super(X, Y);
        player = turnPlayer;
        this.dragStyle = dragStyle;

        box = new FlxSprite().makeGraphic(700, 70, FlxColor.TRANSPARENT);
        box = box.drawRect(0, 0, box.width, box.height, FlxColor.GRAY, {color: FlxColor.WHITE, thickness: 5});
        add(box);

        var configs = (fieldConfigs != null) ? fieldConfigs : defaultFields();
        buildFields(configs);
    }

    private function buildFields(configs:Array<FieldConfig>):Void
    {
        var offsetX:Float = 0;

        for (i in 0...configs.length)
        {
            var cfg = configs[i];
            var slotWidth:Float = box.width * cfg.widthRatio;

            var text:FlxText = new FlxText(offsetX + 5, 0, slotWidth - 10, cfg.getValue(player), 32);
            text.wordWrap = false;
            text.setFormat(null, 32, FlxColor.WHITE, LEFT, OUTLINE_FAST, FlxColor.BLACK);
            text.y = (box.height / 2) - (text.height / 2);
            add(text);
            fields.push(text);

            // dividers
            if (i > 0)
                box.drawLine(offsetX, 1, offsetX, box.height - 1, {color: FlxColor.WHITE, thickness: 2});

            offsetX += slotWidth;
        }

        FlxMouseEvent.add(this, onDown, null, null, null);
    }

    public function refresh(configs:Array<FieldConfig>):Void
    {
        for (i in 0...fields.length)
        {
            if (i < configs.length)
                fields[i].text = configs[i].getValue(player);
        }
    }

    public function onDown(obj:FlxObject):Void
    {
        if (!canDrag)
            return;

        if (awaitingSecondClick)
        {
            awaitingSecondClick = false;
            clickTimer.cancel();

            if (doubleClickCallback != null)
                doubleClickCallback();

            return;
        }

        dragging = true;
        box.color = FlxColor.YELLOW;

        if (dragCallback != null)
            dragCallback();

        awaitingSecondClick = true;
        clickTimer = new FlxTimer().start(doubleClickThreshold, function(_) {
            awaitingSecondClick = false;
        });
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

    public function select():Void
    {
        selected = true;
        box.color = FlxColor.YELLOW;
    }

    public function unselect():Void
    {
        selected = false;
        box.color = FlxColor.WHITE;
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        handleDrag();

        if (dragging || selected)
        {
            if (FlxG.mouse.pressedRight || FlxG.keys.pressed.DELETE)
                box.color = FlxColor.RED;
            if (FlxG.mouse.justReleasedRight || FlxG.keys.justReleased.DELETE)
                delete();
        }
    }

    private function handleDrag():Void
    {
        if (!canDrag)
            return;

        if (dragging)
        {
            var worldPos:FlxPoint = FlxG.mouse.getWorldPosition(camera);

            switch (dragStyle)
            {
                case X:
                    var dx:Float = worldPos.x + width / 2;
                    if (maxDrag != null && minDrag != null)
                        if (dx >= maxDrag.x || dx <= minDrag.x)
                            return;
                    x = dx;
                case Y:
                    var dy:Float = worldPos.y - height / 2;
                    if (maxDrag != null && minDrag != null)
                        if (dy >= maxDrag.y || dy <= minDrag.y)
                            return;
                    y = dy;
                default:
                    var dx:Float = worldPos.x + width / 2;
                    var dy:Float = worldPos.y - height / 2;
                    if (maxDrag != null && minDrag != null)
                        if ((dx >= maxDrag.x || dx <= minDrag.x) || (dy >= maxDrag.y || dy <= minDrag.y))
                            return;
                    setPosition(dx, dy);
            }

            worldPos.put(); // recycle

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