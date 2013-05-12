package games.bopMice.states
{
//	import core.Assets;
	import games.bopMice.core.Game;
	
	import flash.display.Stage;
	import flash.display.Sprite
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.media.SoundChannel;
	import flash.utils.Timer;
	
	import games.bopMice.interfaces.IState;
	
	import games.bopMice.managers.CollisionManager;
	import games.bopMice.managers.EnemyManager;
	import games.bopMice.managers.ExplosionManager;
	
//	import objects.Background;
//	import objects.Clouds;
//	import objects.CountdownClock;
//	import objects.Enemy;
//	import objects.Hero;
//	import objects.Score;
	
//	import starling.core.Starling;
//	import starling.display.Image;
//	import starling.display.Sprite;
//	import starling.events.Event;
	
	public class Play extends Sprite implements IState
	{
		public var game:Game;
		private var background:Background;
		public var hero:Hero;
//		public var bulletManager:BulletManager;
		public var fire:Boolean = false;
		private var ns:Stage;
		public var enemyManager:EnemyManager; 
		private var collisionManager:CollisionManager;
		public var explosionManager:ExplosionManager;
		public var score:Score;
		private var _gameTimer:Timer; 
		private var _countdownClock:CountdownClock;
		private var _timer:int;
		private var _clouds:Clouds;
		private var frame:Image;
		private var _soundChannel:SoundChannel;
		
		public function Play(game:Game)
		{
			this.game = game;
			touchable = false;
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(event:Event):void
		{
			ns = Starling.current.nativeStage;
			
			background = new Background();
			addChild(background);
			
			score = new Score();
			addChild(score);
			score.x = 575;
			score.y = 75;
			
			_countdownClock = new CountdownClock();
			_countdownClock.x = 80;
			_countdownClock.y = 80;
			addChild(_countdownClock);
			_countdownClock.startClock();
			
			_timer = Game.DURATION;
			
			_gameTimer = new Timer(1000);
			_gameTimer.addEventListener(TimerEvent.TIMER, timerTick);
			_gameTimer.start();
			
			_clouds = new Clouds();
			addChild(_clouds);
			
			frame = new Image(Assets.frameTexture);
			addChild(frame);
			
//			bulletManager = new BulletManager(this);
			enemyManager = new EnemyManager(this);
			collisionManager = new CollisionManager(this);
			explosionManager = new ExplosionManager(this);
			
			hero = new Hero(this);
			addChild(hero);
			
			ns.addEventListener(MouseEvent.MOUSE_DOWN, onDown);
			ns.addEventListener(MouseEvent.MOUSE_UP, onUp);
			
			_soundChannel = new SoundChannel();
			_soundChannel = Assets.bgMusic.play();
		}
		
		protected function timerTick(event:TimerEvent):void
		{
			_timer--;
	
			_countdownClock.updateClock(_timer);
			
			if (_timer <= 0)
			{
				game.userScore = score.getScore();
				//Stop game loop
				game.changeState(Game.GAME_OVER_STATE);
				//TODO FIX DESTROY STATE!!!!!!!!
				return;
			}
		}
		
		private function onDown(event:MouseEvent):void
		{
			fire = true;
		}
		
		private function onUp(event:MouseEvent):void
		{
			fire = false;
//			bulletManager.count = 0;
		}
		
		public function update():void
		{
			background.update();
			hero.update();
			_clouds.update();
//			bulletManager.update();
			enemyManager.update();
			collisionManager.update();
		}
		
		public function destroy():void
		{
//			CLEAN THIS UP!!!!!!!!!!!
			_gameTimer.stop();
			_gameTimer = null;
			
			_soundChannel.stop();
			
			ns.removeEventListener(MouseEvent.MOUSE_DOWN, onDown);
			ns.removeEventListener(MouseEvent.MOUSE_UP, onUp);
//			bulletManager.destroy();
			enemyManager.destroy();
			removeFromParent(true);
		}
	}
}