package gameObjects.ui;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteContainer;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;

class TurnCounter extends FlxSpriteContainer
{
    public var turn(default, set):Int = 1;

    var bg:FlxSprite;
    var skull:FlxSprite;
    var countText:FlxText;
    var skullScale:FlxPoint;

    var floatRadius:Float = 3;
    var floatSpeed:Float = 1;
    var floatTilt:Float = 8;
    var skullRestX:Float = 0;
    var skullRestY:Float = 0;
    var floatTime:Float = 0;

    public function new(x:Float = 0, y:Float = 0)
    {
        super(x, y);

        bg = new FlxSprite().loadGraphic(Paths.image('counter_bg'));
        bg.setGraphicSize(Std.int(bg.width * 3));
        bg.updateHitbox();
        add(bg);

        skull = new FlxSprite().loadGraphic(Paths.image('counter_skull'));
        skull.setGraphicSize(Std.int(skull.width * 3));
        skull.updateHitbox();
        add(skull);
        skullScale = new FlxPoint(skull.scale.x, skull.scale.y);

        countText = new FlxText(0, 0, bg.width, Std.string(turn), 16);
        countText.setFormat(null, 16, FlxColor.WHITE, CENTER, OUTLINE_FAST, FlxColor.BLACK);
        countText.setPosition(
            bg.width / 2 - countText.width / 2,
            bg.height / 2 - countText.height / 2 + 16
        );
        add(countText);

        skullRestX = skull.x - this.x;
        skullRestY = skull.y - this.y;
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        floatTime += elapsed * floatSpeed;

        var offsetX:Float = Math.cos(floatTime) * floatRadius;
        var offsetY:Float = Math.sin(floatTime) * floatRadius;

        skull.x = this.x + skullRestX + offsetX;
        skull.y = this.y + skullRestY + offsetY;

        skull.angle = Math.cos(floatTime) * floatTilt;
    }

    function set_turn(v:Int):Int
    {
        FlxTween.completeTweensOf(skull);
        FlxTween.completeTweensOf(countText);
        
        skull.scale.set(skullScale.x + 0.5, 0.2);
        countText.scale.set(1.3, 0.0);
        countText.angle = FlxG.random.bool(50) ? -10 : 10;
        FlxTween.tween(skull.scale, {x: skullScale.x, y: skullScale.y}, 0.4);
        FlxTween.tween(countText, {angle: 0, "scale.x": 1, "scale.y": 1}, 0.4);

        turn = v;
        countText.text = Std.string(turn);
        /*countText.setPosition(
            bg.width / 2 - countText.width / 2,
            bg.height / 2 - countText.height / 2 + 15
        );*/

        // skullScale.put();
        return turn;
    }
}