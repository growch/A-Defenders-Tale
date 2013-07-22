package games.sunlightGame.managers
{
	import com.leebrimelow.starling.StarlingPool;
	
	import assets.sunlightGame.EnemyMC;
	
	import games.sunlightGame.core.Game;
	import games.sunlightGame.objects.Enemy;
	
	import model.DataModel;
	
	
	public class EnemyManager
	{
		private var game:Game;
		public var enemies:Array;
		private var pool:StarlingPool;
		public var count:int = 0;
		private var _bottom:Number = DataModel.APP_HEIGHT;
		
		public function EnemyManager(game:Game)
		{
			this.game = game;
			enemies = new Array();
			pool = new StarlingPool(Enemy, 50);
		}
		
		public function update():void
		{
			if(Math.random() < 0.05)
				spawn();
			
			var e:Enemy;
			var len:int = enemies.length;
			
			for(var i:int=len-1; i>=0; i--)
			{
				e = enemies[i];
				e.y += 8;
				if(e.y > _bottom)
					destroyEnemy(e);
			}
		}
		
		private function spawn():void
		{
			var e:Enemy = pool.getSprite() as Enemy;
			enemies.push(e);
			e.y = -50;
			e.x = Math.random() * 700 + 50;
			game.enemyHolder.addChild(e);
		}
		
		public function destroyEnemy(e:Enemy):void
		{
			var len:int = enemies.length;
			
			for(var i:int=0; i<len; i++)
			{
				if(e == enemies[i])
				{
//					e.destroy();
					enemies.splice(i, 1);
					game.enemyHolder.removeChild(e);
					pool.returnSprite(e);
				}
			}
			
		}
		
		public function destroy():void
		{
			pool.destroy();
			pool = null;
			enemies = null;
		}
	}
}