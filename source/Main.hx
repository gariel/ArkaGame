package;

import flixel.FlxGame;
import openfl.display.Sprite;

class Main extends Sprite
{
	public function new()
	{
		super();
		var fps = 30;
		var fullscreen = true;
		addChild(new FlxGame(1280, 720, PlayState, 1, fps, fps, true, fullscreen));
	}
}
