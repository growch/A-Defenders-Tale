package games.sunlightGame.core
{
	import com.greensock.TweenMax;
	import com.neriksworkshop.lib.ASaudio.Track;
	
	import flash.display.MovieClip;
	import flash.display.StageOrientation;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.StageOrientationEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.utils.setTimeout;
	
	import control.EventController;
	
	import events.ViewEvent;
	
	import games.sunlightGame.managers.BulletManager;
	import games.sunlightGame.managers.CollisionManager;
	import games.sunlightGame.managers.EnemyManager;
	import games.sunlightGame.managers.ExplosionManager;
	import games.sunlightGame.objects.GameLost;
	import games.sunlightGame.objects.GameWon;
	import games.sunlightGame.objects.Health;
	import games.sunlightGame.objects.Hero;
	import games.sunlightGame.objects.Nero;
	import games.sunlightGame.objects.StartGame;
	
	import model.DataModel;
	
	import util.SWFAssetLoader;
	
	public class Game extends MovieClip
	{
		
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
		private var _speedTimer:int = 12000;
		private var _glowingLight:MovieClip;
		private var _underGlow:MovieClip;
		private var _health:Health;
		
		private var _hitCount:int = 0;
		public var allowedHits:int = 5;
		private var _cannonSound:Track;
		
		public function Game()
		{
			_SAL = new SWFAssetLoader("capitol.SunlightGameMC", this);
			EventController.getInstance().addEventListener(ViewEvent.ASSET_LOADED, init);
		}
		
		public function destroy():void {
			if (hasEventListener(Event.ENTER_FRAME)) {
				removeEventListener(Event.ENTER_FRAME, update);
			}
			
//			WTF???? crashey
//			_mc.stopAllMovieClips();
			TweenMax.killAll();
			
			stage.removeEventListener( StageOrientationEvent.ORIENTATION_CHANGE, onOrientationChange ); 
			stage.setOrientation( StageOrientation.DEFAULT );
			stage.autoOrients = false;
			
			hero.destroy();
			hero = null;
			nero.destroy();
			nero = null;
			
			_glowingLight = null;
			_underGlow = null;
			_health = null;
			
			_startGame.destroy();
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
			
			bulletHolder = null;
			enemyHolder = null;
			explosionHolder = null;
			dropHolder = null;
			lightSource = null;
			
			_bgMusic.stop();
			_bgMusic = null;
			
			_cannonSound = null;
			
			_gameTimer.stop();
			_gameTimer = null;
			
			DataModel.getInstance().removeAllChildren(_mc);
			_SAL.destroy();
			_SAL = null;
			removeChild(_mc);
			_mc = null;
		}
		
		protected function mcAdded(event:Event):void
		{
			_mc.removeEventListener(Event.ADDED_TO_STAGE, mcAdded);
			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.MC_READY));
		}
		
		private function init(event:Event):void
		{
			EventController.getInstance().removeEventListener(ViewEvent.ASSET_LOADED, init);
			_mc = _SAL.assetMC;
			
			_mc.addEventListener(Event.ADDED_TO_STAGE, mcAdded);

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
			
			_health = new Health(this, _mc.health_mc);
			
			_glowingLight = _mc.machine_mc.glow_mc;
			_glowingLight.alpha = 0;
			
			_underGlow = _mc.machine_mc.underglow_mc;
			_underGlow.alpha = 0;
			
			//GRAPHICS
			DataModel.getInstance().setGraphicResolution(_mc.bg_mc);
			DataModel.getInstance().setGraphicResolution(_mc.startGame_mc.overlay_mc);
			DataModel.getInstance().setGraphicResolution(_mc.gameLost_mc.overlay_mc);
			DataModel.getInstance().setGraphicResolution(_mc.gameWon_mc.overlay_mc);
			DataModel.getInstance().setGraphicResolution(_mc.machine_mc.shadow_mc);
			DataModel.getInstance().setGraphicResolution(_mc.machine_mc.machine_mc);
			
			addChild(_mc);
			
			stage.autoOrients = true;
			
			stage.addEventListener( StageOrientationEvent.ORIENTATION_CHANGE, onOrientationChange ); 
//			stage.addEventListener(	StageOrientationEvent.ORIENTATION_CHANGING, onOrientationChanging );
			// didn't have to bother with the above, the below locks it in portrait mode
//			stage.setAspectRatio(StageAspectRatio.PORTRAIT); SET IN default class
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
			_bgMusic = new Track("assets/audio/games/sunlightGame/capitol_GAME_MUSIC.mp3");
			_bgMusic.start(true);
			_bgMusic.loop = true;
			_bgMusic.fadeAtEnd = true;
			
			_cannonSound = new Track("assets/audio/games/sunlightGame/capitol_CanonShoot.mp3");
			
			_gameTimer.start();
			
			TweenMax.allTo([_glowingLight, _underGlow], 1.5, {alpha:1, yoyo:true, repeat:-1, delay:1}); 
			
		}
		
		private function heroOn():void  {
			stage.addEventListener(MouseEvent.MOUSE_DOWN, onDown);
			stage.addEventListener(MouseEvent.MOUSE_UP, onUp);
		}
		
		private function onDown(event:MouseEvent):void
		{
			fire = true;
			bulletManager.fire();
			_cannonSound.start();
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
//			trace("gameOver: "+winOrLose);
			
			_gameTimer.stop();
			removeEventListener(Event.ENTER_FRAME, update);
			
			stage.removeEventListener(MouseEvent.MOUSE_DOWN, onDown);
			stage.removeEventListener(MouseEvent.MOUSE_UP, onUp);
			
			enemyManager.gameOver();
			hero.gameOver();
			
			_bgMusic.stop(true);
			
			if (winOrLose == "winner") {
				_mc.gameWon_mc.visible = true;
			} else {
				_mc.gameLost_mc.visible = true;
				DataModel.getInstance().endSound();
			}
			
//			WTF???? this was causing crashes
//			_mc.stopAllMovieClips();
			
			TweenMax.killAll();
		}
		
		public function gameCompleted(thisPageObj:Object):void
		{
//			trace("gameCompleted");
//			_mc.stopAllMovieClips();
//			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.DECISION_CLICK, tempObj));
			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.DECISION_CLICK, thisPageObj));
		}
		
//		public function gameLost(thisPageObj:Object):void {
//			trace("gameLost");
////			_mc.stopAllMovieClips();
//			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.DECISION_CLICK, thisPageObj));
//		}
		
		public function heroHit():void
		{
			_hitCount++;
			// update health bar
			_health.heroHit();
			
			if (_hitCount > allowedHits-1) {
//				
				gameOver("LOSER");
			}
		}
	}
}