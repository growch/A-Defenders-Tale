package games.sunlightGame.objects
{
	import flash.display.MovieClip;
	
	import games.sunlightGame.core.Game;
	
	public class Health extends MovieClip
	{
		private var _game:Game;
		private var _mc:MovieClip;
		private var _hitCount:int;
		private var _mask:MovieClip;
		private var _allowedHits:int;

		public function Health(game:Game, mc:MovieClip)
		{
			_game = game; 
			_mc = mc;
			_hitCount = _game.allowedHits;
			_mask = _mc.mask_mc;
			_allowedHits = _game.allowedHits;
		}
		
		public function destroy():void
		{
			_mask = null;
			_game = null;
			_mc = null;
		}
		
		public function heroHit():void {
			_hitCount--;
			_mask.scaleX = _hitCount/_allowedHits;
		}
	}
}