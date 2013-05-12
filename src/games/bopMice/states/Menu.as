package games.bopMice.states
{
//	import games.bopMice.core.Assets;
	import games.bopMice.core.Game;
	
	import games.bopMice.interfaces.IState;
	
	import flash.display.Sprite;
	import flash.events.Event;
	
//	import games.bopMice.objects.Background;
	
//	import starling.display.BlendMode;
//	import starling.display.Button;
//	import starling.display.Image;
//	import starling.display.Sprite;
//	import starling.events.Event;
	
	public class Menu extends Sprite implements IState
	{
		private var game:Game;
//		private var background:Background;
//		private var frame:Image;
//		private var play:Button;
		
		public function Menu(game:Game)
		{
			this.game = game;
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(event:Event):void
		{
//			background = new Background();
//			addChild(background);
//			
//			frame = new Image(Assets.frameTexture);
//			addChild(frame);
//			
//			play = new Button(Assets.ta.getTexture("playButton"));
//			play.addEventListener(Event.TRIGGERED, onPlay);
//			play.pivotX = play.width * 0.5;
//			play.x = 389;
//			play.y = 475;
//			addChild(play);
			trace("MENU!!!");
		}
		
		private function onPlay(event:Event):void
		{
			game.changeState(Game.PLAY_STATE);
		}
		
		public function update():void
		{
//			background.update();
		}
		
		public function destroy():void
		{
//			background.removeFromParent(true);
//			background = null;
//			play.removeFromParent(true);
//			play = null;
//			removeFromParent(true);
		}
	}
}