package games.sandlands.managers
{
	
	import flash.display.MovieClip;
	
	import games.sandlands.objects.Enemy;
	
	import model.DataModel;
	
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
				enem = new Enemy(_enemsMC.getChildAt(i) as MovieClip);
				enemies.push(enem);
			}
		}
		
		public function update():void
		{
		}
		
		
		
		public function destroy():void
		{
			for(var i:int=_len-1; i>=0; i--)
			{
				_enemy = enemies[i];
				_enemy.destroy();
			}
			
			enemies = null;
			_enemsMC = null;
		}
		
		public function reset():void
		{
			for(var i:int=_len-1; i>=0; i--)
			{
				_enemy = enemies[i];
				_enemy.reset();
			}
		}
		
		public function hideStone(_objIndex:Number):void
		{
			_enemy = enemies[_objIndex];
			_enemy.activateStone();
		}
	}
}