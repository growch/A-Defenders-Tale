package games.bopMice.core
{
	import com.neriksworkshop.lib.ASaudio.Track;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import assets.BopMiceMC;
	
	import control.EventController;
	
	import events.ViewEvent;
	
	import games.bopMice.managers.CollisionManager;
	import games.bopMice.managers.EnemyManager;
	import games.bopMice.managers.ExplosionManager;
	import games.bopMice.objects.Clouds;
	import games.bopMice.objects.CountdownClock;
	import games.bopMice.objects.GameWon;
	import games.bopMice.objects.Hero;
	import games.bopMice.objects.RetryGame;
	import games.bopMice.objects.Score;
	import games.bopMice.objects.StartGame;
	
	import model.DataModel;
	
	
	public class Game extends Sprite
	{
		
		public static const FPS:int = DataModel.BOP_MICE_FPS; 
		public static const DURATION:int = 60; // in seconds
		public static const MINIMUM_SCORE:int = 30;	
		
		public var userScore:int;
		private var _mc:BopMiceMC;
		public var enemyManager:EnemyManager;
		public var hero:Hero;
		public var collisionManager:CollisionManager;
		
		public var fire:Boolean;
		private var _countdownClock:CountdownClock;
		private var _timer:int;
		private var _gameTimer:Timer;
		public var score:Score;
		private var _clouds:Clouds;
		public var explosionManager:ExplosionManager;
		private var _bgMusic:Track;
		private var _startGame:MovieClip;
		private var _tryAgain:MovieClip;
		private var _gameWon:GameWon;
		
		public function Game()
		{
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(event:Event):void
		{
			
			_mc = new BopMiceMC();
			
			_mc.frame_mc.mouseEnabled = false;
			_mc.frameShadow_mc.mouseEnabled = false;
			
			_startGame = new StartGame(this, _mc.startGame_mc);
			
			_tryAgain = new RetryGame(this, _mc.tryAgain_mc);
			_mc.tryAgain_mc.visible = false;
			
			_gameWon = new GameWon(this, _mc.gameWon_mc);
			_mc.gameWon_mc.visible = false;
			
			_countdownClock = new CountdownClock(_mc.countdown_mc);
			
			_clouds = new Clouds(_mc.clouds_mc);
			
			score = new Score(_mc.counter_mc);
			
			_timer = Game.DURATION;
			
			_gameTimer = new Timer(1000);
			_gameTimer.addEventListener(TimerEvent.TIMER, timerTick);
			
			addChild(_mc);
			
		}
		
		public function startGame():void {
			_mc.startGame_mc.visible = false;
			
			enemyManager = new EnemyManager(_mc.mice_mc);
			collisionManager = new CollisionManager(this);
			explosionManager = new ExplosionManager(this);
			hero = new Hero(this, _mc.mallet_mc);
			
			_countdownClock.startClock();
			_gameTimer.start();
			malletOn();
			addEventListener(Event.ENTER_FRAME, update);
			// audio
			_bgMusic = new Track("assets/audio/games/bopMice/bg.mp3");
			_bgMusic.start(true);
			_bgMusic.loop = true;
		}
		
		protected function timerTick(event:TimerEvent):void
		{
			_timer--;
			
			_countdownClock.updateClock(_timer);
			
			if (_timer <= 0)
			{
				removeEventListener(Event.ENTER_FRAME, update);
				enemyManager.killAll();
				explosionManager.explosion.visible = false;
				_gameTimer.stop();
				_bgMusic.stop(true);
					
				if (score.getScore() >= MINIMUM_SCORE) {
//					trace("you won");
					_mc.gameWon_mc.visible = true;
				} else {
//					trace("you lost");
					_mc.tryAgain_mc.visible = true;
				}
			}
		}
		
		private function malletOn():void  {
			stage.addEventListener(MouseEvent.MOUSE_DOWN, onDown);
			stage.addEventListener(MouseEvent.MOUSE_UP, onUp);
		}
		
		private function malletOff():void  {
			stage.removeEventListener(MouseEvent.MOUSE_DOWN, onDown);
			stage.removeEventListener(MouseEvent.MOUSE_UP, onUp);
		}
		
		
		private function onDown(event:MouseEvent):void
		{
			fire = true;
		}
		
		private function onUp(event:MouseEvent):void
		{
			fire = false;
		}
		
		private function update(event:Event):void
		{
			hero.update();
			enemyManager.update();
			collisionManager.update();
			_clouds.update();
		}
		
		public function destroy():void {
			//TODO!!!!!! clean everything UP!!!!!!!!
			removeEventListener(Event.ENTER_FRAME, update);
			
			explosionManager.destroy();
			
			_bgMusic.stop(true);
			_bgMusic = null;
		}
		
		public function restartGame():void
		{
			_mc.tryAgain_mc.visible = false;
			addEventListener(Event.ENTER_FRAME, update);
			
			explosionManager.explosion.visible = true;
			
			score.resetScore();
			
			_timer = Game.DURATION;
				
			_gameTimer.reset();
			_gameTimer.start();
			_countdownClock.startClock();
			_bgMusic.start();
		}
		
		public function gameCompleted():void
		{
			var tempObj:Object = new Object();
			tempObj.id = "theCattery.GameWonView";
			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.DECISION_CLICK, tempObj));
		}
	}
}