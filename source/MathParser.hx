package;

using StringTools;

class MathParser
{
    static var str:String;
    static var pos:Int;

    public static function evaluate(s:String):Float
    {
        str = StringTools.replace(s, " ", "");
        pos = 0;

        var value = parseExpression();

        if (pos < str.length)
            throw "Unexpected character at " + Std.string(pos);

        return value;
    }

    static function parseExpression():Float
    {
        var value = parseTerm();

        while (pos < str.length)
        {
            switch (str.charAt(pos))
            {
                case '+':
                    pos++;
                    value += parseTerm();
                case '-':
                    pos++;
                    value -= parseTerm();
                default:
                    return value;
            }
        }

        return value;
    }

    static function parseTerm():Float
    {
        var value = parseFactor();

        while (pos < str.length)
        {
            switch(str.charAt(pos))
            {
                case '*':
                    pos++;
                    value *= parseFactor();
                case '/':
                    pos++;
                    value /= parseFactor();
                case '%':
                    pos++;
                    value %= parseFactor();
                default:
                    return value;
            }
        }

        return value;
    }

    static function parseFactor():Float
    {
        if (str.charAt(pos) == "(")
        {
            pos++;
            var value = parseExpression();

            if (str.charAt(pos) != ")")
                throw "Missing )";

            pos++;
            return value;
        }

        return parseNumber();
    }

    static function parseNumber():Float
    {
        var start = pos;

        while (pos < str.length)
        {
            var c = str.charAt(pos);

            if ((c >= "0" && c <= "9") || c == ".")
                pos++;
            else
                break;
        }

        return Std.parseFloat(str.substring(start, pos));
    }
}