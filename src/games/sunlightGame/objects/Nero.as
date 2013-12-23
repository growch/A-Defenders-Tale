package games.sunlightGame.objects
{
	import flash.display.MovieClip;
	
	import games.sunlightGame.core.Game;
	
	import model.DataModel;
	
	public class Nero extends MovieClip
	{
		private var _game:Game;
		private var _mc:MovieClip;
		private var _head:MovieClip;
		private var counter:int;
		private var faceTime:int = 10;
		private var _normal:MovieClip;
		private var _evil:MovieClip;
		private var _mad:MovieClip;
		private var _laughing:MovieClip;

		public function Nero(game:Game, mc:MovieClip)
		{
			_game = game; 
			_mc = mc;
			_head = _mc.head_mc;
			
			_normal = _head.normal_mc;
			_evil = _head.evil_mc;
			_mad = _head.mad_mc;
			_laughing = _head.laughing_mc;
			
			_mad.visible = false;
			_evil.visible = false;
			_laughing.visible = false;
			
			//GRAPHICS
			DataModel.getInstance().setGraphicResolution(mc.body_mc);
			DataModel.getInstance().setGraphicResolution(_normal);
			DataModel.getInstance().setGraphicResolution(_evil);
			DataModel.getInstance().setGraphicResolution(_mad);
			DataModel.getInstance().setGraphicResolution(_laughing);
		}
		
		public function destroy():void
		{
			_game = null;
			_mc = null;
			_head = null;
			
			_normal = null;
			_evil = null;
			_mad = null;
			_laughing = null;
		}
		
		private function showFace(thisFace:MovieClip) :void {
			_normal.visible = false;
			_mad.visible = false;
			_evil.visible = false;
			_laughing.visible = false;
			
			thisFace.visible = true;
		}
		
		public function get neroMC():MovieClip {
			return _mc;
		}
		
		public function spawn():void {
//			_head.gotoAndStop("laughing");
			showFace(_laughing);
			counter = 0;
		}
		
		public function getSunlight():void {
//			_head.gotoAndStop("evil");
			showFace(_evil);
			counter = 0;
		}
		
		public function enemyHit():void {
//			_head.gotoAndStop("mad");
			showFace(_mad);
			counter = 0;
		}
		
		public function update():void
		{
			counter++;
			
			if (counter > faceTime) {
//				_head.gotoAndStop(1);
				showFace(_normal);
			}

		}
		
		
	}
}