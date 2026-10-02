package substates;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.ui.FlxUIButton;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import openfl.events.Event;
import openfl.net.FileReference;
import states.TitleState;
import states.TurnState;

class TurnQuitSubState extends FlxSubState
{
    var curSelected:Int = 0;

    var cursor:FlxSprite;
    var optionBtns:Array<FlxUIButton> = [];
    var optionShit:Array<String> = ["Salva ed esci", "Esci", "Annulla"];

    public function new()
    {
        super();
    }

    override function create()
    {
		var farthestCam:FlxCamera = FlxG.cameras.list[FlxG.cameras.list.length - 1];
        cameras = [farthestCam];
        super.create();

        var alphaBg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
        alphaBg.alpha = 0.5;
        add(alphaBg);

        var bg:FlxSprite = new FlxSprite().makeGraphic(Std.int(FlxG.width / 2), 150, FlxColor.GRAY);
        bg.screenCenter();
        add(bg);

        var sureLabel:FlxText = new FlxText(0, 0, 0 , "Sei sicuro di voler uscire?", 32);
        sureLabel.setFormat(null, 32, FlxColor.WHITE, CENTER, OUTLINE_FAST, FlxColor.BLACK);
        sureLabel.screenCenter();
        sureLabel.y -= 30;
        add(sureLabel);

        for (i in 0...optionShit.length)
        {
            var btn:FlxUIButton = new FlxUIButton(330 + 210 * i, sureLabel.y + 80, optionShit[i], function()
            {
                changeSelection(i, true);
                acceptSelection();
            });
            btn.label.size = 16;
            btn.resize(200, 30);
            btn.ID = i;
            btn.onOver.callback = function()
            {
                changeSelection(i, true);
            };
            add(btn);
            optionBtns.push(btn);
        }

        cursor = new FlxSprite(-100).loadGraphic(Paths.image('finger_small'));
        cursor.setGraphicSize(Std.int(cursor.width * 1.5), Std.int(cursor.height * 1.5));
        cursor.updateHitbox();
        cursor.angle = 90;
        add(cursor);

        changeSelection();
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        handleInput();
    }

    private function handleInput():Void
    {
        if (FlxG.keys.anyJustPressed([LEFT, A]))
            changeSelection(-1);
        else if (FlxG.keys.anyJustPressed([RIGHT, D]))
            changeSelection(1);

        if (FlxG.keys.anyJustPressed([Z, ENTER]))
            acceptSelection();

        if (FlxG.keys.justPressed.ESCAPE)
            close();
    }

    private function changeSelection(change:Int = 0, force:Bool = false):Void
    {
        if (force)
            curSelected = change;
        else
            curSelected = FlxMath.wrap(curSelected + change, 0, optionShit.length - 1);

        for (btn in optionBtns)
        {
            if (btn.ID == curSelected)
            {
                FlxTween.completeTweensOf(cursor, ["x", "y"]);
                FlxTween.tween(cursor, {x: (btn.x + btn.width / 2) - (cursor.width / 2), y: btn.y - cursor.height - 5}, 0.1, {ease: FlxEase.quadOut});
            }
            // cursor.setPosition((btn.x + btn.width / 2) - (cursor.width / 2), btn.y - cursor.height - 5);
            // side // cursor.setPosition(btn.x - cursor.width - 5, btn.getMidpoint().y - cursor.height / 2);
        }
    }

    private function acceptSelection():Void
    {
        switch(optionShit[curSelected].toLowerCase())
        {
            case "salva ed esci":
                var saved:FileReference = cast(_parentState, TurnState).saveToFile();
                saved.addEventListener(Event.SELECT, function(_)
                {
                    switchToTitleState();
                }, false, 0, true);

            case "esci":
                switchToTitleState();

            case "annulla":
                close();
                
        }
    }

    private function switchToTitleState():Void
    {
        cast(_parentState, PandoraState).switchState(new TitleState());
    }
}