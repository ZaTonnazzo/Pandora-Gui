package states;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import gameObjects.ui.FileFrame;

class DeltaTitleState extends PandoraState
{
    private var curSelected:Int = 0;
    private var curChoice:Int = 0;
    private var fileSelected:Bool = false;

    var selector:FlxSprite;
	var fileGroup:FlxTypedGroup<FileFrame>;
	var optionShit:Array<String> = ["TURNI", "ESCI"];

    override public function create()
    {
        super.create();

        fileGroup = new FlxTypedGroup<FileFrame>();
        add(fileGroup);

        for(i in 0...optionShit.length)
        {
            var fileBtn:FileFrame = new FileFrame();
            fileBtn.screenCenter(X);
            fileBtn.creatorText.text = optionShit[i];
            fileGroup.add(fileBtn);
        }

        centerEvenlyY(fileGroup, FlxG.height / 2 - 100, FlxG.height / 2 + 100);

        selector = new FlxSprite().loadGraphic(Paths.image('heart_small'));
        selector.setGraphicSize(Std.int(selector.width * 2));
        selector.updateHitbox();
        add(selector);

        var pleaseTxt:FlxText = new FlxText(0, fileGroup.members[0].y - 50, 0, "Selezionare un'opzione.", 16);
        pleaseTxt.setFormat(Paths.fontTTF('determination'), 16, FlxColor.LIME, CENTER, SHADOW, FlxColor.BLACK);
        pleaseTxt.shadowOffset.set(2, 2);
        pleaseTxt.setGraphicSize(Std.int(pleaseTxt.width * 1.7));
        pleaseTxt.updateHitbox();
        pleaseTxt.screenCenter(X);
        add(pleaseTxt);

        changeSelection(0, true);
    }

    private function centerEvenlyY(grp:FlxTypedGroup<FileFrame>, top:Float, bottom:Float):Void
	{
		var totalHeight:Float = 0;
		grp.forEach(function(txt:FlxObject)
		{
			totalHeight += txt.height;
		});

		var avHeight:Float = bottom - top;
		var spacing:Float = 0;

		if (grp.members.length > 1)
			spacing = (avHeight - totalHeight) / (grp.members.length - 1);

		var contentHeight:Float = totalHeight + spacing * (grp.members.length - 1);
		var leY:Float = top + (avHeight - contentHeight) * 0.5;

		grp.forEach(function(txt:FlxObject)
		{
			txt.y = leY;
			leY += txt.height + spacing;
		});
	}

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        if (FlxG.keys.anyJustPressed([W, UP]))
            changeSelection(-1);
        else if (FlxG.keys.anyJustPressed([S, DOWN]))
            changeSelection(1);
        if (FlxG.keys.anyJustPressed([A, LEFT]))
            changeChoice(-1);
        else if (FlxG.keys.anyJustPressed([D, RIGHT]))
            changeChoice(1);

        if (FlxG.keys.anyJustPressed([Z, SPACE, ENTER]))
            acceptSelection();
        else if (FlxG.keys.anyJustPressed([X, SHIFT, BACKSPACE]))
            cancelSelection();

        if (FlxG.keys.justPressed.ESCAPE)
            Sys.exit(0);
    }

    private function changeSelection(change:Int = 0, snap:Bool = false):Void
    {
        if (fileSelected)
            return;

        curSelected = FlxMath.wrap(curSelected + change, 0, fileGroup.members.length - 1);
        if (change != 0)
            FlxG.sound.play(Paths.sound('dt_scroll'));

        var leSelected = fileGroup.members[curSelected];
        fileGroup.forEach(function(spr:FileFrame)
        {
            if (spr == leSelected)
            {
                spr.hover();
            }
            else
            {
                if (spr.hovered)
                    spr.unhover();
            }
        });

        var selX:Float = leSelected.creatorText.x - 27;
        var selY:Float = leSelected.box.getMidpoint().y - selector.height / 2;
        FlxTween.cancelTweensOf(selector);
        if (!snap)
            FlxTween.tween(selector, {x: selX, y: selY}, 0.1, {ease: FlxEase.quadOut});
        else
            selector.setPosition(selX, selY);
    }

    private function changeChoice(change:Int = 0):Void
    {
        if (!fileSelected)
            return;

        var curFile = fileGroup.members[curSelected];
        curChoice = FlxMath.wrap(curChoice + change, 0, curFile.choiceTxts.length - 1);
        if (change != 0)
            FlxG.sound.play(Paths.sound('dt_scroll'));

        var leSelected = curFile.choiceTxts[curChoice];
        for (txt in curFile.choiceTxts)
        {
            if (txt == leSelected)
                txt.color = FlxColor.LIME;
            else
                txt.color = FlxColor.fromRGB(0, 127, 14);
        }

        var selX:Float = leSelected.x - selector.width - 5;
        var selY:Float = leSelected.getMidpoint().y - selector.height / 2;
        FlxTween.cancelTweensOf(selector);
        FlxTween.tween(selector, {x: selX, y: selY}, 0.1, {ease: FlxEase.quadOut});
    }

    private function acceptSelection():Void
    {
        if (transitioning)
            return;

        FlxG.sound.play(Paths.sound('dt_select'));

        var curFile = fileGroup.members[curSelected];
        switch (fileSelected)
        {
            case true:
                var curChosen = curFile.choiceTxts[curChoice];
                switch (curChosen.text.toLowerCase())
                {
                    case "esegui":
                        FlxG.mouse.visible = true;
                        FlxG.sound.music.stop();
                        switch (curFile.creatorText.text.toLowerCase())
                        {
                            case "turni":
                                switchState(new TurnState());
                            case "esci":
                                Sys.exit(0);
                            default:
                                // nan
                        }
                    default:
                        cancelSelection();
                }
            default:
                if (!curFile.selected)
                {
                    fileSelected = true;
                    curFile.select();
                    changeChoice();
                }
        }
    }

    private function cancelSelection():Void
    {
        if (!fileSelected)
            return;

        FlxG.sound.play(Paths.sound('dt_cancel'));

        fileSelected = false;
        fileGroup.members[curSelected].unselect();
        changeSelection();
        curChoice = 0;
    }
}