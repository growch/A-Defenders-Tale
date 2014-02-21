package games.sunlightGame.objects
{
	import flash.display.MovieClip;
	
	import games.sunlightGame.core.Game;
	
	import model.DataModel;
	
	public class Health extends MovieClip
	{
		private var _game:Game;
		private var _mc:MovieClip;
		private var _hitCount:int;
		private var _allowedHits:int;

		public function Health(game:Game, mc:MovieClip)
		{
			_game = game; 
			_mc = mc;
			
			_hitCount = _game.allowedHits;
					
			for (var i:int = 1; i <= _hitCount; i++) 
			{
				var thisHeart:MovieClip = _mc["heart"+i+"_mc"];
				//GRAPHICS
				DataModel.getInstance().setGraphicResolution(thisHeart.empty_mc);
				DataModel.getInstance().setGraphicResolution(thisHeart.full_mc);
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