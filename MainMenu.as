package {
	import org.flixel.*;

	public class MainMenu extends FlxState
	{
		[Embed(source = "data/creeper_pixel.ttf", fontFamily = "Creeper Pixel", embedAsCFF = "false")] public var FntCreeperPixel:String;
		[Embed(source = "data/music.mp3")] public static var SndMusic:Class;		
		
		override public function create():void
		{
			var t:FlxText;
			var b:FlxButton;
			
			t = new FlxText(0, FlxG.height/3, FlxG.width, "ZERO");
			t.setFormat("Creeper Pixel", 72, 0xffffffff, "center");
			t.y -= t.height;
			add(t);
			
			b = new FlxButton(125, 200, "Click to play", startGame);
			add(b);
			
			b = new FlxButton(125, 250, "Options", optionsClick);
			add(b);

			// Shows the mouse cursor
			FlxG.mouse.show();
			FlxG.play(SndMusic); 
		}

		override public function update():void
		{
			super.update();
		}
		
		public function optionsClick():void
		{
			FlxG.switchState(new Options());
			super.update();
		}
		
		public function startGame():void
		{
			FlxG.switchState(new PlayState());
			super.update();
		}
	}
}