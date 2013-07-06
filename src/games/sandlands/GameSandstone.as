package games.sandlands
{
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
		
		public static const FPS:int = DataModel.BOP_MICE_FPS; 
//		public static const DURATION:int = 15; // in seconds
		public var DURATION:int = 15; // in seconds
		
		private var _mc:MovieClip;
		public var enemyManager:EnemyManager; 
		private var _countdownClock:CountdownClock;
		private var _timer:int;
		private var _gameTimer:Timer;
		private var _bgMusic:Track;
		private var _startGame:MovieClip;
		private var _tryAgain:MovieClip;
		private var _gameWon:GameWon;
		private var _gameLost:GameLost;
		private var _SAL:SWFAssetLoader;
		private var _objIndex:Number;
		private var _allowedAttempts:int = 5;
		private var _attempts:int = 0;
		
		
		public function GameSandstone()
		{
			_SAL = new SWFAssetLoader("sandlands.SandlandsGameMC", this);
			EventController.getInstance().addEventListener(ViewEvent.ASSET_LOADED, init);
			
			EventController.getInstance().addEventListener(ViewEvent.SAND_GAME_STONE_FOUND, stoneFound);
		}
		
		protected function stoneFound(event:ViewEvent):void
		{
			stopGame();
			setTimeout(function():void {_mc.gameWon_mc.visible = true;}, 500);
		}
		
		private function init(event:Event):void
		{
			EventController.getInstance().removeEventListener(ViewEvent.ASSET_LOADED, init);
			_mc = _SAL.assetMC;
			
			_mc.frame_mc.mouseEnabled = false;
			_mc.frame_mc.mouseChildren = false;
			
			_startGame = new StartGame(this, _mc.startGame_mc);
//			_mc.startGame_mc.visible = false;
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
//			_timer = GameSandlands.DURATION;
			_timer = DURATION;
//			
			_gameTimer = new Timer(1000);
			_gameTimer.addEventListener(TimerEvent.TIMER, timerTick);
			
			addChild(_mc);
			
//			startGame();
		}
		
		public function startGame():void {
			_mc.startGame_mc.visible = false;
//			
			enemyManager = new EnemyManager(_mc.enemies_mc);
			
			hideStone();
//			
			_countdownClock.startClock();
			_gameTimer.start();
//			addEventListener(Event.ENTER_FRAME, update);
//			// audio
			_bgMusic = new Track("assets/audio/games/bopMice/bg.mp3");
//			_bgMusic.start(true);
			_bgMusic.loop = true;
			
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
//				removeEventListener(Event.ENTER_FRAME, update);
//				enemyManager.killAll();
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
		}
		
		
//		private function update(event:Event):void
//		{
//			enemyManager.update();
//		}
		
		public function destroy():void {
			//TODO!!!!!! clean everything UP!!!!!!!!
//			removeEventListener(Event.ENTER_FRAME, update);
			EventController.getInstance().removeEventListener(ViewEvent.SAND_GAME_STONE_FOUND, stoneFound);
			
			enemyManager.destroy();
			
			_gameWon.destroy();
			_tryAgain.destroy();
			
			_gameTimer = null;
			
			_bgMusic.stop(true);
			_bgMusic = null;
			
			DataModel.getInstance().removeAllChildren(_mc);
			
			_SAL.destroy();
			_SAL = null;
		}
		
		public function restartGame():void
		{
			_mc.tryAgain_mc.visible = false;
			
			enemyManager.reset();
			
			hideStone();
//			addEventListener(Event.ENTER_FRAME, update);
			
//			_timer = GameSandlands.DURATION;
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