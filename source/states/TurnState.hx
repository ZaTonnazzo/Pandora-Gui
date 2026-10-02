package states;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.ui.FlxUIButton;
import flixel.addons.ui.FlxUISpriteButton;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxInputText;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxTimer;
import gameObjects.data.TurnPlayer;
import gameObjects.ui.PandoraButton;
import gameObjects.ui.PandoraScrollbar;
import gameObjects.ui.TurnPlayerDraggable;
import hscript.Interp;
import hscript.Parser;
import openfl.Assets;
import openfl.display.Loader;
import openfl.display.LoaderInfo;
import openfl.events.Event;
import openfl.net.FileFilter;
import openfl.net.FileReference;
import substates.EditTurnPlayerSubState;
import substates.TurnQuitSubState;

using StringTools;

class TurnState extends PandoraState
{
    public var nameField:FlxInputText;
    public var scoreField:FlxInputText;
    public var hpField:FlxInputText;
    public var acField:FlxInputText;
    public var newPlrBtn:FlxUIButton;
    public var isDragging:Bool = false;

    private static inline final NAME_DESC:String = "Nome: ";
    private static inline final SCORE_DESC:String = "Iniziativa: ";
    private static inline final HP_DESC:String = "Punti ferita: ";
    private static inline final AC_DESC:String = "Classe armatura: ";
    private static inline final MAX_SCORE:Int = 999;
    private static inline var SCROLL_SMOOTHING:Float = 10;

    private final helpStr:String = "Tasto destro o Canc mentre trascini un giocatore per eliminarlo.\n"
        + "F3 per riordinare.\nF2 per salvare in un file di testo.\nF1 per nascondere queste istruzioni.";

    var nameLabel:FlxText;
    var scoreLabel:FlxText;
    var hpLabel:FlxText;
    var acLabel:FlxText;
    var helpText:FlxText;
    var randomizerBtn:FlxUISpriteButton;
    var loadBtn:PandoraButton;
    var saveBtn:PandoraButton;
    var sortBtn:PandoraButton;
    var inputArr:Array<FlxInputText> = [];
    var plrGroup:FlxTypedGroup<TurnPlayerDraggable>;
    var plrStart:Float = FlxG.height / 2 - 150;

    var transitionCam:FlxCamera; // so that transitions are still nice to watch
    var scrollCam:FlxCamera;
    var scrollbar:PandoraScrollbar;
    var targetScrollY:Float = 0;
    var maxScrollY:Float = 0;
    var viewportHeight:Float = 0;
    var playerHeight:Float = 0;

    var parser:Parser = new Parser();
    var interp:Interp = new Interp();
    var flashTimers:Map<FlxText, FlxTimer> = new Map();

    override public function create()
    {
        super.create();
        bgColor = 0xFF0f0f1a;

        viewportHeight = FlxG.height - plrStart;

        scrollCam = new FlxCamera(0, Std.int(plrStart), FlxG.width, Std.int(viewportHeight));
        scrollCam.bgColor = 0xff303053;
        transitionCam = new FlxCamera();
        transitionCam.bgColor = FlxColor.TRANSPARENT;
        FlxG.cameras.add(scrollCam, false);
        FlxG.cameras.add(transitionCam, false);

        initInputPart();
        initCharPart();

        plrGroup = new FlxTypedGroup<TurnPlayerDraggable>();
        plrGroup.cameras = [scrollCam];
        add(plrGroup);

        scrollbar = new PandoraScrollbar(0, 0, viewportHeight, 0.1);
        scrollbar.cameras = [scrollCam];
        scrollbar.x = scrollCam.width - scrollbar.bg.width;
        scrollbar.scrollFactor.set(0, 0);
        scrollbar.onScroll = function(v:Float) targetScrollY = v * maxScrollY;
        scrollbar.visible = false;
        add(scrollbar);
    }

    private function initCharPart():Void
    {
        var sortLabel:FlxSprite = new FlxSprite().loadGraphic(Paths.image('sort_icon'));
        sortBtn = new PandoraButton(7, plrStart - 33, 30, 30, 0xFF5A5A5A, sortLabel);
        sortBtn.clickCallback = sortAndPositionPlrs;
        add(sortBtn);

        var saveLabel:FlxSprite = new FlxSprite().loadGraphic(Paths.image('download_icon'));
        saveBtn = new PandoraButton(sortBtn.x + sortBtn.width + 5, sortBtn.y, 30, 30, 0xFF5A5A5A, saveLabel);
        saveBtn.clickCallback = function()
        {
            if (plrGroup.length > 0)
                saveToFile();
        };
        add(saveBtn);

        var loadLabel:FlxSprite = new FlxSprite().loadGraphic(Paths.image('upload_icon'));
        loadBtn = new PandoraButton(saveBtn.x + saveBtn.width + 5, sortBtn.y, 30, 30, 0xFF5A5A5A, loadLabel);
        loadBtn.clickCallback = loadFile;
        add(loadBtn);
    }

    private function addLabeledInput(desc:String):{label:FlxText, field:FlxInputText}
    {
        var txtLabel:FlxText = new FlxText(0, 40, 0, desc, 16);
        txtLabel.setFormat(null, 16, FlxColor.WHITE, LEFT, OUTLINE_FAST, FlxColor.BLACK);
        add(txtLabel);

        var txtField:FlxInputText = new FlxInputText(0, txtLabel.y + txtLabel.height + 5, 200, "", 32, FlxColor.BLACK, FlxColor.WHITE);
        add(txtField);
        inputArr.push(txtField);

        return {label: txtLabel, field: txtField};
    }

    private function initInputPart():Void
    {
        var name = addLabeledInput(NAME_DESC);
        var score = addLabeledInput(SCORE_DESC);
        var hp = addLabeledInput(HP_DESC);
        var ac = addLabeledInput(AC_DESC);

        nameLabel = name.label;
        nameField = name.field;
        scoreLabel = score.label;
        scoreField = score.field;
        hpLabel = hp.label;
        hpField = hp.field;
        acLabel = ac.label;
        acField = ac.field;

        centerEvenlyX(inputArr, FlxG.width / 8, FlxG.width - FlxG.width / 8);

        for (pair in [name, score, hp, ac])
            pair.label.x = pair.field.x;

        newPlrBtn = new FlxUIButton(0, nameField.y + nameField.height + 45, "Aggiungi", addPlr);
        newPlrBtn.label.size = 16;
        newPlrBtn.resize(200, 30);
        newPlrBtn.screenCenter(X);
        add(newPlrBtn);

        var diceLabel = new FlxSprite().loadGraphic(Paths.image('dice_icon'));
        randomizerBtn = new FlxUISpriteButton(scoreField.x + scoreField.width - 20, scoreField.y + scoreField.height, diceLabel, d20InScore);
        randomizerBtn.resize(20, 20);
        add(randomizerBtn);

        helpText = new FlxText(0, 0, 0, helpStr, 16);
        helpText.setFormat(null, 16, FlxColor.WHITE, LEFT);
        helpText.setPosition(0, FlxG.height - helpText.height);
        helpText.alpha = 0.5;
        helpText.blend = INVERT;
        helpText.cameras = [transitionCam];
        add(helpText);

        var divider:FlxSprite = new FlxSprite(0, plrStart - 3).makeGraphic(FlxG.width, 3, FlxColor.GRAY);
        add(divider);
    }

    private function d20InScore():Void
    {
        var roll:Int = FlxG.random.int(1, 20);
        scoreField.text = (roll == 20) ? "20nat" : Std.string(roll);
    }

    private function centerEvenlyX(arr:Array<FlxInputText>, left:Float, right:Float):Void
    {
        var totalWidth:Float = 0;
        for (txt in arr)
            totalWidth += txt.width;

        var spacing:Float = arr.length > 1 ? (right - left - totalWidth) / (arr.length - 1) : 0;
        var x:Float = left;
        for (txt in arr)
        {
            txt.x = x;
            x += txt.width + spacing;
        }
    }

    private function checkField(cond:Bool, label:FlxText, msg:String, normal:String):Bool
    {
        if (cond)
            return true;

        var old = flashTimers.get(label);
        if (old != null)
            old.cancel();

        label.text = msg;
        label.color = FlxColor.RED;
        flashTimers.set(label, new FlxTimer().start(1, function(_)
        {
            label.text = normal;
            label.color = FlxColor.WHITE;
        }));
        return false;
    }

    private function addPlr():Void
    {
        var name = nameField.text.trim();
        var scoreText = scoreField.text.toLowerCase();
        var score:Null<Int> = Std.parseInt(scoreText);
        var hp:Null<Int> = evaluateInputInt(hpField.text);
        var ac:Null<Int> = evaluateInputInt(acField.text);

        var results = [
            checkField(score != null && score <= MAX_SCORE, scoreLabel, "Iniziativa invalida.", SCORE_DESC),
            checkField(name != "", nameLabel, "Nome invalido.", NAME_DESC),
            checkField(hp != null, hpLabel, "PF invalidi.", HP_DESC),
            checkField(ac != null, acLabel, "CA invalida.", AC_DESC)
        ];
        if (results.contains(false))
            return;

        var plr = new TurnPlayer(name, score, hp, Std.int(Math.max(0, ac)));
        plr.setNat(scoreText.contains("nat") && score >= 20);
        resetFields();

        plrGroup.add(createDraggable(plr));
        sortAndPositionPlrs();
    }

    private function addPlrFromObject(plr:TurnPlayer):Void
    {
        var results = [
            plr.score <= MAX_SCORE,
            plr.name != ""
        ];
        if (results.contains(false))
            return;

        plrGroup.add(createDraggable(plr));
        sortAndPositionPlrs();
    }

    private function createDraggable(plr:TurnPlayer):TurnPlayerDraggable
    {
        var draggable = new TurnPlayerDraggable(0, 0, plr, Y);
        draggable.cameras = [scrollCam];
        draggable.screenCenter(X);

        draggable.dragCallback = function()
        {
            isDragging = true;
            setOthersDraggable(draggable, false);
            putOnTop(draggable);
        };
        draggable.undragCallback = function()
        {
            isDragging = false;
            plrGroup.sort((order, a, b) -> FlxSort.byY(order, a, b));
            positionPlrs();
            setOthersDraggable(draggable, true);
            draggable.canDrag = true;
        };
        draggable.deleteCallback = function()
        {
            plrGroup.remove(draggable, true);
            positionPlrs();
            updateScrollBounds();
        };
        draggable.doubleClickCallback = function()
        {
            openSubState(new EditTurnPlayerSubState(draggable, [for (inp in inputArr) inp.getPosition()]));
        };

        return draggable;
    }

    private function setOthersDraggable(except:TurnPlayerDraggable, value:Bool):Void
    {
        for (tpd in plrGroup)
        {
            if (tpd != except)
                tpd.canDrag = value;
        }
    }

    private function sortAndPositionPlrs():Void
    {
        sortByIniziativa();
        positionPlrs();
        updateScrollBounds();
    }

    private function sortByIniziativa():Void
    {
        plrGroup.sort(function (_, x:TurnPlayerDraggable, y:TurnPlayerDraggable)
        {
            if (x.player.getNat() != y.player.getNat())
                return x.player.getNat() ? -1 : 1;
            return y.player.score - x.player.score;
        });
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

    private function resetFields():Void
    {
        for (txt in inputArr)
        {
            txt.text = "";
            txt.endFocus();
        }
    }

    private function positionPlrs():Void
    {
        for (i in 0...plrGroup.members.length)
        {
            var plr = plrGroup.members[i];
            plr.y = plr.height * i;
        }
    }

    private function putOnTop(tpd:TurnPlayerDraggable):Void
    {
        plrGroup.sort(function (_, x:TurnPlayerDraggable, y:TurnPlayerDraggable)
        {
            if (x == tpd)
                return 1;
            if (y == tpd)
                return -1;
            
            return 0;
        });
    }

    private function updateScrollBounds():Void
    {
        if (playerHeight == 0 && plrGroup.members.length > 0)
            playerHeight = plrGroup.members[0].height;

        var contentHeight:Float = plrGroup.members.length * playerHeight;
        scrollbar.setBarRatio(contentHeight > 0 ? Math.min(1, viewportHeight / contentHeight) : 1);

        maxScrollY = Math.max(0, contentHeight - viewportHeight);

        scrollbar.canScroll = maxScrollY > 0;
        scrollbar.visible = maxScrollY > 0;

        targetScrollY = FlxMath.bound(targetScrollY, 0, maxScrollY);
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        newPlrBtn.active = !isDragging;
        randomizerBtn.active = !isDragging;

        handleInput();

        scrollCam.scroll.y = FlxMath.lerp(scrollCam.scroll.y, targetScrollY, 0.15);
        scrollCam.scroll.y = FlxMath.bound(scrollCam.scroll.y, 0, maxScrollY);
    }

    private function handleInput():Void
    {
        if (transitioning)
            return;

        if (FlxG.keys.justPressed.ENTER)
            addPlr();
        if (FlxG.keys.justPressed.F3 && plrGroup.length > 0)
            saveToFile();
        if (FlxG.keys.justPressed.F2)
            sortAndPositionPlrs();
        if (FlxG.keys.justPressed.F1)
            helpText.visible = !helpText.visible;

        if (FlxG.keys.justPressed.ESCAPE)
        {
            #if !debug
            if (plrGroup.length > 0)
                openSubState(new TurnQuitSubState());
            else
                switchState(new TitleState());
            #else
            openSubState(new TurnQuitSubState());
            #end
        }
    }

    public function saveToFile():Void
    {
        var lines:Array<String> = [];
        plrGroup.forEach(function(x:TurnPlayerDraggable)
        {
            var p:TurnPlayer = x.player;
            lines.push('-${p.name}, ${p.score}${p.getNat() ? "nat" : ""}, PF: ${p.hp}, CA: ${p.ac}');
        });

        new FileReference().save(lines.join("\n") + "\n", "turni.pandorapl");
    }

    public function loadFile():Void
    {
        var fr:FileReference = new FileReference();
		fr.addEventListener(Event.SELECT, _onSelect, false, 0, true);
		fr.addEventListener(Event.CANCEL, _onCancel, false, 0, true);
		var filters:Array<FileFilter> = new Array<FileFilter>();
		filters.push(new FileFilter("Pandora Player List", "*.pandorapl"));
		fr.browse(filters);
    }

    function _onSelect(E:Event):Void
	{
		var fr:FileReference = cast(E.target, FileReference);
		fr.addEventListener(Event.COMPLETE, _onLoad, false, 0, true);
		fr.load();
	}

	function _onLoad(E:Event):Void
	{
		var fr:FileReference = cast E.target;
		fr.removeEventListener(Event.COMPLETE, _onLoad);
        
        var loadedData:Array<String> = fr.data.toString().replace("\n", "").split("-");
        loadedData.shift();

        var loadedPlrs:Array<TurnPlayer> = [];
        for (i in 0...loadedData.length)
        {
            var str:String = loadedData[i].replace("PF: ", "").replace("CA: ", "");
            var plrData:Array<String> = str.split(", ");
            loadedPlrs[i] = new TurnPlayer(plrData[0].trim(), Std.parseInt(plrData[1]), Std.parseInt(plrData[2]), Std.parseInt(plrData[3]));
        }

        for (plr in loadedPlrs)
        {
            addPlrFromObject(plr);
        }
	}

    function _onCancel(_):Void
	{
		trace("cancelled");
	}
}