package games.sunlightGame.managers
{
	import com.leebrimelow.starling.StarlingPool;
	
	import games.sunlightGame.core.Game;
	import games.sunlightGame.objects.Bullet;
	import games.sunlightGame.objects.Explosion;
	import games.sunlightGame.objects.SparklerExplosion;
	
	import model.DataModel;
	
	public class ExplosionManager
	{
		private var _game:Game;
		public var explosion:SparklerExplosion;
		private var explosions:Array;
		private var pool:StarlingPool;
		
		public function ExplosionManager(game:Game)
		{
			_game = game;
//			explosion = new SparklerExplosion();
//			_game.explosionHolder.addChild(explosion);
			
			explosions = new Array();
			pool = new StarlingPool(Explosion, 10);
		}
		
		public function destroy():void
		{
			//			_game.explosionHolder.removeChild(explosion);
			//			explosion.destroy();
			//			explosion = null;
			//			_game = null;
			
			var len:int = explosions.length;
			var exp:Explosion;
			
			for(var i:int=0; i<len; i++)
			{
				exp = explosions[i] as Explosion;
				exp.destroy();
			}
			
			pool.destroy();
			pool = null;
			explosions = null;
			explosion = null;
			_game = null;
		}
		
		public function update():void {
			var exp:Explosion;
			var len:int = explosions.length;
			
//			trace("update EXP");
			
			for(var i:int=len-1; i>=0; i--)
			{
				exp = explosions[i];
				if (exp.mc.currentFrame >= 20) {
					destroyExplosion(exp);
				}
			}	
		}
		
		private function destroyExplosion(exp:Explosion):void
		{
			var len:int = explosions.length;
			
			for(var i:int=0; i<len; i++)
			{
				if(explosions[i] == exp)
				{
					explosions.splice(i, 1);
					_game.explosionHolder.removeChild(exp);
					pool.returnSprite(exp);
				}
			}
		}
		
		public function spawn(x:int, y:int):void
		{
//			explosion.shootStars(x, y);
			
			var exp:Explosion = pool.getSprite() as Explosion;
			exp.x = x;
			exp.y = y;
			_game.explosionHolder.addChild(exp);
			exp.explode();
			
			explosions.push(exp);
		}
		
	}
}