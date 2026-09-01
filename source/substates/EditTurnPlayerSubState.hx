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
import hscript.Expr;
import hscript.Interp;
import hscript.Parser;

using StringTools;

class EditTurnPlayerSubState extends FlxSubState
{
    var parentButton:TurnPlayerDraggable;
    var fieldPos:Array<FlxPoint>;
    var inputFields:Array<{key:String, input:FlxInputText}>;
    var labelArr:Array<FlxText> = [];
    
    var parser:Parser = new Parser();
    var interp:Interp = new Interp();

    public function new(parentButton:TurnPlayerDraggable, fieldPos:Array<FlxPoint>)
    {
        this.parentButton = parentButton;
        this.fieldPos = fieldPos;
        super();
    }

    override public function create()
    {
        cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
        super.create();

        var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
        bg.alpha = 0.5;
        add(bg);

        //parentButton.canDrag = false;
        //add(parentButton);

        inputFields = [];

        var btnFields = getButtonFields();
        var i:Int = 0;
        for (field in btnFields)
        {
            var baseInput:String = Std.string(field.value);
            if (field.key.toLowerCase().contains("iniziativa") && parentButton.player.getNat())
                baseInput += "nat";

            var inputTxt:FlxInputText = new FlxInputText(
                fieldPos[i].x,
                fieldPos[i].y,
                200,
                baseInput,
                32
            );
            add(inputTxt);
            inputFields.push({ key: field.key, input: inputTxt });

            var labelTxt:FlxText = new FlxText(inputTxt.x, inputTxt.y - 28, 0, field.key, 16);
            labelTxt.setFormat(null, 16, FlxColor.WHITE, LEFT, OUTLINE_FAST, FlxColor.BLACK);
            add(labelTxt);
            labelArr.push(labelTxt);

            i++;
        }

        var editBtn:FlxUIButton = new FlxUIButton(0, 158, "Modifica", acceptEdit);
        editBtn.label.size = 16;
        editBtn.resize(200, 30);
        editBtn.screenCenter(X);
        add(editBtn);
    }

    private function getButtonFields():Array<{key:String, value:Dynamic}>
    {
        var plr:TurnPlayer = parentButton.player;
        return [
            { key: "Nome: ", value: plr.name },
            { key: "Iniziativa: ", value: plr.score },
            { key: "Punti ferita: ", value: plr.hp },
            { key: "Classe armatura: ", value: plr.ac }
        ];
    }

    private function isValid():Bool
    {
        var name:String = inputFields[0].input.text;
        var score:Null<Int> = Std.parseInt(inputFields[1].input.text);
        // var onTop:Bool = inputFields[1].input.text.toLowerCase().contains("nat");
        var hp:Null<Int> = evaluateInputInt(inputFields[2].input.text);
        var ac:Null<Int> = evaluateInputInt(inputFields[3].input.text);

        var invalid:Bool = false;
        if (score == null || score > 999)
        {
            invalid = true;

            labelArr[1].text = "Iniziativa invalida.";
            labelArr[1].color = FlxColor.RED;
            new FlxTimer().start(1, function(_)
            {
                labelArr[1].text = inputFields[1].key;
                labelArr[1].color = FlxColor.WHITE;
            });
        }
        if (name == null || name == "")
        {
            invalid = true;
            
            labelArr[0].text = "Nome invalido.";
            labelArr[0].color = FlxColor.RED;
            new FlxTimer().start(1, function(_)
            {
                labelArr[0].text = inputFields[0].key;
                labelArr[0].color = FlxColor.WHITE;
            });
        }
        if (hp == null)
        {
            invalid = true;

            labelArr[2].text = "PF invalidi.";
            labelArr[2].color = FlxColor.RED;
            new FlxTimer().start(1, function(_)
            {
                labelArr[2].text = inputFields[2].key;
                labelArr[2].color = FlxColor.WHITE;
            });
        }
        if (ac == null)
        {
            invalid = true;

            labelArr[3].text = "CA invalida.";
            labelArr[3].color = FlxColor.RED;
            new FlxTimer().start(1, function(_)
            {
                labelArr[3].text = inputFields[3].key;
                labelArr[3].color = FlxColor.WHITE;
            });
        }

        if (invalid)
            return false;

        return true;
    }

    private function evaluateInputInt(input:String):Null<Int>
    {
        try
        {
            var result = interp.execute(parser.parseString(input));
            return result;
        }
        catch (e)
        {
            trace("Invalid expression: " + e);
            return Std.parseInt(input);
        }
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        if (FlxG.keys.justPressed.ENTER)
            acceptEdit();

        if (FlxG.keys.justPressed.ESCAPE)
            close();
    }

    private function acceptEdit():Void
    {
        if (!isValid())
            return;

        var plr:TurnPlayer = parentButton.player;

        for (f in inputFields)
        {
            var text:String = f.input.text;

            switch (f.key)
            {
                case "Nome: ":
                    plr.name = text;
                case "Iniziativa: ":
                    plr.score = Std.parseInt(text);
                    if (text.toLowerCase().contains("nat"))
                        plr.setNat(true);
                    else
                        plr.setNat(false);
                case "Punti ferita: ":
                    plr.hp = evaluateInputInt(text);
                case "Classe armatura: ":
                    var newAc = evaluateInputInt(text);
                    if (newAc < 0)
                        newAc = 0;
                    plr.ac = newAc;
            }
        }
        parentButton.refresh(TurnPlayerDraggable.defaultFields());

        close();
    }
}