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
		private var _spawnX:Number;
		private var _spawnY:Number;
		
		public function EnemyManager(game:Game)
		{
			this.game = game;
			enemies = new Array();
			pool = new StarlingPool(Enemy, 50);
//			pool = new StarlingPool(Enemy, 1);
			
			_spawnX = game.nero.neroMC.x + Math.round(game.nero.neroMC.width/2) - 17;
			_spawnY = game.nero.neroMC.y + Math.round(game.nero.neroMC.height) + 35;
			
//			TESTING!!!!!
//			spawn();
		}
		
		public function update():void
		{
			if(Math.random() < 0.02) {
				spawn();
				game.nero.spawn();
			}
			
			var e:Enemy;
			var len:int = enemies.length;
			
			for(var i:int=len-1; i>=0; i--)
			{
				e = enemies[i];
				e.update();
				if(e.y > _bottom)
					destroyEnemy(e);
			}
		}
		
		private function spawn():void
		{
			var e:Enemy = pool.getSprite() as Enemy;
			enemies.push(e);
			e.x = _spawnX;
			e.y = _spawnY;
//			trace(game.nero.getNeroMC());
			game.enemyHolder.addChild(e);
			
			e.reset();
//			TESTING!!!!
//			e.startDrag(true);
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
		
		public function avoidBlock(e:Enemy):void
		{
			var len:int = enemies.length;
			
			for(var i:int=0; i<len; i++)
			{
				if(e == enemies[i])
				{
					e.moveLateral = true;
				}
			}
		}
	}
}