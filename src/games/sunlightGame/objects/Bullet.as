package games.sunlightGame.objects
{
	import flash.display.MovieClip;
	
	import assets.sunlightGame.CanonballMC;
	
	import model.DataModel;
	
	public class Bullet extends MovieClip
	{
		private var _mc:MovieClip;
		
		public function Bullet()
		{
			_mc = new CanonballMC();
			//GRAPHICS
			DataModel.getInstance().setGraphicResolution(_mc);
			addChild(_mc);
			
		}
		
		public function explode():void
		{
//			_mc.play();
			// _mc gets removed by actions layer after explosion
		}
	}
}