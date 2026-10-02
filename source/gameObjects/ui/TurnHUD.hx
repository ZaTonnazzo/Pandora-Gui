package gameObjects.ui;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.ui.FlxUIButton;
import flixel.group.FlxSpriteContainer;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;

class TurnHUD extends FlxSpriteContainer
{
    public var battleCallback:Void->Void;

    var body:FlxSprite;
    public var battleBtn:FlxUIButton;
    var arrowBtn:PandoraButton;

    private var open:Bool = false;

    public function new(x:Float = 0, y:Float = 0, bWidth:Int = 200, bHeight:Int = 200)
    {
        super(x, y);

        body = new FlxSprite().makeGraphic(bWidth, bHeight, FlxColor.fromRGB(43, 68, 86));
        add(body);

        battleBtn = new FlxUIButton(0, 0, "Battaglia!", function()
        {
            if (battleCallback != null)
                battleCallback();
        });
        battleBtn.label.size = 16;
        battleBtn.resize(150, 30);
        battleBtn.setPosition(
            body.width / 2 - battleBtn.width / 2,
            body.height / 2 - battleBtn.height / 2
        );
        add(battleBtn);

        var arrowIcon:FlxSprite = new FlxSprite().loadGraphic(Paths.image('arrow_icon'));
        arrowBtn = new PandoraButton(body.width, 0, 20, Std.int(bHeight / 2), FlxColor.fromRGB(35, 60, 80), arrowIcon);
        arrowBtn.y = body.height / 2 - arrowBtn.height / 2;
        arrowBtn.clickCallback = toggle;
        add(arrowBtn);
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        if (FlxG.keys.justPressed.TAB)
            toggle();
    }

    private function toggle():Void
    {
        open = !open;
        final openMult:Int = open ? 1 : -1;

        FlxTween.completeTweensOf(this, ["x"]);
        FlxTween.tween(this, {x: x + (200 * openMult)}, 0.2, {ease: FlxEase.quadOut});

        FlxTween.completeTweensOf(arrowBtn.label, ["angle"]);
        FlxTween.tween(arrowBtn.label, {angle: arrowBtn.label.angle + (180 * openMult)}, 0.5, {ease: FlxEase.elasticOut});
    }
}