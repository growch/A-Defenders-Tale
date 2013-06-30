package games.bopMice.managers
{
	
	import flash.display.MovieClip;
	
	import games.bopMice.objects.Enemy;
	
	public class EnemyManager
	{
		private var _enemsMC:MovieClip;
		public var enemies:Array;
		public var count:int = 0;
		private var _enemyCount:int;
		private var _len:int;
		private var _enemy:Enemy;
		
		public function EnemyManager(enemsMC:MovieClip)
		{
			_enemsMC = enemsMC;
			enemies = new Array();
			_enemyCount = _enemsMC.numChildren;
			addEnemies();
			
			_len = enemies.length;
		}
		
		private function addEnemies():void {
			var enem:Enemy
			for (var i:int = 0; i < _enemyCount; i++) 
			{
				enem = new Enemy(_enemsMC.getChildByName("mouse"+i) as MovieClip);
				enemies.push(enem);
			}
		}
		
		public function update():void
		{
			if(Math.random() < 0.04) spawn();
			
//			var en:Enemy;
//			var len:int = enemies.length;
			
			for(var i:int=_len-1; i>=0; i--)
			{
				_enemy = enemies[i];
				_enemy.update();
			}
		}
		
		private function spawn():void
		{
			var randomEnemyIndex:int = Math.floor(Math.random() * _enemyCount);
			var thisEnem:Enemy = enemies[randomEnemyIndex];
			if (thisEnem.showing) {
				return;
			}
			thisEnem.showEnemy();
		}
		
		
		public function destroy():void
		{
			enemies = null;
			_enemsMC = null;
		}
		
		public function killAll():void
		{
			var en:Enemy;
			var len:int = enemies.length;
			
			for(var i:int=len-1; i>=0; i--)
			{
				en = enemies[i];
				if (en.showing) {
					en.hideEnemy();
				}
				
			}
		}
	}
}