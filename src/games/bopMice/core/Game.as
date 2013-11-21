package games.bopMice.core
{
	import com.greensock.TweenMax;
	import com.neriksworkshop.lib.ASaudio.Track;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import assets.MalletMC;
	import assets.MouseStatesMC;
	
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
	
	import util.SWFAssetLoader;
	
	public class Game extends MovieClip
	{
		
		public static const FPS:int = DataModel.BOP_MICE_FPS; 
		public var DURATION:int = 30; // in seconds
		public static const MINIMUM_SCORE:int = 25;	
		
		public var userScore:int;
		private var _mc:MovieClip;
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
		private var _startGame:StartGame;
		private var _tryAgain:RetryGame;
		private var _gameWon:GameWon;
		private var _SAL:SWFAssetLoader;
		private var _mallet:MalletMC;
		
		public function Game()
		{
			_SAL = new SWFAssetLoader("theCattery.BopMiceMC", this);
			EventController.getInstance().addEventListener(ViewEvent.ASSET_LOADED, init);
		}
		
		public function destroy():void {
			removeEventListener(Event.ENTER_FRAME, update);
			
			_gameWon.destroy();
			_tryAgain.destroy();
			_startGame.destroy();
			
			_gameWon = null;
			_tryAgain = null;
			_startGame = null;
			
			hero.destroy();
			hero = null;
			
			_countdownClock.destroy();
			_countdownClock = null;
			
//			not doing this was breaking it
			score.destroy();
			score = null;
			
			_mallet = null;
			
			_clouds.destroy();
			_clouds = null;
			
			explosionManager.destroy();
			collisionManager.destroy();
			enemyManager.destroy();
			
			explosionManager = null;
			collisionManager = null;
			enemyManager = null;
			
			_bgMusic.stop(true);
			_bgMusic = null;
			
			_gameTimer.removeEventListener(TimerEvent.TIMER, timerTick);
			_gameTimer = null;
			
			DataModel.getInstance().removeAllChildren(_mc);
			
			_SAL.destroy();
			_SAL = null;
			
			removeChild(_mc);
			_mc = null;
		}
		
		private function init(event:Event):void
		{
			EventController.getInstance().removeEventListener(ViewEvent.ASSET_LOADED, init);
			_mc = _SAL.assetMC;
			
			_mc.frame_mc.mouseEnabled = false;
			_mc.frameShadow_mc.mouseEnabled = false;
			
			_startGame = new StartGame(this, _mc.startGame_mc);
			
			_tryAgain = new RetryGame(this, _mc.tryAgain_mc);
			_mc.tryAgain_mc.visible = false;
			
			_gameWon = new GameWon(this, _mc.gameWon_mc);
			_mc.gameWon_mc.visible = false;
			
			_countdownClock = new CountdownClock(_mc.countdown_mc, this);
			
			_clouds = new Clouds(_mc.clouds_mc);
			
			score = new Score(_mc.counter_mc);
			
			_timer = DURATION;
			
			_gameTimer = new Timer(1000);
			_gameTimer.addEventListener(TimerEvent.TIMER, timerTick);
			
			addAssets();
			
			enemyManager = new EnemyManager(_mc.mice_mc);
			collisionManager = new CollisionManager(this);
			explosionManager = new ExplosionManager(this);
			
			hero = new Hero(this, _mallet);
			
			// audio
			_bgMusic = new Track("assets/audio/games/bopMice/bg.mp3");
			
			//restack screens
			
			_mc.addChild(_mc.tryAgain_mc);
			_mc.addChild(_mc.gameWon_mc);
			_mc.addChild(_mc.frame_mc);
			_mc.addChild(_mc.startGame_mc);
			
			addChild(_mc);
		}
		
		private function addAssets():void
		{
			//add and replace assets from swc
			for (var i:int = 0; i < _mc.mice_mc.numChildren; i++) 
			{
				var thisRef:MovieClip = _mc.mice_mc.getChildByName("mouse"+i) as MovieClip;
				var thisMouse:MovieClip = new MouseStatesMC();
				
//								thisMouse.stop();
				thisMouse.name = "mouse"+i;
				thisMouse.x = thisRef.x;
				thisMouse.y = thisRef.y;
				thisMouse.scaleX = thisMouse.scaleY = thisRef.scaleX;
				
				_mc.mice_mc.removeChild(thisRef);
				_mc.mice_mc.addChild(thisMouse);
			}
			
			_mallet = new MalletMC();
			_mc.addChild(_mallet);
			_mallet.x = _mc.mallet_mc.x;
			_mallet.y = _mc.mallet_mc.y;
			_mc.removeChild(_mc.mallet_mc);
		}
		
		public function startGame():void {
			_mc.startGame_mc.visible = false;
			
			_countdownClock.startClock();
			_gameTimer.start();
			malletOn();
			addEventListener(Event.ENTER_FRAME, update);
			
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
		
		public function restartGame():void
		{
			_mc.tryAgain_mc.visible = false;
			addEventListener(Event.ENTER_FRAME, update);
			
			explosionManager.explosion.visible = true;
			
			score.resetScore();
			
//			_timer = Game.DURATION;
			_timer = DURATION;
				
			_gameTimer.reset();
			_gameTimer.start();
			_countdownClock.startClock();
			_bgMusic.start();
		}
		
		public function gameCompleted():void
		{
			_mc.stopAllMovieClips();
			TweenMax.killAll();
			
			var tempObj:Object = new Object();
			tempObj.id = "theCattery.GameWonView";
			_mc.stopAllMovieClips();
			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.DECISION_CLICK, tempObj));
		}
	}
}