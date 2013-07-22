package games.sunlightGame.objects
{
	import flash.display.MovieClip;
	
	import assets.sunlightGame.EnemyMC;
	import flash.display.DisplayObject;
	
	
	public class Enemy extends flash.display.MovieClip 
	{
		private var _enemMC:MovieClip;
		private var _hitMC:MovieClip;
		
		public function Enemy()
		{
			_enemMC = new EnemyMC();
			this.hitArea = _enemMC.getChildByName("hit_mc") as MovieClip;
//			_enemMC.getChildByName("hit_mc").alpha = .5;
			addChild(_enemMC);
		}
		
		public function get hitMC():MovieClip {
			_hitMC = _enemMC.getChildByName("hit_mc") as MovieClip;
			return _hitMC;
		}
		
		public function destroy():void {
			removeChild(_enemMC);
		}
		
		public function update():void {

		}
	}
}