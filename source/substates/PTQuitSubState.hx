package substates;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import gameObjects.ui.Pizzabeth;

class PTQuitSubState extends FlxSubState
{
    var curSelected:Int = 0;
    var choices:FlxTypedGroup<Pizzabeth>;

    public function new()
	{
		super();
	}

    override function create()
	{
		super.create();
        cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];

        var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
        bg.alpha = 0.5;
        add(bg);

        final txtSize:Float = 1.3;
        var leafing:Pizzabeth = new Pizzabeth(0, 0, "VUOI USCIRE DAL GIOCO?");
        leafing.size = txtSize;
        leafing.screenCenter();
		leafing.y -= 90;
		add(leafing);

        choices = new FlxTypedGroup<Pizzabeth>();
        add(choices);

        var yes:Pizzabeth = new Pizzabeth(0, 0, "SI");
        yes.size = txtSize;
        yes.screenCenter(Y);
        yes.x = FlxG.width / 2 - 100 - 23;
		yes.y -= 10;
        yes.ID = 0;
        yes.alpha = 0.5;
        choices.add(yes);

        var no:Pizzabeth = new Pizzabeth(0, 0, "NO");
        no.size = txtSize;
        no.screenCenter(Y);
        no.x = FlxG.width / 2 + 100 - 23;
		no.y -= 10;
        no.ID = 1;
        no.alpha = 0.5;
        choices.add(no);

        var bye1:FlxSprite = new FlxSprite();
        bye1.frames = Paths.getAtlasFrames('eggs/PT/hud/bye');
        bye1.animation.addByPrefix("default", "bye", 4, true);
        bye1.animation.play("default");
        bye1.setPosition(
            yes.x - bye1.width - 10,
            yes.y + 10
        );
        add(bye1);

        var bye2:FlxSprite = new FlxSprite();
        bye2.frames = Paths.getAtlasFrames('eggs/PT/hud/bye');
        bye2.animation.addByPrefix("default", "bye", 4, true);
        bye2.animation.play("default");
        bye2.setPosition(
            no.x + no.width + 10,
            no.y + 10
        );
        add(bye2);

        changeSelection();
    }

    override public function update(elapsed:Float)
	{
		super.update(elapsed);

        if (FlxG.keys.justPressed.LEFT)
            changeSelection(-1);
        else if (FlxG.keys.justPressed.RIGHT)
            changeSelection(1);

        if (FlxG.keys.anyJustPressed([ENTER, Z, SPACE]))
            acceptSelection();
    }

    private function changeSelection(change:Int = 0):Void
    {
        curSelected = FlxMath.wrap(curSelected + change, 0, choices.length - 1);

        for (txt in choices)
        {
            if (txt.ID == curSelected)
                txt.alpha = 1;
            else
                txt.alpha = 0.5;
        }
    }

    private function acceptSelection():Void
    {
        switch(choices.members[curSelected].text.toLowerCase())
        {
            case "si":
                Sys.exit(0);
            default:
                close();
        }
    }
}