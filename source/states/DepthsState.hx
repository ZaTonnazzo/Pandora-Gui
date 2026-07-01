package states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.text.FlxTypeText;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

class DepthsState extends PandoraState
{
    var dial1:Array<String> = [
        "CI SEI?",
        "  SIAMO\nCONNESSI?"
    ];
    var dial2:Array<String> = [
        "ECCELLENTE.",
        " DAVVERO\nECCELLENTE.",
        "ORA.",
        " POSSIAMO\nCOMINCIARE."
    ];

    var heart:FlxSprite;
    var gasterText:FlxTypeText;
    var fakeText:FlxText;
    var currentQueue:Array<String> = [];
    var currentIndex:Int = 0;
    var dialogueComplete:Bool = false;
    var autoNextTimer:FlxTimer;
    var waitingForNext:Bool = false;

    static inline final NORMAL_SPEED:Float = 0.2;
    static inline final FAST_SPEED:Float = 0.1;
    static inline final AUTO_NEXT_DELAY:Float = 1.5;

    override public function create()
    {
        super.create();
        FlxG.mouse.visible = false;
        FlxG.sound.playMusic(Paths.musicWAV('dt_ambience'));

        gasterText = new FlxTypeText(0, 100, Std.int(FlxG.width / 4), "", 48);
        gasterText.setFormat(Paths.fontTTF('determination'), 48, FlxColor.WHITE, LEFT);
        gasterText.screenCenter(X);
        add(gasterText);
        
        fakeText = new FlxText(0, 100, 0, "", 48);
        fakeText.setFormat(Paths.fontTTF('determination'), 48, FlxColor.WHITE, CENTER);
        fakeText.screenCenter(X);
        fakeText.visible = false;
        add(fakeText);

        autoNextTimer = new FlxTimer();

        beginDialogue(dial1);
    }

    private function beginDialogue(arr:Array<String>):Void
    {
        currentQueue = arr;
        currentIndex = 0;
        gasterText.alpha = 1;
        showCurrent();
    }

    private function showCurrent():Void
    {
        if (currentIndex >= currentQueue.length)
            return;

        dialogueComplete = false;
        waitingForNext = false;

        gasterText.resetText(currentQueue[currentIndex]);
        fakeText.text = currentQueue[currentIndex];
        fakeText.screenCenter(X);
        gasterText.x = fakeText.x;
        gasterText.start(NORMAL_SPEED, true, false, [], onLineComplete);
    }

    private function onLineComplete():Void
    {
        dialogueComplete = true;
        waitingForNext = true;
        autoNextTimer.start((FlxG.keys.pressed.X) ? AUTO_NEXT_DELAY / 3 : AUTO_NEXT_DELAY, function(_)
        {
            FlxTween.tween(gasterText, {alpha: 0}, 1, {
                    onComplete: function(_)
                    {
                        nextLine();
                    }
                });
        }, 1);
    }

    private function nextLine():Void
    {
        if (!waitingForNext) return;

        autoNextTimer.cancel();
        waitingForNext = false;
        currentIndex++;

        if (currentIndex < currentQueue.length)
        {
            FlxTween.completeTweensOf(gasterText);
            gasterText.alpha = 1;
            showCurrent();
        }
        else
            onAllDialogueComplete();
    }

    private function onAllDialogueComplete():Void
    {
        trace("All dialogue complete.");

        if (currentQueue == dial1)
            heartAppear();
        else if (currentQueue == dial2)
            heartDisappear();
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        #if debug
        if (FlxG.keys.justPressed.F1)
            switchState(new DeltaTitleState());
        #end

        // Speed up typing while X is held
        if (!dialogueComplete)
        {
            gasterText.delay = FlxG.keys.pressed.X ? FAST_SPEED : NORMAL_SPEED;
        }
    }

    private function heartAppear():Void
    {
        var beam:FlxSprite = new FlxSprite().makeGraphic(1, FlxG.height, FlxColor.RED);
        beam.screenCenter();
        add(beam);
        heart = new FlxSprite().loadGraphic(Paths.image('heart_blur'));
        heart.setGraphicSize(Std.int(heart.width * 3));
        heart.updateHitbox();
        heart.screenCenter();
        heart.visible = false;
        add(heart);
        FlxTween.tween(heart, {y: heart.y + 5}, 1.5, {type: PINGPONG});
        
        var totalScale:Float = 75.0;
        FlxG.sound.play(Paths.soundWAV('dt_appear'));
        FlxTween.tween(beam.scale, {x: totalScale}, 0.3, {
            onComplete: function(_)
            {
                heart.visible = true;

                beam.updateHitbox();
                var subScale:Float = totalScale / 3.0;
                var originX:Float = beam.x - beam.width / 2;

                for (i in 0...3)
                {
                    var subBeam:FlxSprite = new FlxSprite().makeGraphic(1, FlxG.height, FlxColor.RED);
                    subBeam.x = originX; // all start at the original beam's position
                    subBeam.y = beam.y;
                    add(subBeam);

                    var targetX:Float = originX + (i * subScale);
                    subBeam.x = targetX;
                    subBeam.scale.x = subScale;
                    subBeam.updateHitbox();

                    FlxTween.tween(subBeam.scale, {x: 0.0}, 1, {startDelay: 0.1,
                        onComplete: function(_)
                        {
                            subBeam.visible = false;
                            new FlxTimer().start(AUTO_NEXT_DELAY, function(_) { beginDialogue(dial2); } );
                        }
                    });
                }
                
                beam.visible = false;
                beam.kill();
            }
        });
    }

    private function heartDisappear():Void
    {
        var beam:FlxSprite = new FlxSprite().makeGraphic(1, FlxG.height, FlxColor.RED);
        beam.screenCenter();
        add(beam);
        
        var totalScale:Float = 75.0;
        FlxG.sound.play(Paths.soundWAV('dt_appear'));
        FlxTween.tween(beam.scale, {x: totalScale}, 0.3, {
            onComplete: function(_)
            {
                heart.visible = false;

                beam.updateHitbox();
                var subScale:Float = totalScale / 3.0;
                var originX:Float = beam.x - beam.width / 2;

                for (i in 0...3)
                {
                    var subBeam:FlxSprite = new FlxSprite().makeGraphic(1, FlxG.height, FlxColor.RED);
                    subBeam.x = originX; // all start at the original beam's position
                    subBeam.y = beam.y;
                    add(subBeam);

                    var targetX:Float = originX + (i * subScale);
                    subBeam.x = targetX;
                    subBeam.scale.x = subScale;
                    subBeam.updateHitbox();

                    FlxTween.tween(subBeam.scale, {x: 0.0}, 1, {startDelay: 0.1,
                        onComplete: function(_)
                        {
                            subBeam.visible = false;
                            new FlxTimer().start(AUTO_NEXT_DELAY, function(_)
                            {
                                // FlxG.sound.music.stop();
                                switchState(new DeltaTitleState());
                            });
                        }
                    });
                }
                
                beam.visible = false;
                beam.kill();
            }
        });
    }
}