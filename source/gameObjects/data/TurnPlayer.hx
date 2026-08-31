package gameObjects.data;

class TurnPlayer
{
    public var name:String;
    public var score:Int;
    private var onTop:Bool = false;
    public var hp:Int; // health points
    public var ac:Int; // armor class

    public function new(name:String, score:Int, hp:Int, ac:Int)
    {
        this.name = name;
        this.score = score;
        this.hp = hp;
        this.ac = ac;
    }

    public function getNat():Bool
    {
        return onTop;
    }

    public function setNat(nat:Bool):Void
    {
        if (score < 20)
            return;

        onTop = nat;
    }
}