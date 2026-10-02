package states;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.sound.FlxSound;
import flixel.system.scaleModes.PixelPerfectScaleMode;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import gameObjects.other.PTEmitter;
import gameObjects.ui.PTNumber;
import gameObjects.ui.Pizzabeth;
import substates.PTQuitSubState;

using StringTools;

/*
    This could be written soooo much better,
    but idc since it's just an easter egg for a shitty dnd program.
    Non so perché ogni tanto scrivo i commenti in italiano e ogni tanto in inglese, anche se il programma è interamente in italiano.
*/
class PTState extends PandoraState
{
    var curFile:Int = 0;
    var curSelected:Int = 0;
    var lastSelected:Int = -1;

    var staticSound:FlxSound;
    var bg:FlxSprite;
    var peppino:FlxSprite;
    /*
        var tvLeft:FlxSprite;
        var tvMid:FlxSprite;
        var tvRight:FlxSprite;
    */
    var tvGroup:FlxTypedGroup<FlxSprite>;
    var charSelect:FlxSprite;
    var statusFrame:FlxSprite;
    var towerPercent:PTNumber;
    var pizzaboy:FlxSprite;
    var explosions:FlxTypedGroup<FlxSprite>;

    var camMain:FlxCamera;
    var camHUD:FlxCamera;

    var jumpscareSprite:FlxSprite;
    var jumpscareTimer:FlxTimer;

    // flags
    var noiseUnlocked:Bool = true;
    var swapUnlocked:Bool = true;

    var selectionAccepted:Bool = false;
    var jumpscaring:Bool = false;
    static var waiting:Bool = true;
    var started:Bool = false;
    var curChar:String = "peppino";
    private var leChars:Array<String> = ['peppino', 'noise'];
    private var leFiles:Array<String> = ['peppino', 'noise', 'swap'];

    override public function create()
	{
        FlxG.mouse.visible = false;
        noiseUnlocked = FlxG.random.bool(90);
        swapUnlocked = FlxG.random.bool(90);

		camMain = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alphaFloat = 0;
		FlxG.cameras.reset(camMain);
		FlxG.cameras.add(camHUD, false);
		FlxG.cameras.setDefaultDrawTarget(camMain, true);

		super.create();
        //persistentUpdate = false;
        FlxG.sound.playMusic(Paths.music('pt_title'), 0.5); // 4.794 secondi per il loop | 13.201 secondi per l'inizio
        var date:Date = Date.now();

        staticSound = new FlxSound();
        staticSound.loadEmbedded(Paths.sound('pt_static'));
        camHUD.alpha = 0;

        //

        bg = new FlxSprite();
        bg.frames = Paths.getAtlasFrames('eggs/PT/background');
        bg.animation.addByPrefix("wait", "wait", 1, false);
        bg.animation.addByPrefix("default", (date.getMonth() == 9 && date.getDate() == 31) ? "halloween" : "bg", 1, false);
        bg.animation.play("wait");
        bg.setGraphicSize(-1, FlxG.height);
        bg.updateHitbox();
        bg.screenCenter();
        add(bg);

        peppino = new FlxSprite(521, 243);
        peppino.frames = Paths.getAtlasFrames('eggs/PT/peppino');
        peppino.replaceColor(FlxColor.fromRGB(255, 255, 64), FlxColor.WHITE);
        peppino.animation.addByPrefix("idle", "idle", 1, false);
        peppino.animation.addByPrefix("fw_left", "fw_left", 24, false);
        peppino.animation.addByPrefix("left_mid", "left_mid", 24, false);
        peppino.animation.addByPrefix("mid_right", "mid_right", 24, false);
        peppino.animation.addByPrefix("mid_left", "mid_left", 24, false);
        peppino.animation.addByPrefix("right_mid", "right_mid", 24, false);
        peppino.animation.addByPrefix("angry", "angry", 24, true);
        peppino.animation.addByPrefix("damage1", "damage1", 24, false);
        peppino.animation.addByPrefix("damage2", "damage2", 24, false);
        peppino.animation.addByPrefix("damage3", "damage3", 24, false);
        peppino.animation.addByPrefix("damage4", "damage4", 24, false);
        peppino.animation.addByPrefix("damage5", "damage5", 24, false);
        peppino.animation.addByPrefix("damage6", "damage6", 24, false);
        peppino.animation.play("idle");
        peppino.setGraphicSize(Std.int(peppino.width * 4 / 3));
        peppino.updateHitbox();
        //peppino.screenCenter();
        peppino.visible = false;
        add(peppino);

        tvGroup = new FlxTypedGroup<FlxSprite>();
        add(tvGroup);

        createTV(138, 0, 'eggs/PT/tv_left');
        createTV(658, 91, 'eggs/PT/tv_mid');
        createTV(932, 222, 'eggs/PT/tv_right');

        explosions = new FlxTypedGroup<FlxSprite>();
        add(explosions);

        // hud

        var quit:FlxSprite = new FlxSprite().loadGraphic(Paths.image('eggs/PT/hud/quit'));
        quit.setGraphicSize(Std.int(quit.width * 4 / 3));
        quit.updateHitbox();
        quit.setPosition(0, 0);
        quit.cameras = [camHUD];
        add(quit);

        var esc:FlxSprite = new FlxSprite().loadGraphic(Paths.image('eggs/PT/hud/button_esc'));
        esc.setGraphicSize(Std.int(esc.width * 4 / 3));
        esc.updateHitbox();
        esc.setPosition(50, 90);
        esc.cameras = [camHUD];
        add(esc);

        charSelect = new FlxSprite();
        charSelect.frames = Paths.getAtlasFrames('eggs/PT/hud/file_select');
        charSelect.animation.addByPrefix("peppino", "peppino", 6, true);
        charSelect.animation.addByPrefix("noise1", "noise1", 6, true);
        charSelect.animation.addByPrefix("noise2", "noise2", 6, true);
        charSelect.animation.addByPrefix("swap", "swap", 6, true);
        charSelect.animation.play("peppino");
        charSelect.setGraphicSize(Std.int(charSelect.width * 4 / 3));
        charSelect.updateHitbox();
        charSelect.y = FlxG.height - charSelect.height;
        if (!noiseUnlocked)
            charSelect.visible = false;
        charSelect.cameras = [camHUD];
        add(charSelect);

        statusFrame = new FlxSprite(84, 290).loadGraphic(Paths.image('eggs/PT/hud/status'));
        statusFrame.setGraphicSize(Std.int(statusFrame.width * 4 / 3));
        statusFrame.updateHitbox();
        statusFrame.cameras = [camHUD];
        add(statusFrame);

        towerPercent = new PTNumber(238, 375, 'eggs/PT/hud/numbers', 0);
        towerPercent.spacing = -14;
        towerPercent.digitScale = 1.4;
        towerPercent.align = CENTER;
        towerPercent.cameras = [camHUD];
        add(towerPercent);

        pizzaboy = new FlxSprite().loadGraphic(Paths.image('eggs/PT/hud/skeleton'));
        pizzaboy.setGraphicSize(Std.int(pizzaboy.width * 4 / 3));
        pizzaboy.updateHitbox();
        pizzaboy.cameras = [camHUD];
        pizzaboy.setPosition(
            statusFrame.x + statusFrame.width / 2 - pizzaboy.width / 2,
            statusFrame.y + statusFrame.height - 10
        );
        add(pizzaboy);

        var version:Pizzabeth = new Pizzabeth(0, 0, "");
		version.alphabetType = "new_small_alphabet";
        version.size = 1.3;
        version.set_text("V" + lime.app.Application.current.meta.get('version'));
        version.cameras = [camHUD];
        version.setPosition(
            FlxG.width - version.width - 150 + 150,
            FlxG.height - version.height - 150 + 75
        );
        add(version);

        // jumpscare
        jumpscareSprite = new FlxSprite().loadGraphic(Paths.image('eggs/PT/jumpscare'));
        jumpscareSprite.screenCenter();
        jumpscareSprite.visible = false;
        add(jumpscareSprite);

        jumpscareTimer = new FlxTimer().start(30, function(_)
        {
            jumpscare();
        });

        #if debug
        introStart();
        #end
	}

    private function createTV(x:Float, y:Float, atlasPath:String):FlxSprite
    {
        var tv = new FlxSprite(x, y);
        tv.frames = Paths.getAtlasFrames(atlasPath);

        var anims:Map<String, Array<Dynamic>> = [
            "peppino off" => ["Poff", 1, false],
            "noise off" => ["Noff", 1, false],
            "peppino on" => ["Pon", 24, false],
            "noise on" => ["Non", 24, false],
            "peppino static" => ["Pstatic", 24, true],
            "noise static" => ["Nstatic", 24, true],
            "peppino hover" => ["Phover", 24, true],
            "noise hover" => ["Nhover", 24, true],
            "peppino select" => ["Pselect", 24, true],
            "noise select" => ["Nselect", 24, true],
        ];

        for (name => data in anims)
        {
            tv.animation.addByPrefix(name, data[0], data[1], data[2]);
        }

        tv.animation.play("peppino off");
        tv.setGraphicSize(Std.int(tv.width * 4 / 3));
        tv.updateHitbox();
        tv.visible = false;
        tv.ID = tvGroup.length;

        tvGroup.add(tv);
        return tv;
    }

    private function jumpscare():Void
    {
        jumpscaring = true;
        FlxG.sound.play(Paths.sound('pt_jumpscare'));

        jumpscareSprite.visible = true;
        FlxTween.tween(jumpscareSprite, {"scale.x": 10.0, "scale.y": 10.0}, 0.6, {
            onUpdate: function(_)
            {
                jumpscareSprite.screenCenter();
            },
            onComplete: function(_)
            {
                Sys.exit(0);
            }
        });
    }

    private function introStart():Void
    {
        waiting = false;
        jumpscareTimer.cancel();
        FlxG.sound.play(Paths.sound('pt_lightswitch'));
        FlxG.sound.music.time = 13183;
        FlxG.sound.music.pause();

        tvGroup.forEach(function(leTv:FlxSprite)
        {
            FlxFlicker.flicker(leTv, 1, 0.1, true, true);
        });
        FlxFlicker.flicker(peppino, 1, 0.1, true, true,
            function(_)
            {
                started = true;
                bg.animation.play("default");
                changeSelection();
                FlxTween.tween(camHUD, {alpha: 1}, 0.2);
                towerPercent.setCoolValue(FlxG.random.int(86, 99));
            },
            function(_)
            {
                if (bg.animation.curAnim.name == "default")
                    bg.animation.play("wait");
                else
                    bg.animation.play("default");
            }
        );

        new FlxTimer().start(0.3, function(_)
        {
            FlxG.sound.music.resume();
        });
    }

    private static function checkAnyJustPressed():Bool
	{
		return (FlxG.keys.justPressed.ANY ||
            (FlxG.mouse.justPressed || FlxG.mouse.justPressedRight || FlxG.mouse.justPressedMiddle));
	}

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        handleSoundLoop();
        handleInput();
    }

    private function handleInput():Void
    {
        if (jumpscaring || selectionAccepted)
            return;

        if (waiting && checkAnyJustPressed())
        {
            introStart();
        }

        if (started)
        {
            if (FlxG.keys.anyJustPressed([LEFT, A]))
                changeSelection(-1);
            else if (FlxG.keys.anyJustPressed([RIGHT, D]))
                changeSelection(1);

            if (FlxG.keys.anyJustPressed([UP, W]))
                changeCharacter(-1);
            else if (FlxG.keys.anyJustPressed([DOWN, S]))
                changeCharacter(1);

            if (FlxG.keys.anyJustPressed([BACKSPACE, ESCAPE, X])) // (FlxG.keys.justPressed.ESCAPE)
                openSubState(new PTQuitSubState());

            if (FlxG.keys.anyJustPressed([ENTER, SPACE, Z]))
                acceptSelection();

            if (FlxG.mouse.overlaps(peppino) && FlxG.mouse.justPressed)
            {
                damage();
            }
        }
    }

    private function handleSoundLoop():Void // im not adding fmod just for this shit
    {
        if (FlxG.sound.music.time >= 4794 && waiting)
			FlxG.sound.music.time = 0;
    }

    private function damage():Void
    {
        FlxG.sound.play(Paths.sound('pt_punch'));

        var randomAnim:Int = FlxG.random.bool(5) ? 6 : FlxG.random.int(1, 5);
        peppino.animation.play('damage' + randomAnim, true);
        peppino.offset.set(130, 70);

        if (angerTimer != null && angerTimer.active)
            angerTimer.cancel();
        FlxTween.cancelTweensOf(peppino);
        FlxTween.shake(peppino, 0.02, 0.35, XY, {
            onComplete: function(_)
            {
                new FlxTimer().start(0.1, function(_)
                {
                    damageReaction();
                });
            }
        });
    }

    var angerTimer:FlxTimer;
    private function damageReaction():Void
    {
        peppino.animation.play("angry", true);
        angerTimer = new FlxTimer().start(1, function(_)
        {
            var animToPlay:String = '${getLastSelected()}_${getCurSelected()}';
            // var lastFrame:Int = peppino.animation.getByName(animToPlay).frames.length - 1;
            peppino.animation.play(animToPlay); // , true, false, lastFrame);
            peppino.animation.finish();
            peppino.offset.set(-31.5, -36.255);
        });
    }

    private function changeCharacter(change:Int = 0):Void
    {
        if (!noiseUnlocked)
            return;

        if (swapUnlocked && (curFile + change < 0 || curFile + change > leFiles.length - 1))
            return;
        else if (!swapUnlocked && (curFile + change < 0 || curFile + change > leFiles.length - 2))
            return;

        FlxG.sound.play(Paths.sound('pt_switchchar' + FlxG.random.int(1, 2)));
        curFile = curFile + change;
        var lastChar:String = curChar;
        curChar = leChars[Std.int(FlxMath.bound(curFile, 0, leChars.length - 1))];

        if (curChar == "noise" && leFiles[curFile] != 'swap')
            charSelect.animation.play('noise' + ((swapUnlocked) ? '2' : '1'));
        else
            charSelect.animation.play(leFiles[curFile]);
        
        for(leTv in tvGroup)
        {
            if (leTv.ID == curSelected)
            {
                turnOnTV(leTv, (lastChar == curChar) ? false : true);
            }
            else
            {
                leTv.animation.play('$curChar off');
            }
        }
    }

    private function changeSelection(change:Int = 0):Void
    {
        if (curSelected + change < 0 || curSelected + change > tvGroup.length - 1)
            return;

        if (change != 0)
            lastSelected = curSelected;
        curSelected = curSelected + change;
        if (angerTimer != null && angerTimer.active)
            angerTimer.cancel();

        for(leTv in tvGroup)
        {
            if (leTv.ID == curSelected)
            {
                turnOnTV(leTv);
            }
            else
            {
                leTv.animation.play('$curChar off');
            }
        }

        if (!peppino.animation.curAnim.name.startsWith("damage"))
        {
            peppino.animation.play('${getLastSelected()}_${getCurSelected()}');
            peppino.offset.set(-31.5, -36.255);
        }
    }

    private function turnOnTV(leTv:FlxSprite, ?turnOn:Bool = true):Void
    {
        if (!turnOn)
        {
            leTv.animation.play('$curChar hover');
            staticSound.stop();
            return;
        }

        staticSound.play();

        leTv.animation.play('$curChar on');
        leTv.animation.finishCallback = function(name:String)
        {
            if (name.endsWith("on"))
            {
                leTv.animation.play('$curChar hover');
                staticSound.stop();
            }
        };
    }

    private function acceptSelection():Void
    {
        staticSound.stop();
        switch(getCurSelected())
        {
            default:
                selectionSequence(
                    function()
                    {
                        FlxG.mouse.visible = true;
                        FlxG.mouse.useSystemCursor = true;
                        switchState(new TurnState());
                    }
                );

        }
    }

    private function selectionSequence(endCallback:Void->Void):Void
    {
        selectionAccepted = true;
        FlxG.sound.music.stop();

        switch(curChar)
        {
            case 'noise':
                FlxG.camera.shake(0.01, 10);
                camHUD.shake(0.01, 10);
                FlxG.sound.play(Paths.sound('pt_selectscream'), 0.5);
                FlxG.sound.play(Paths.sound('pt_selectexplosions'), 1.0);
                var leTv:FlxSprite = tvGroup.members[curSelected];
                leTv.animation.play('$curChar select');
                goExplosions();

                new FlxTimer().start(2, function(_)
                {
                    peppino.animation.play("damage" + FlxG.random.int(1, 6));
                    peppino.offset.set(130, 70);
                    FlxTween.tween(peppino, {x: FlxG.width * 1.2, y: peppino.y - 300}, 1.2, {ease: FlxEase.cubeOut});
                });

                new FlxTimer().start(5.2, function(_)
                {
                    try
                    {
                        endCallback();
                    }
                    catch (e)
                    {
                        FlxG.resetState();
                    }
                });
            default:
                FlxG.sound.play(Paths.sound('pt_select' + (curSelected + 1)));
                var leTv:FlxSprite = tvGroup.members[curSelected];
                leTv.animation.play('$curChar select');

                new FlxTimer().start(4.2, function(_)
                {
                    try
                    {
                        endCallback();
                    }
                    catch (e)
                    {
                        FlxG.resetState();
                    }
                });
        }
    }

    private function goExplosions():Void
    {
        var template = new FlxSprite();
        template.frames = Paths.getAtlasFrames('eggs/PT/explosion');
        template.animation.addByPrefix("default", "explosion", 24, false);

        var emitter = new PTEmitter(explosions, template, 7, 0.02, "default");
    }

    private function getLastSelected():String
    {
        switch (lastSelected)
        {
            case 0:
                return "left"; 
            case 1:
                return "mid";
            case 2:
                return "right";
            default:
                return "fw";
        }
    }

    private function getCurSelected():String
    {
        switch (curSelected)
        {
            case 0:
                return "left"; 
            case 1:
                return "mid";
            case 2:
                return "right";
            default:
                return null;
        }
    }
}