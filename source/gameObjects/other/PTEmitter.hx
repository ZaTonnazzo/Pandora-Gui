package gameObjects.other;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxTimer;

class PTEmitter
{
    var group:FlxTypedGroup<FlxSprite>;
    var template:FlxSprite;
    var spawnTimer:FlxTimer;
    var duration:Float;
    var elapsed:Float = 0;
    var spawnRate:Float;
    var animName:String;

    public function new(group:FlxTypedGroup<FlxSprite>, template:FlxSprite, duration:Float, spawnRate:Float = 0.05, animName:String = null)
    {
        this.group = group;
        this.template = template;
        this.duration = duration;
        this.spawnRate = spawnRate;
        this.animName = animName;

        spawnTimer = new FlxTimer().start(spawnRate, onSpawnTick, 0);
    }

    function onSpawnTick(t:FlxTimer):Void
    {
        elapsed += spawnRate;
        if (elapsed >= duration)
        {
            spawnTimer.cancel();
        }

        spawnSprite();
    }

    function spawnSprite():Void
    {
        var s:FlxSprite = group.recycle(FlxSprite, function() {
            return new FlxSprite();
        });

        if (s.frames != template.frames)
        {
            s.frames = template.frames;
            s.animation.copyFrom(template.animation);
            s.scale.copyFrom(template.scale);
            s.updateHitbox();
            s.blend = template.blend;
            s.antialiasing = template.antialiasing;
        }

        //s.x = FlxG.random.float(0 - s.width / 2, FlxG.width - s.width / 2);
        //s.y = FlxG.random.float(0 - s.height / 2, FlxG.height - s.height / 2);
        s.x = edgeBiasedFloat(0 - s.width / 2, FlxG.width - s.width / 2, 2.5);
        s.y = edgeBiasedFloat(0 - s.height / 2, FlxG.height - s.height / 2, 2.5);
        s.alive = true;
        s.exists = true;
        s.visible = true;

        if (animName != null && s.animation.getByName(animName) != null)
        {
            s.animation.play(animName, true);
            s.animation.finishCallback = function(_)
            {
                s.kill();
            };
        }
        else
        {
            new FlxTimer().start(1.0, function(_)
            {
                s.kill();
            });
        }
    }

    function edgeBiasedFloat(min:Float, max:Float, bias:Float = 2.0):Float
    {
        var t = FlxG.random.float(-1, 1);
        var sign = t < 0 ? -1.0 : 1.0;
        var skewed = sign * Math.pow(Math.abs(t), 1 / bias);
        return min + (skewed + 1) / 2 * (max - min);
    }

    public function stop():Void
    {
        if (spawnTimer != null) spawnTimer.cancel();
    }
}