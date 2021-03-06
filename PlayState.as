package
{
	import org.flixel.*;
	import org.flixel.plugin.photonstorm.BaseTypes.Bullet;
	import org.flixel.plugin.photonstorm.FlxDelay;
	
	public class PlayState extends FlxState
	{
		[Embed(source="data/home.png")]
		private static var ImgHome:Class;
		[Embed(source="data/pause.png")]
		private static var ImgPause:Class;
		[Embed(source="data/LLS - Flesh And Steel.mp3")]
		private static var SndMusic:Class;
		[Embed(source="data/invisChef.png")]
		private static var ImgChefButton:Class;
		[Embed(source="data/bg.png")]
		private static var ImgBG:Class;
		[Embed(source="data/bulletCount.png")]
		private static var ImgBullet:Class;
		
		private static var COLUMNS:uint = 7;
		private static var ROWS:uint = 7;
		
		public var board:Board;
		public var chef:Chef;
		public var dishs:FlxGroup;
		public var bullet:FlxGroup;
		public var pause:Pause;
		public var score:FlxText;
		public var bulletDisplay:FlxText;
		public var zombies:FlxGroup;
		//public var timer:FlxDelay;
		//public var zomebieSpawnDelay:int = 5000;	// time in MS for how long to delay zombie spawning	
		public var zombieSpawnDelay:Number = 5;
		// the amount of time played - used for spawning zombies
		public var elapsedTime:Number;
		// speed to pass into zombie on construction
		public var zombieSpeedScalar:Number = 10;
		// counter for how many zombies have been brought it
		public var zombieCounter:int = 0;
		
		// the time to wait until next spawn
		public var spawnTime:Number;
		public const TIME_SEED:int = 12;
		
		override public function create():void
		{
			elapsedTime = 0;
			spawnTime = 5;
			
			pause = new Pause();
			zombies = new FlxGroup();
			dishs = new FlxGroup();
			bullet = new FlxGroup();
			
			// Background Image
			add(new FlxSprite(0, 0, ImgBG));
			
			score = new FlxText(0, 0, FlxG.width);
			score.alignment = "center";
			score.shadow = 0xFF000000;
			score.size = 21;
			add(score);
			
			bulletDisplay = new FlxText(0, 458, FlxG.width);
			bulletDisplay.alignment = "right";
			bulletDisplay.size = 18;
			add(bulletDisplay);
			
			// Home button
			add(new FlxButton(0, 0, "", goToMain).loadGraphic(ImgHome, true, false, 32, 32));
			// Pause button
			add(new FlxButton(FlxG.width - 30, 0, null, pauseGame).loadGraphic(ImgPause, true, false, 32, 32));
			// ammo counter image
			add(new FlxSprite(256, 458, ImgBullet));
			
			add(new FlxButton(FlxG.width - 91, FlxG.height - 131, null, throwDishChefClick).loadGraphic(ImgChefButton, false, false, 91, 91));
			
			add(dishs);
			add(bullet);
			
			board = new Board(COLUMNS, ROWS);
			add(board);
			// this would need to be called after swaps and and replacing tiles
			board.checkBoard();
			
			chef = new Chef();
			add(chef);
			
			// start with first zombie
			zombies.add(new Zombie(zombieSpeedScalar));
			// add all objects to the game
			add(dishs);
			add(zombies);
			
			// start timer for zombie spawn delay
			//timer = new FlxDelay(zomebieSpawnDelay);
			//timer.start();
			
			pause.alive = false;
			pause.exists = false;
			add(pause);
			
			FlxG.flash(0xFF000000, 1);
			FlxG.mouse.show();
			FlxG.playMusic(SndMusic);
		}
		
		public function pauseGame():void
		{
			if (!FlxG.paused)
			{
				FlxG.paused = true;
				pause.revive();
			}
			else
			{
				FlxG.paused = false;
				pause.alive = false;
				pause.exists = false;
			}
		}
		
		
		override public function update():void
		{
			if (FlxG.paused)
			{
				
				pause.update();
			}
			else
			{
				super.update();
			
				// check collisions
				FlxG.collide(zombies, chef, gameOver);
				FlxG.collide(dishs, zombies, hitZombieWithDish);
				FlxG.collide(bullet, zombies, hitZombieWithBullet);
// if enough time has passed, spawn new zombie
//elapsedTime += FlxG.elapsed;			
//if (elapsedTime >= spawnTime)
				//if (timer.hasExpired)
				elapsedTime += FlxG.elapsed;
				if (elapsedTime.valueOf() >= zombieSpawnDelay)
				{
					zombieSpeedScalar += 0.3;
					zombies.add(new Zombie(zombieSpeedScalar));
					add(zombies);
					zombieCounter++;
					// reset timer
					if (zombieCounter < 20)
						zombieSpawnDelay = 5;
					else if (zombieCounter < 30)
						zombieSpawnDelay = 4.5;
					else if (zombieCounter < 40)
						zombieSpawnDelay = 4;
					else if (zombieCounter < 50)
						zombieSpawnDelay = 3.5;
					else
						zombieSpawnDelay = 3;
					
					elapsedTime = 0;
					
						//timer.duration = zomebieSpawnDelay;
						//timer.start();
					/*
					   // reset timer
					   elapsedTime = 0;
					   spawnTime = FlxG.random() * TIME_SEED;
					 */
				}
				
				if (board.checkBowl() > -1)
				{
					// do animation and throw dish if chain is made
					//Chef.chopping = true;
					chef.chop();
					throwDish();
				}
				
				score.text = FlxG.score.toString(); //use this score to update the actual score at the top of the screen.
				
				if (board.getBullets() < 10)
					bulletDisplay.text = "x0" + board.getBullets().toString()
				else
					bulletDisplay.text = "x" + board.getBullets().toString()
				if (board.getBullets() == board.maxBullets)
					bulletDisplay.color = new uint("0x00FF00");
				else
					bulletDisplay.color = new uint("0xFFFFFF");
			}
		}
		
		public function gameOver(Object1:FlxObject, Object2:FlxObject):void
		{
			FlxG.switchState(new Death());
		}
		
		public function goToMain():void
		{
			FlxG.switchState(new MenuState());
		}
		
		public function throwDish():void
		{
			dishs.add(new Dish());
		}
		
		public function hitZombieWithDish(Object1:FlxObject, Object2:FlxObject):void
		{
			Object1.kill();
			//Object2.kill();
			(Object2 as Zombie).WalkAway();
		}
		
		public function hitZombieWithBullet(Object1:FlxObject, Object2:FlxObject):void
		{
			Object1.kill();
			(Object2 as Zombie).GetShot();
		}
		
		public function throwDishChefClick()
		{
			if (board.getBullets() > 0)
			{
				bullet.add(new Shots());
				board.shootBullet();
			}
		}
	}
}