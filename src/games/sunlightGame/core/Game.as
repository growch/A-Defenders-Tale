package games.sunlightGame.core
{
	import com.neriksworkshop.lib.ASaudio.Track;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.utils.setTimeout;
	
	import assets.MalletMC;
	import assets.MouseStatesMC;
	
	import control.EventController;
	
	import events.ViewEvent;
	
	import games.sunlightGame.managers.BulletManager;
	import games.sunlightGame.managers.CollisionManager;
	import games.sunlightGame.managers.EnemyManager;
	import games.sunlightGame.managers.ExplosionManager;
	import games.sunlightGame.objects.Clouds;
	import games.sunlightGame.objects.CountdownClock;
	import games.sunlightGame.objects.GameWon;
	import games.sunlightGame.objects.Hero;
	import games.sunlightGame.objects.Nero;
	import games.sunlightGame.objects.RetryGame;
	import games.sunlightGame.objects.Score;
	import games.sunlightGame.objects.StartGame;
	
	import model.DataModel;
	
	import util.SWFAssetLoader;
	
	public class Game extends MovieClip
	{
		
		public static const FPS:int = DataModel.BOP_MICE_FPS; 
//		public static const DURATION:int = 60; // in seconds
		public var DURATION:int = 60; // in seconds
		public static const MINIMUM_SCORE:int = 30;	
		
		public var userScore:int;
		private var _mc:MovieClip;
		public var enemyManager:EnemyManager;
		public var hero:Hero;
		public var collisionManager:CollisionManager;
		public var fire:Boolean;
//		private var _countdownClock:CountdownClock;
		private var _timer:int;
		private var _gameTimer:Timer;
//		public var score:Score;
//		private var _clouds:Clouds;
		public var explosionManager:ExplosionManager;
		private var _bgMusic:Track;
		private var _startGame:StartGame;
		private var _tryAgain:RetryGame;
		private var _gameWon:GameWon;
		private var _SAL:SWFAssetLoader;
//		private var _mallet:MalletMC;
		public var nero:Nero;
		public var bulletManager:BulletManager;
		public var bulletHolder:MovieClip;
		public var enemyHolder:MovieClip;
		public var blockArray:Array;
		
		public function Game()
		{
			_SAL = new SWFAssetLoader("capitol.SunlightGameMC", this);
			EventController.getInstance().addEventListener(ViewEvent.ASSET_LOADED, init);
		}
		
		private function init(event:Event):void
		{
			EventController.getInstance().removeEventListener(ViewEvent.ASSET_LOADED, init);
			_mc = _SAL.assetMC;
			
//			_mc.frame_mc.mouseEnabled = false;
//			_mc.frameShadow_mc.mouseEnabled = false;
//			
//			_startGame = new StartGame(this, _mc.startGame_mc);
//			
//			_tryAgain = new RetryGame(this, _mc.tryAgain_mc);
//			_mc.tryAgain_mc.visible = false;
//			
//			_gameWon = new GameWon(this, _mc.gameWon_mc);
//			_mc.gameWon_mc.visible = false;
			
			
			
//			_timer = Game.DURATION;
			_timer = DURATION;
			
//			_gameTimer = new Timer(1000);
//			_gameTimer.addEventListener(TimerEvent.TIMER, timerTick);
			
			bulletHolder = _mc.bulletHolder_mc;
			enemyHolder = _mc.enemyHolder_mc;
			
			hero = new Hero(this, _mc.cannon_mc);
			nero = new Nero(this, _mc.nero_mc);
			
			blockArray = new Array();
			for (var i:int = 0; i < _mc.blocks_mc.numChildren; i++) 
			{
				var thisBlock:MovieClip = _mc.blocks_mc.getChildAt(i);
				blockArray.push(thisBlock);
			}
			
			
			addChild(_mc);
			
			startGame();
			
//			addAssets();
			
			//restack screens
//			_mc.addChild(_mc.startGame_mc);
//			_mc.addChild(_mc.tryAgain_mc);
//			_mc.addChild(_mc.gameWon_mc);
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
			
//			_mallet = new MalletMC();
//			_mc.addChild(_mallet);
//			_mallet.x = _mc.mallet_mc.x;
//			_mallet.y = _mc.mallet_mc.y;
//			_mc.removeChild(_mc.mallet_mc);
		}
		
		public function startGame():void {
//			_mc.startGame_mc.visible = false;
			
			bulletManager = new BulletManager(this);
			enemyManager = new EnemyManager(this);
			collisionManager = new CollisionManager(this);
			explosionManager = new ExplosionManager(this);
			
			
			
//			_countdownClock.startClock();
//			_gameTimer.start();
			heroOn();
			addEventListener(Event.ENTER_FRAME, update);
			// audio
//			_bgMusic = new Track("assets/audio/games/sunlightGame/bg.mp3");
//			_bgMusic.start(true);
//			_bgMusic.loop = true;
			
		}
		
		protected function timerTick(event:TimerEvent):void
		{
			_timer--;
			
//			_countdownClock.updateClock(_timer);
//			
//			if (_timer <= 0)
//			{
//				removeEventListener(Event.ENTER_FRAME, update);
//				enemyManager.killAll();
//				explosionManager.explosion.visible = false;
////				_gameTimer.stop();
//				_bgMusic.stop(true);
//					
//				if (score.getScore() >= MINIMUM_SCORE) {
////					trace("you won");
//					_mc.gameWon_mc.visible = true;
//				} else {
////					trace("you lost");
//					_mc.tryAgain_mc.visible = true;
//				}
//			}
		}
		
		private function heroOn():void  {
			stage.addEventListener(MouseEvent.MOUSE_DOWN, onDown);
			stage.addEventListener(MouseEvent.MOUSE_UP, onUp);
		}
		
		public function gameOver():void  {
			removeEventListener(Event.ENTER_FRAME, update);
			stage.removeEventListener(MouseEvent.MOUSE_DOWN, onDown);
			stage.removeEventListener(MouseEvent.MOUSE_UP, onUp);
		}
		
		
		private function onDown(event:MouseEvent):void
		{
			fire = true;
			bulletManager.fire();
		}
		
		private function onUp(event:MouseEvent):void
		{
			fire = false;
		}
		
		private function update(event:Event):void
		{
			hero.update();
			bulletManager.update();
			enemyManager.update();
			collisionManager.update();
		}
		
		public function destroy():void {
			//TODO!!!!!! clean everything UP!!!!!!!!
			if (hasEventListener(Event.ENTER_FRAME)) {
				removeEventListener(Event.ENTER_FRAME, update);
			}
			
			
			_gameWon.destroy();
			_tryAgain.destroy();
			
			explosionManager.destroy();
			collisionManager.destroy();
			enemyManager.destroy();
			
			_bgMusic.stop(true);
			_bgMusic = null;
			
			_gameTimer = null;
			
			DataModel.getInstance().removeAllChildren(_mc);
			
			_SAL.destroy();
			_SAL = null;
		}
		
		public function restartGame():void
		{
			_mc.tryAgain_mc.visible = false;
			addEventListener(Event.ENTER_FRAME, update);
			
			explosionManager.explosion.visible = true;
			
			
//			_timer = Game.DURATION;
			_timer = DURATION;
				
			_gameTimer.reset();
			_gameTimer.start();
			_bgMusic.start();
		}
		
		public function gameCompleted():void
		{
			var tempObj:Object = new Object();
			tempObj.id = "capitol.WinView";
			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.DECISION_CLICK, tempObj));
		}
	}
}