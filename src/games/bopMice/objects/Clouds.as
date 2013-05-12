package games.bopMice.objects
{
	import flash.display.MovieClip;
	
	import model.DataModel;
	
	public class Clouds extends MovieClip
	{
		private var _cloud1:MovieClip;
		private var _cloud2:MovieClip;
		private var _cloud3:MovieClip;
		private var _mc:MovieClip;
		
		public function Clouds(mc:MovieClip)
		{
			_mc = mc;
			_cloud1 = _mc.cloud1_mc;
			_cloud2 = _mc.cloud2_mc;
			_cloud3 = _mc.cloud3_mc;
		}
		
		public function update():void
		{
			_cloud1.x -= .3;
			if(_cloud1.x <= -_cloud1.width)
				_cloud1.x = DataModel.APP_WIDTH;
			
			_cloud2.x -= .5;
			if(_cloud2.x <= -_cloud2.width)
				_cloud2.x = DataModel.APP_WIDTH;
			
			_cloud3.x -= .4;
			if(_cloud3.x <= -_cloud3.width)
				_cloud3.x = DataModel.APP_WIDTH;
		}
	}
}