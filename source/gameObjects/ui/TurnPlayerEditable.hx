package gameObjects.ui;

import flixel.FlxSprite;
import flixel.group.FlxSpriteContainer;
import flixel.text.FlxInputText;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import gameObjects.data.TurnPlayer;

using flixel.util.FlxSpriteUtil;

class TurnPlayerEditable extends FlxSpriteContainer
{
    public var player:TurnPlayer;
    public var fields:Array<FlxInputText> = [];
    public var labels:Array<FlxText> = [];

    var box:FlxSprite;
    var flashTimers:Map<Int, FlxTimer> = new Map();
    var normalLabels:Array<String> = [];

    public function new(x:Float = 0, y:Float = 0, player:TurnPlayer)
    {
        super(x, y);
        this.player = player;

        box = new FlxSprite().makeGraphic(700, 70, FlxColor.TRANSPARENT);
        box = box.drawRect(0, 0, box.width, box.height, FlxColor.GRAY, {color: FlxColor.WHITE, thickness: 5});
        add(box);

        // build fields

        var configs = TurnPlayerDraggable.defaultFields();
        var offsetX:Float = 0;
        for (i in 0...configs.length)
        {
            var cfg = configs[i];
            var slotWidth:Float = box.width * cfg.widthRatio;

            var text:FlxInputText = new FlxInputText(offsetX + 5, 0, slotWidth - 10, cfg.getValue(player), 32);
            text.wordWrap = false;
            text.setFormat(null, 32, FlxColor.BLACK, LEFT, NONE);
            text.y = (box.height / 2) - (text.height / 2);
            add(text);
            fields.push(text);

            var topLabel:FlxText = new FlxText(text.x - 1, box.y - 20, 0, '${cfg.displayName}:', 14);
            topLabel.setFormat(null, 14, FlxColor.BLACK, LEFT, OUTLINE_FAST, FlxColor.WHITE);
            add(topLabel);
            labels.push(topLabel);
            normalLabels.push(topLabel.text);

            // dividers
            if (i > 0)
                box.drawLine(offsetX, 1, offsetX, box.height - 1, {color: FlxColor.WHITE, thickness: 2});

            offsetX += slotWidth;
        }
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);
    }

    public function showError(index:Int, msg:String = "Invalido."):Void
    {
        var label = labels[index];

        var old = flashTimers.get(index);
        if (old != null)
            old.cancel();

        label.text = msg;
        label.color = FlxColor.RED;
        label.borderColor = FlxColor.BLACK;
        flashTimers.set(index, new FlxTimer().start(1, function(_)
        {
            label.text = normalLabels[index];
            label.color = FlxColor.BLACK;
            label.borderColor = FlxColor.WHITE;
        }));
    }

    override public function destroy()
    {
        for (t in flashTimers)
            t.cancel();
        flashTimers.clear();
        super.destroy();
    }
}