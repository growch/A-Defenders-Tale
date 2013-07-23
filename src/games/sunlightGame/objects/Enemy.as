package games.sunlightGame.objects
{
	import flash.display.MovieClip;
	
	import assets.sunlightGame.EnemyMC;
	
	
	public class Enemy extends flash.display.MovieClip 
	{
		private var _enemMC:MovieClip;
		private var _hitMC:MovieClip;
		private var _hitBigMC:MovieClip;
		
		public function Enemy()
		{
			_enemMC = new EnemyMC();
//			this.hitArea = _enemMC.getChildByName("hit_mc") as MovieClip;
//			_enemMC.getChildByName("hit_mc").alpha = .5;
			_hitMC = _enemMC.getChildByName("hitSmall_mc") as MovieClip;
			_hitBigMC = _enemMC.getChildByName("hitBig_mc") as MovieClip;
			addChild(_enemMC);
		}
		
		public function get hitMC():MovieClip {
			return _hitMC;
		}
		
		public function destroy():void {
			removeChild(_enemMC);
		}
		
		public function update():void {
			y += 8;
		}
	}
}