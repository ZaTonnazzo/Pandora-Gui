package states;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.ui.FlxInputText;
import flixel.addons.ui.FlxUIButton;
import flixel.addons.ui.FlxUISpriteButton;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.ui.FlxSpriteButton;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxTimer;
import gameObjects.data.TurnPlayer;
import gameObjects.ui.PandoraButton;
import gameObjects.ui.PandoraScrollbar;
import gameObjects.ui.TurnPlayerDraggable;
import openfl.net.FileReference;

using StringTools;

class TurnState extends PandoraState
{
    public var nameField:FlxInputText;
    public var scoreField:FlxInputText;
    public var newPlrBtn:FlxUIButton;
    public var isDragging:Bool = false;
    private final helpStr:String =
        "Tasto destro o Canc mentre trascini un giocatore per eliminarlo.\nF3 per riordinare.\nF2 per salvare in un file di testo.\nF1 per nascondere queste istruzioni.";

    var nomeDesc:String = "Nome: ";
    var scoreDesc:String = "Iniziativa: ";
    var nameLabel:FlxText;
    var scoreLabel:FlxText;
    var helpText:FlxText;
    var randomizerBtn:FlxUISpriteButton;
    var sortBtn:PandoraButton;
    var inputArr:Array<FlxText> = [];
    var plrGroup:FlxTypedGroup<TurnPlayerDraggable>;
    var plrStart:Float = FlxG.height / 2 - 150;

    var transitionCam:FlxCamera; // so that transitions are still nice to watch
    var scrollCam:FlxCamera;
    var scrollbar:PandoraScrollbar;
    var targetScrollY:Float = 0;
    var maxScrollY:Float = 0;
    var viewportHeight:Float;
    var playerHeight:Float = 0;

	override public function create()
	{
		super.create();
		bgColor = 0xFF0f0f1a;

        scrollCam = new FlxCamera(0, plrStart, FlxG.width, FlxG.height);
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

        scrollbar = new PandoraScrollbar(0, 0, FlxG.height - plrStart, 0.1);
        scrollbar.cameras = [scrollCam];
        scrollbar.x = scrollCam.width - scrollbar.bg.width;
        scrollbar.scrollFactor.set(0, 0);
        scrollbar.onScroll = function(v:Float)
        {
            targetScrollY = v * maxScrollY;
        };
        scrollbar.visible = false;
        add(scrollbar);
	}

    private function initCharPart():Void
    {
        var sortLabel:FlxSprite = new FlxSprite().loadGraphic(Paths.image('sort_icon'));
        sortBtn = new PandoraButton(7, plrStart - 33, 30, 30, 0xFF5A5A5A, sortLabel);
        sortBtn.clickCallback = function()
        {
            sortAndPositionPlrs();
        };
        add(sortBtn);
    }

    private function initInputPart():Void
    {
        nameLabel = new FlxText(0, 40, 0, nomeDesc, 16);
        nameLabel.setFormat(null, 16, FlxColor.WHITE, LEFT, OUTLINE_FAST, FlxColor.BLACK);
        add(nameLabel);
        scoreLabel = new FlxText(0, 40, 0, scoreDesc, 16);
        scoreLabel.setFormat(null, 16, FlxColor.WHITE, LEFT, OUTLINE_FAST, FlxColor.BLACK);
        add(scoreLabel);

        nameField = new FlxInputText(0, scoreLabel.y + scoreLabel.height + 5, 200, "", 32, FlxColor.BLACK, FlxColor.WHITE);
        add(nameField);
        inputArr.push(nameField);

        scoreField = new FlxInputText(0, nameField.y, 200, "", 32, FlxColor.BLACK, FlxColor.WHITE);
        add(scoreField);
        inputArr.push(scoreField);

        centerEvenlyX(inputArr, FlxG.width / 4, FlxG.width - FlxG.width / 4);
        
        nameLabel.x = nameField.x;
        scoreLabel.x = scoreField.x;

        newPlrBtn = new FlxUIButton(0, nameField.y + nameField.height + 15, "Aggiungi", addPlr);
        newPlrBtn.label.size = 16;
        newPlrBtn.resize(200, 30);
        newPlrBtn.screenCenter(X);
        add(newPlrBtn);

        var label:FlxSprite = new FlxSprite().loadGraphic(Paths.image('dice_icon'));
        randomizerBtn = new FlxUISpriteButton(scoreField.x + scoreField.width - 20, scoreField.y + scoreField.height, label, function()
        {
            var randomScore:Int = FlxG.random.int(1, 20);
            scoreField.text = (randomScore == 20) ? "20nat" : Std.string(randomScore);
        });
        randomizerBtn.resize(20, 20);
        // randomizerBtn.setAllLabelOffsets(1, 1);
        add(randomizerBtn);

        helpText = new FlxText(0, 0, 0, helpStr, 16);
        helpText.setFormat(null, 16, FlxColor.WHITE, LEFT);
        helpText.setPosition(/*FlxG.width - helpText.width*/ 0, FlxG.height - helpText.height);
        helpText.alpha = 0.5;
        helpText.blend = INVERT;
        helpText.cameras = [transitionCam];
        add(helpText);

        var divider:FlxSprite = new FlxSprite(0, plrStart - 3).makeGraphic(FlxG.width, 3, FlxColor.GRAY);
        // divider.alpha = 0.3;
        add(divider);
    }

    private function centerEvenlyX(arr:Array<FlxText>, top:Float, bottom:Float):Void
	{
		var totalWidth:Float = 0;
        for (txt in arr)
            totalWidth += txt.width;

		var avWidth:Float = bottom - top;
		var spacing:Float = 0;

		if (arr.length > 1)
			spacing = (avWidth - totalWidth) / (arr.length - 1);

		var contentHeight:Float = totalWidth + spacing * (arr.length - 1);
		var leX:Float = top + (avWidth - contentHeight) * 0.5;

        for (txt in arr)
        {
            txt.x = leX;
			leX += txt.width + spacing;
        }
	}

    private function addPlr():Void
    {
        var name:String = nameField.text;
        var score:Null<Int> = Std.parseInt(scoreField.text);
        var onTop:Bool = scoreField.text.toLowerCase().contains("nat");

        var invalid:Bool = false;
        if (score == null || score > 999)
        {
            invalid = true;

            scoreLabel.text = "Iniziativa invalida.";
            scoreLabel.color = FlxColor.RED;
            new FlxTimer().start(1, function(_)
            {
                scoreLabel.text = scoreDesc;
                scoreLabel.color = FlxColor.WHITE;
            });
        }
        if (name == null || name == "")
        {
            invalid = true;
            
            nameLabel.text = "Nome invalido.";
            nameLabel.color = FlxColor.RED;
            new FlxTimer().start(1, function(_)
            {
                nameLabel.text = nomeDesc;
                nameLabel.color = FlxColor.WHITE;
            });
        }

        if (invalid)
            return;

        if (onTop)
            onTop = (score >= 20);

        var plr:TurnPlayer = new TurnPlayer(name, score);
        plr.setNat(onTop);
        resetFields();

        var draggable:TurnPlayerDraggable = new TurnPlayerDraggable(0, 0, plr, Y);
        // draggable.minDrag = new FlxPoint(0, plrStart - 40);
        // draggable.maxDrag = new FlxPoint(FlxG.width, FlxG.height - draggable.height);
        draggable.cameras = [scrollCam];
        draggable.screenCenter(X);
        plrGroup.add(draggable);
        draggable.dragCallback = function()
        {
            isDragging = true;
            plrGroup.forEach(function(tpd:TurnPlayerDraggable)
            {
                if (tpd != draggable)
                    tpd.canDrag = false;
            });
            putOnTop(draggable);
        };
        draggable.undragCallback = function()
        {
            isDragging = false;
            draggable.canDrag = false;
            plrGroup.sort((Order, Obj1, Obj2) ->
			{
				return FlxSort.byY(Order, Obj1, Obj2);
			});
            positionPlrs();

            plrGroup.forEach(function(tpd:TurnPlayerDraggable)
            {
                tpd.canDrag = true;
            });
        };
        draggable.deleteCallback = function()
        {
            plrGroup.remove(draggable, true);
            updateScrollBounds();
        };

        sortAndPositionPlrs();
        updateScrollBounds();

        /*
        var result:String = "";
        for (p in plrArr)
        {
            if (result == "")
                result += "[" + p.name + " | " + p.score + "]";
            else
                result += (", " + "[" + p.name + " | " + p.score + "]");
        }
        trace(result);
        */
    }

    private function sortAndPositionPlrs():Void
    {
        sortByIniziativa();
        positionPlrs();
    }

    private function sortByIniziativa():Void
    {
        plrGroup.sort(function (i:Int, x:TurnPlayerDraggable, y:TurnPlayerDraggable)
        {
            if (x.player.getNat() && y.player.getNat() == false)
                return -1;
            else if (y.player.getNat() && x.player.getNat() == false)
                return 1;

            if (x.player.score < y.player.score)
                return 1;
            else if (x.player.score > y.player.score)
                return -1;

            return 0;
        });
    }

    private function parseScore():Null<Int>
    {
        try {
            var result = MathParser.evaluate(scoreField.text);

            /*
            if (result == Std.int(result))
                scoreField.text = Std.string(Std.int(result));
            else
                scoreField.text = Std.string(result);
            */

            return Std.int(result);
        } catch (e:Dynamic) {
            scoreLabel.text = "Errore di calcolo";
            return null;
        }
    }

    private function resetFields():Void
    {
        nameField.text = "";
        nameField.hasFocus = false;
        scoreField.text = "";
        scoreField.hasFocus = false;
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
        plrGroup.sort(function (i:Int, x:TurnPlayerDraggable, y:TurnPlayerDraggable)
        {
            if (x == tpd)
                return 1;
            else if (y == tpd)
                return -1;

            return 0;
        });
    }

    private function updateScrollBounds():Void
    {
        if (playerHeight == 0 && plrGroup.members.length > 0)
            playerHeight = plrGroup.members[0].height;

        viewportHeight = FlxG.height - plrStart;
        var contentHeight:Float = plrGroup.members.length * playerHeight;
        var ratio:Float = contentHeight > 0 ? Math.min(1, viewportHeight / contentHeight) : 1;
        scrollbar.setBarRatio(ratio);

        maxScrollY = Math.max(0, contentHeight - viewportHeight);

        scrollbar.canScroll = maxScrollY > 0;
        scrollbar.visible = maxScrollY > 0;

        targetScrollY = FlxMath.bound(targetScrollY, 0, maxScrollY);
    }

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

        if (isDragging)
        {
            newPlrBtn.active = false;
            randomizerBtn.active = false;
        }
        else
        {
            newPlrBtn.active = true;
            randomizerBtn.active = true;
        }

        handleInput();
        
        scrollCam.scroll.y = FlxMath.lerp(scrollCam.scroll.y, targetScrollY, 0.15);
        scrollCam.scroll.y = FlxMath.bound(scrollCam.scroll.y, 0, maxScrollY);
	}

    private function handleInput():Void
    {
        if (transitioning)
            return;

        if (FlxG.keys.anyJustPressed([ENTER]))
            addPlr();

        if (FlxG.keys.justPressed.F3)
            sortAndPositionPlrs();

        if (FlxG.keys.justPressed.F2)
            saveToFile();

        if (FlxG.keys.justPressed.F1)
            helpText.visible = !helpText.visible;

        if (FlxG.keys.justPressed.ESCAPE)
            switchState(new TitleState());

        /*
        if (FlxG.mouse.wheel != 0)
        {
            var scrollSpeed:Float = 20;
            var newY:Float = scrollCam.scroll.y - (FlxG.mouse.wheel * scrollSpeed);

            newY = Math.max(0, Math.min(FlxG.height, newY));

            scrollCam.scroll.y = newY;
        }
        */
    }

    private function saveToFile():Void
    {
        var data:String = "";
        plrGroup.forEach(function(x:TurnPlayerDraggable)
        {
            var plr:TurnPlayer = x.player;
            data += "- " + plr.name + ", " + plr.score + ((plr.getNat()) ? "nat" : "") + "\n";
        });

        var _file = new FileReference();
		_file.save(data, "turni.txt");
    }
}
