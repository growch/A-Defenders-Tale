package games.bopMice.states
{
	import core.Assets;
	import core.Game;
	
	import interfaces.IState;
	
	import objects.Background;
	import objects.CountdownClock;
	import objects.Score;
	
	import starling.display.Button;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.text.TextField;
	
	public class GameOver extends Sprite implements IState
	{
		private var game:Game;
		private var background:Background;
		private var overText:TextField;
		private var tryAgain:Button;
		private var score:Score;
		private var _countdownClock:CountdownClock; 
		private var frame:Image;
		
		public function GameOver(game:Game)
		{
			this.game = game;
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(event:Event):void
		{
			background = new Background();
			addChild(background);
			
			frame = new Image(Assets.frameTexture);
			addChild(frame);
			
			overText = new TextField(800, 200, "GAME OVER", "KomikaAxis", 72, 0x000000);
			overText.hAlign = "center";
			overText.y = 200;
			addChild(overText);
			
			score = new Score();
			addChild(score);
			score.x = 575;
			score.y = 75;
			score.addScore(game.userScore);
			
			_countdownClock = new CountdownClock();
			_countdownClock.x = 80;
			_countdownClock.y = 80;
			addChild(_countdownClock);
			
			tryAgain = new Button(Assets.ta.getTexture("tryAgainButton"));
			tryAgain.addEventListener(Event.TRIGGERED, onAgain);
			tryAgain.pivotX = tryAgain.width * 0.5;
			tryAgain.x = 400;
			tryAgain.y = 450;
			addChild(tryAgain);
		}
		
		private function onAgain(event:Event):void
		{
			tryAgain.removeEventListener(Event.TRIGGERED, onAgain);
			game.changeState(Game.PLAY_STATE);
		}
		
		public function update():void
		{
//			background.update();
		}
		
		public function destroy():void
		{
			removeFromParent(true);
		}
	}
}