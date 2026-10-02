package substates;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.ui.FlxUIButton;
import flixel.math.FlxPoint;
import flixel.text.FlxInputText;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import gameObjects.data.TurnPlayer;
import gameObjects.ui.TurnPlayerDraggable;
import gameObjects.ui.TurnPlayerEditable;
import hscript.Expr;
import hscript.Interp;
import hscript.Parser;
import states.TurnState;

using StringTools;

class EditTurnPlayerSubState extends FlxSubState
{
    var parentButton:TurnPlayerDraggable;
    var parentPlr:TurnPlayer;
    var editable:TurnPlayerEditable;
    
    var parser:Parser = new Parser();
    var interp:Interp = new Interp();

    public function new(parentButton:TurnPlayerDraggable)
    {
        this.parentButton = parentButton;
        parentPlr = parentButton.player;
        super();
    }

    override public function create()
    {
        cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
        super.create();

        var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
        bg.alpha = 0.5;
        add(bg);

        editable = new TurnPlayerEditable(0, 0, parentPlr);
        editable.screenCenter();
        add(editable);

        // parentButton.canDrag = false;
        // add(parentButton);
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        if (FlxG.keys.justPressed.ENTER)
            acceptEdit();

        if (FlxG.keys.justPressed.ESCAPE)
            close();
    }

    private function evaluateInputInt(input:String):Null<Int>
    {
        try
        {
            var result:Dynamic = interp.execute(parser.parseString(input));
            if (Std.isOfType(result, Float))
                return Std.int(result);
        }
        catch (e)
        {
            trace("Invalid expression: " + e);
        }

        return Std.parseInt(input);
    }

    private function checkField(valid:Bool, index:Int, msg:String = "Invalido."):Bool
    {
        if (!valid)
            editable.showError(index, msg);
        return valid;
    }

    private function acceptEdit():Void
    {
        var name = editable.fields[0].text.trim();
        var score:Null<Int> = Std.parseInt(editable.fields[1].text.trim());
        var hp:Null<Int> = evaluateInputInt(editable.fields[2].text.trim());
        var ac:Null<Int> = evaluateInputInt(editable.fields[3].text.trim());

        var results = [
            checkField(name != "", 0),
            checkField(score != null && score <= TurnState.MAX_SCORE, 1, "Invalido (max " + TurnState.MAX_SCORE + ")"),
            checkField(hp != null, 2),
            checkField(ac != null, 3)
        ];
        if (results.contains(false))
            return;

        parentPlr.name = name;
        parentPlr.score = score;
        parentPlr.hp = hp;
        parentPlr.ac = ac;
        parentPlr.setNat(editable.fields[1].text.trim().contains("nat"));

        parentButton.refresh(TurnPlayerDraggable.defaultFields());
        close();
    }
}