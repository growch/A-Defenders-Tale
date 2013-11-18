package games.sunlightGame.objects
{
	import flash.display.MovieClip;
	
	import games.sunlightGame.core.Game;
	
	public class Energy extends MovieClip
	{
		private var _game:Game;
		private var _mc:MovieClip;
		private var _hitCount:int = 5;

		public function Energy(game:Game, mc:MovieClip)
		{
			_game = game; 
			_mc = mc;
			
			for (var i:int = 1; i <= _hitCount; i++) 
			{
				var thisHeart:MovieClip = _mc["heart"+i+"_mc"];
				thisHeart.empty_mc.visible = false;
			}
			
		}
		
		public function destroy():void
		{
			_game = null;
			_mc = null;
		}
		
		public function heroHit():void {
			_mc["heart"+_hitCount+"_mc"].full_mc.visible = false;
			_mc["heart"+_hitCount+"_mc"].empty_mc.visible = true;
			_hitCount--;
		}
	}
}