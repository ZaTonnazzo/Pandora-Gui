package;

import flixel.FlxG;
import flixel.util.FlxSave;

class SaveData
{
    static var save:FlxSave;

    static function getSave():FlxSave
    {
        if (save == null)
        {
            save = new FlxSave();
            save.bind("PandoraGui-eastereggs");

            if (save.data.seen == null)
            {
                save.data.seen = [];
            }
        }
        return save;
    }
    
    public static function pickStartState(easterEggs:Array<Class<flixel.FlxState>>, chancePercent:Int = 5):Class<flixel.FlxState>
    {
        if (!FlxG.random.bool(chancePercent))
        {
            return null;
        }

        var save = getSave();
        var seen:Array<String> = save.data.seen;

        var unseen:Array<Class<flixel.FlxState>> = [];
        for (state in easterEggs)
        {
            if (seen.indexOf(Type.getClassName(state)) == -1)
            {
                unseen.push(state);
            }
        }

        // makes you see the unseen ones if any remain, otherwise the full list
        var pool = unseen.length > 0 ? unseen : easterEggs;

        var chosen = pool[FlxG.random.int(0, pool.length - 1)];
        markSeen(chosen);
        return chosen;
    }

    static function markSeen(state:Class<flixel.FlxState>):Void
    {
        var save = getSave();
        var seen:Array<String> = save.data.seen;
        var name = Type.getClassName(state);

        if (seen.indexOf(name) == -1)
        {
            seen.push(name);
        }

        save.data.seen = seen;
        save.flush();
    }

    public static function resetProgress():Void
    {
        var save = getSave();
        save.data.seen = [];
        save.flush();
    }
}