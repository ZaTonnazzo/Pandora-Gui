package states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import gameObjects.ui.MoriButton;

class MoriTitleState extends PandoraState
{
    var logo:FlxSprite;
    var bright:FlxSprite;
    var selector:FlxSprite;

    var curSelected:Int = 0;
    var btnGroup:FlxTypedGroup<MoriButton>;
    var optionShit:Array<String> = ["turni", "esci"];

    override public function create()
    {
        super.create();
        bgColor = FlxColor.WHITE;
        transitionTime = 0.5;
        FlxG.sound.playMusic(Paths.music('o_title'));

        var mor:FlxSprite = new FlxSprite().loadGraphic(Paths.image('eggs/o_guy'), true, 306, 351);
        mor.animation.add("default", [0, 1, 2], 2, true);
        mor.animation.play("default");
        mor.setGraphicSize(Std.int(mor.width * 1.6));
        mor.updateHitbox();
        mor.screenCenter(X);
        mor.y = FlxG.height - mor.height;
        mor.antialiasing = true;
        add(mor);

        logo = new FlxSprite(411, -50).loadGraphic(Paths.image('eggs/o_logo'));
        logo.setGraphicSize(Std.int(logo.width * 1.5));
        logo.updateHitbox();
        add(logo);

        bright = new FlxSprite(0, 80).loadGraphic(Paths.image('eggs/o_bright'), true, 67, 65);
        bright.animation.add("default", [0, 1, 2], 2, true);
        bright.animation.play("default");
        bright.setGraphicSize(Std.int(bright.width * 1.5));
        bright.updateHitbox();
        bright.screenCenter(X);
        add(bright);

        btnGroup = new FlxTypedGroup<MoriButton>();
        add(btnGroup);

        for (i in 0...optionShit.length)
        {
            var btn:MoriButton = new MoriButton(0, FlxG.height - 74, 200, 50, optionShit[i]);
            btnGroup.add(btn);
        }
        centerEvenlyX(btnGroup, 350, FlxG.width - 350);

        selector = new FlxSprite().loadGraphic(Paths.image('eggs/o_selector'));
        selector.setGraphicSize(Std.int(selector.width * 1.5));
        selector.updateHitbox();
        add(selector);
        FlxTween.tween(selector.offset, {x: 7}, 0.4, {ease: FlxEase.quadOut, type: PINGPONG});
        
        changeSelection();
        FlxG.mouse.visible = false;
    }

    private function centerEvenlyX(grp:FlxTypedGroup<MoriButton>, top:Float, bottom:Float):Void
	{
		var totalWidth:Float = 0;
        grp.forEach(function(spr:MoriButton)
        {
            totalWidth += spr.width;
        });

		var avWidth:Float = bottom - top;
		var spacing:Float = 0;

		if (grp.members.length > 1)
			spacing = (avWidth - totalWidth) / (grp.members.length - 1);

		var contentHeight:Float = totalWidth + spacing * (grp.members.length - 1);
		var leX:Float = top + (avWidth - contentHeight) * 0.5;

        grp.forEach(function(spr:MoriButton)
        {
            spr.x = leX;
			leX += spr.width + spacing;
        });
	}

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        if (FlxG.keys.anyJustPressed([LEFT, A]))
            changeSelection(-1);
        else if (FlxG.keys.anyJustPressed([RIGHT, D]))
            changeSelection(1);

        if (FlxG.keys.anyJustPressed([Z, ENTER]))
            acceptSelection();

        if (FlxG.keys.justPressed.ESCAPE)
			Sys.exit(0);
    }

    private function changeSelection(change:Int = 0):Void
    {
        curSelected = FlxMath.wrap(curSelected + change, 0, optionShit.length - 1);
        if (change != 0)
            FlxG.sound.play(Paths.sound('o_scroll'));

        selector.setPosition(
            btnGroup.members[curSelected].x - selector.width - 5,
            btnGroup.members[curSelected].getMidpoint().y - selector.height / 2
        );
    }

    private function acceptSelection():Void
    {
        FlxG.sound.play(Paths.sound('o_select'));

        switch (btnGroup.members[curSelected].label.text.toLowerCase())
        {
            case "turni":
                FlxG.mouse.visible = true;
                FlxG.sound.music.stop();
				switchState(new TurnState());
			default:
				Sys.exit(0);
        }
    }
}