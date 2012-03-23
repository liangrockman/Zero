package
{
	import org.flixel.*;
	
	public class StoryState extends FlxState
	{
		[Embed(source="data/storyClickToPlay.png")] public static var clickToPlay:Class;
		
		public var text:FlxText;
		
		override public function create():void
		{
			FlxG.flash(0xFF000000, 5);
			FlxG.mouse.show();
			
			
			
			text = new FlxText(30, FlxG.height, FlxG.width - 60, "Zombies, ghouls, the living dead, whatever you want to call them, they're out there and they're after me. I was holed up in my diner with nothing left to defend myself but my trusty meat cleaver. One of those .. things.. reached in after me and I chopped off its hand. As luck would have it, the hand landed in my frying pan and as they broke through the door, they walked right past me and went for the frying hand. And that's when I realized they key to survival: keep them happy and well-fed, and I stay off the menu.\n\nIt turns out zombies don't really have any need for money, so they're happy to pay if you give them what they want, and these customers have very discrete taste. If things get out of hand, I keep them in order with a well-placed bullet to head, but that's not exactly good for business. So now I give orders in the kitchen to gather up the body parts necessary to satisfy my clientele, and sometimes I give a little extra for a nice tip. Maybe it's unethical to chop up bodies and feed them to customers, but hey, business has never been better here at the Corpse Cuisine.");
			text.size = 12;
			text.velocity.y = -11;
			add(text);
			
			add(new FlxSprite(0, 0, clickToPlay));
		}
		
		override public function update():void
		{
			super.update();
			
			if ((text.y + text.height < 0) || FlxG.mouse.justPressed())
				FlxG.fade(0xFF000000, 1, skip);
		}
		
		public function skip():void
		{
			FlxG.mouse.hide();
			FlxG.switchState(new PlayState());
		}
	}
}