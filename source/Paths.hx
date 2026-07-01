package;

class Paths
{
	public static function getPath(key:String):String
	{
		return 'assets/$key';
	}

	public static function image(key:String):String
	{
		return getPath("images/") + key + ".png";
	}

	public static function music(key:String):String
	{
		return getPath("music/") + key + ".ogg";
	}

	public static function sound(key:String):String
	{
		return getPath("sounds/") + key + ".ogg";
	}

	public static function musicWAV(key:String):String
	{
		return getPath("music/") + key + ".wav";
	}

	public static function soundWAV(key:String):String
	{
		return getPath("sounds/") + key + ".wav";
	}

	public static function json(key:String):String
	{
		return getPath("data/") + key + ".json";
	}

	public static function tileLoader(key:String):String
	{
		return getPath("data/") + key + ".ogmo";
	}

	public static function fontTTF(key:String):String
	{
		return getPath("fonts/") + key + ".ttf";
	}

	public static function fontOTF(key:String):String
	{
		return getPath("fonts/") + key + ".otf";
	}
}