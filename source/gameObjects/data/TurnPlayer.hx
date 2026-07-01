package gameObjects.data;

class TurnPlayer
{
    public var name:String;
    public var score:Int;
    private var onTop:Bool = false;

    public function new(name:String, score:Int)
    {
        this.name = name;
        this.score = score;
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