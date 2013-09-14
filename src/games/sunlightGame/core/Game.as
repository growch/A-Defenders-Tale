package games.sunlightGame.core
{
	import com.neriksworkshop.lib.ASaudio.Track;
	
	import flash.display.MovieClip;
	import flash.display.StageAspectRatio;
	import flash.display.StageOrientation;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.StageOrientationEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import control.EventController;
	
	import events.ViewEvent;
	
	import games.sunlightGame.managers.BulletManager;
	import games.sunlightGame.managers.CollisionManager;
	import games.sunlightGame.managers.EnemyManager;
	import games.sunlightGame.managers.ExplosionManager;
	import games.sunlightGame.objects.GameLost;
	import games.sunlightGame.objects.GameWon;
	import games.sunlightGame.objects.Hero;
	import games.sunlightGame.objects.Nero;
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
		public var hero:Hero;
		public var nero:Nero;
		public var fire:Boolean;
		private var _timer:int;
		private var _gameTimer:Timer;
		private var _bgMusic:Track;
		private var _startGame:StartGame;
		private var _gameLost:GameLost;
		private var _gameWon:GameWon;
		private var _SAL:SWFAssetLoader;
		public var enemyManager:EnemyManager;
		public var bulletManager:BulletManager;
		public var collisionManager:CollisionManager;
		public var explosionManager:ExplosionManager;
		public var bulletHolder:MovieClip;
		public var enemyHolder:MovieClip;
		public var dropHolder:MovieClip;
		public var blockArray:Array;
		public var gameFlipped:Boolean;
		public var lightSource:MovieClip;
		public var explosionHolder:MovieClip;
		private var _speedTimer:int = 15000;
		
		public function Game()
		{
			_SAL = new SWFAssetLoader("capitol.SunlightGameMC", this);
			EventController.getInstance().addEventListener(ViewEvent.ASSET_LOADED, init);
		}
		
		public function destroy():void {
			if (hasEventListener(Event.ENTER_FRAME)) {
				removeEventListener(Event.ENTER_FRAME, update);
			}
			
			stage.removeEventListener( StageOrientationEvent.ORIENTATION_CHANGE, onOrientationChange ); 
			stage.setOrientation( StageOrientation.DEFAULT );
			stage.autoOrients = false;
			
			hero.destroy();
			hero = null;
			nero.destroy();
			nero = null;
			
			_gameWon.destroy();
			_gameLost.destroy();
			
			_startGame = null;
			_gameLost = null;
			_gameWon = null;
			
			bulletManager.destroy();
			explosionManager.destroy();
			collisionManager.destroy();
			enemyManager.destroy();
			
			bulletManager = null;
			explosionManager = null;
			collisionManager = null;
			enemyManager = null;
			
			_bgMusic.stop(true);
			_bgMusic = null;
			
			_gameTimer.stop();
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
			
			_startGame = new StartGame(this, _mc.startGame_mc);
			
			_gameLost = new GameLost(this, _mc.gameLost_mc);
			_mc.gameLost_mc.visible = false;
			
			_gameWon = new GameWon(this, _mc.gameWon_mc);
			_mc.gameWon_mc.visible = false;
			
			_gameTimer = new Timer(_speedTimer);
			_gameTimer.addEventListener(TimerEvent.TIMER, speedUp);
			
			bulletHolder = _mc.bulletHolder_mc;
			enemyHolder = _mc.enemyHolder_mc;
			explosionHolder = _mc.explosionHolder_mc;
			dropHolder = _mc.dropHolder_mc;
			lightSource = _mc.light_mc;
			
			hero = new Hero(this, _mc.cannon_mc);
			nero = new Nero(this, _mc.nero_mc);
			
			blockArray = new Array();
			for (var i:int = 0; i < _mc.blocks_mc.numChildren; i++) 
			{
				var thisBlock:MovieClip = _mc.blocks_mc.getChildAt(i);
				blockArray.push(thisBlock);
			}
			
			addChild(_mc);
			
			stage.autoOrients = true;
			
			stage.addEventListener( StageOrientationEvent.ORIENTATION_CHANGE, onOrientationChange ); 
//			stage.addEventListener(	StageOrientationEvent.ORIENTATION_CHANGING, onOrientationChanging );
			// didn't have to bother with the above, the below locks it in portrait mode
			stage.setAspectRatio(StageAspectRatio.PORTRAIT); 
			
			
			//restack screens
//			_mc.addChild(_mc.startGame_mc);
//			_mc.addChild(_mc.gameLost_mc);
//			_mc.addChild(_mc.gameWon_mc);
		}
		
		protected function speedUp(event:TimerEvent):void
		{
			enemyManager.speedUp();
		}
		
		protected function onOrientationChange(event:StageOrientationEvent):void
		{
//			trace("onOrientationChange :"+event.afterOrientation);
			if (event.afterOrientation == StageOrientation.UPSIDE_DOWN) {
				hero.flipUpsideDown();
				gameFlipped = true;
			}
			if (event.afterOrientation == StageOrientation.DEFAULT) {
				hero.flipRightSideUp();
				gameFlipped = false;
			}
		}
		
		public function startGame():void {
			_mc.startGame_mc.visible = false;
			
			bulletManager = new BulletManager(this);
			enemyManager = new EnemyManager(this);
			collisionManager = new CollisionManager(this);
			explosionManager = new ExplosionManager(this);
			
			heroOn();
			addEventListener(Event.ENTER_FRAME, update);
			// audio
			_bgMusic = new Track("assets/audio/games/sunlightGame/bg.mp3");
//			_bgMusic.start(true);
//			_bgMusic.loop = true;
			
			_gameTimer.start();
		}
		
		private function heroOn():void  {
			stage.addEventListener(MouseEvent.MOUSE_DOWN, onDown);
			stage.addEventListener(MouseEvent.MOUSE_UP, onUp);
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
			nero.update();
			bulletManager.update();
			enemyManager.update();
			collisionManager.update();
			explosionManager.update();
		}
		
		public function gameOver(winOrLose:String):void  {
			removeEventListener(Event.ENTER_FRAME, update);
			stage.removeEventListener(MouseEvent.MOUSE_DOWN, onDown);
			stage.removeEventListener(MouseEvent.MOUSE_UP, onUp);
			_mc.stopAllMovieClips();
			enemyManager.gameOver();
			
			if (winOrLose == "win") {
				_mc.gameWon_mc.visible = true;
			} else {
				_mc.gameLost_mc.visible = true;
			}
			
		}
		
		public function gameCompleted():void
		{
			var tempObj:Object = new Object();
			tempObj.id = "capitol.WinView";
//			_mc.stopAllMovieClips();
			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.DECISION_CLICK, tempObj));
		}
		
		public function gameLost(thisPageObj:Object):void {
//			_mc.stopAllMovieClips();
			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.DECISION_CLICK, thisPageObj));
		}
	}
}