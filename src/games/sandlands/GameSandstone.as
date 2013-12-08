package games.sandlands
{
	import com.greensock.TweenMax;
	import com.neriksworkshop.lib.ASaudio.Track;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.utils.setTimeout;
	
	import control.EventController;
	
	import events.ViewEvent;
	
	import games.sandlands.managers.EnemyManager;
	import games.sandlands.objects.CountdownClock;
	import games.sandlands.objects.GameLost;
	import games.sandlands.objects.GameWon;
	import games.sandlands.objects.RetryGame;
	import games.sandlands.objects.StartGame;
	
	import model.DataModel;
	
	import util.SWFAssetLoader;
	
	public class GameSandstone extends MovieClip
	{
		
		public var DURATION:int = 15; // in seconds
		
		private var _mc:MovieClip;
		public var enemyManager:EnemyManager; 
		private var _countdownClock:CountdownClock;
		private var _timer:int;
		private var _gameTimer:Timer;
		private var _bgMusic:Track;
		private var _startGame:StartGame;
		private var _tryAgain:RetryGame;
		private var _gameWon:GameWon;
		private var _gameLost:GameLost;
		private var _SAL:SWFAssetLoader;
		private var _objIndex:Number;
		private var _allowedAttempts:int = 5;
		private var _attempts:int = 0;
		private var _bgSound:Track;
		private var _tapSound:Track;
		private var _owlSound:Track;
		
		
		public function GameSandstone()
		{
			_SAL = new SWFAssetLoader("sandlands.SandstoneGameMC", this);
			EventController.getInstance().addEventListener(ViewEvent.ASSET_LOADED, init);
			
			EventController.getInstance().addEventListener(ViewEvent.SAND_GAME_STONE_FOUND, stoneFound);
			EventController.getInstance().addEventListener(ViewEvent.SAND_GAME_OWL_SOUND, owlSound);
			EventController.getInstance().addEventListener(ViewEvent.SAND_GAME_CLICK_SOUND, tapSound);
		}
		
		protected function stoneFound(event:ViewEvent):void
		{
			stopGame();
			TweenMax.delayedCall(.5, showGameWon);
		}
		
		private function showGameWon():void {
			_mc.gameWon_mc.visible = true;
		}
		
		public function destroy():void {
			EventController.getInstance().removeEventListener(ViewEvent.SAND_GAME_STONE_FOUND, stoneFound);
			EventController.getInstance().removeEventListener(ViewEvent.SAND_GAME_OWL_SOUND, owlSound);
			EventController.getInstance().removeEventListener(ViewEvent.SAND_GAME_CLICK_SOUND, tapSound);
			
			enemyManager.destroy();
			enemyManager = null;
			
			_startGame.destroy();
			_tryAgain.destroy();
			_gameWon.destroy();
			_gameLost.destroy();
			
			_gameWon = null;
			_tryAgain = null;
			_startGame = null;
			_gameLost = null;
			
			_gameTimer.stop();
			_gameTimer.removeEventListener(TimerEvent.TIMER, timerTick);
			_gameTimer = null;
			
//			_timer = null;
//			
//			_objIndex = null;
//			_allowedAttempts = null;
//			_objIndex = null;
			
			_bgMusic.stop(true);
			_bgMusic = null;
			
			_countdownClock.destroy();
			_countdownClock = null;
			
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
		
		private function init(e:ViewEvent) : void {
			EventController.getInstance().removeEventListener(ViewEvent.ASSET_LOADED, init);
			_mc = _SAL.assetMC;
			
			_mc.addEventListener(Event.ADDED_TO_STAGE, mcAdded);
			
			_mc.frame_mc.mouseEnabled = false;
			_mc.frame_mc.mouseChildren = false;
			
			_startGame = new StartGame(this, _mc.startGame_mc);
//			
			_tryAgain = new RetryGame(this, _mc.tryAgain_mc);
			_mc.tryAgain_mc.visible = false;
//			
			_gameWon = new GameWon(this, _mc.gameWon_mc);
			_mc.gameWon_mc.visible = false;
			
			_gameLost = new GameLost(this, _mc.gameLost_mc);
			_mc.gameLost_mc.visible = false;
//			
			_countdownClock = new CountdownClock(_mc.countdown_mc, this);
//			
			_timer = DURATION;
//			
			_gameTimer = new Timer(1000);
			_gameTimer.addEventListener(TimerEvent.TIMER, timerTick);
			
			//LOW RES GRAPHICS
			DataModel.getInstance().setGraphicResolution(_mc.bg_mc);
			DataModel.getInstance().setGraphicResolution(_mc.frame_mc.top_mc);
			DataModel.getInstance().setGraphicResolution(_mc.frame_mc.mid_mc);
			DataModel.getInstance().setGraphicResolution(_mc.frame_mc.bottom_mc);
			DataModel.getInstance().setGraphicResolution(_mc.startGame_mc.graphic_mc);
			DataModel.getInstance().setGraphicResolution(_mc.tryAgain_mc.graphic_mc);
			DataModel.getInstance().setGraphicResolution(_mc.gameWon_mc.graphic_mc);
			DataModel.getInstance().setGraphicResolution(_mc.gameLost_mc.graphic_mc);
			
			addChild(_mc);
			
		}
		
		public function startGame():void {
			_mc.startGame_mc.visible = false;
			
			enemyManager = new EnemyManager(_mc.enemies_mc);
			
			hideStone();
//			
			_countdownClock.startClock();
			_gameTimer.start();
//			// audio
			_bgMusic = new Track("assets/audio/games/sandlands/sandlands_game.mp3");
			_bgMusic.start(true);
			_bgMusic.loop = true;
			_bgMusic.fadeAtEnd = true;
			_bgMusic.volumeMultiplier = 2;
			
			_bgSound = new Track("assets/audio/sandlands/sandlands_SL_15.mp3");
			_bgSound.start(true);
			_bgSound.loop = true;
			_bgSound.fadeAtEnd = true;
			_bgSound.volume = .5;
			
			_tapSound = new Track("assets/audio/sandlands/sandlands_WizardObjectTap.mp3");
			_owlSound = new Track("assets/audio/sandlands/sandlands_SL_16_OWL.mp3");
		}
		
		private function tapSound(e:ViewEvent):void {
			_tapSound.start();
		}
		
		private function owlSound(e:ViewEvent):void {
			_owlSound.start();
		}
		
		private function hideStone():void {
			_attempts++;
			_objIndex = Math.round(DataModel.getInstance().randomRange(0,enemyManager.enemies.length-1)); 
			enemyManager.hideStone(_objIndex);
		}
		
		protected function timerTick(event:TimerEvent):void
		{
			_timer--;
			
			_countdownClock.updateClock(_timer);
			
			if (_timer <= 0)
			{
				stopGame();
					
				if (_attempts < _allowedAttempts) {
					_mc.tryAgain_mc.visible = true;
				} else {
					_mc.gameLost_mc.visible = true;
				}
			}
		}
		
		private function stopGame():void {
			_gameTimer.stop();
			_bgMusic.stop(true);
			_bgSound.stop(true);
		}
		
		
		public function restartGame():void
		{
			_mc.tryAgain_mc.visible = false;
			
			enemyManager.reset();
			
			hideStone();
			
			_timer = DURATION;
				
			_gameTimer.reset();
			_gameTimer.start();
			_countdownClock.startClock();
			_bgMusic.start();
		}
		
		public function gameCompleted():void
		{
			var tempObj:Object = new Object();
			tempObj.id = "sandlands.SandstoneWinView";
			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.DECISION_CLICK, tempObj));
		}
		
		public function gameLost(thisPageObj:Object):void {
			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.DECISION_CLICK, thisPageObj));
		}
	}
}