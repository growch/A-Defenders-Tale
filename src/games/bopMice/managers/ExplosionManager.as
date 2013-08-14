package games.bopMice.managers
{
	import games.bopMice.core.Game;
	import games.bopMice.objects.StarExplosion;
	
	public class ExplosionManager
	{
		private var _game:Game;
		public var explosion:StarExplosion;
		
		public function ExplosionManager(game:Game)
		{
			_game = game;
			explosion = new StarExplosion();
			_game.addChild(explosion);
		}
		
		public function spawn(x:int, y:int):void
		{
			explosion.shootStars(x, y);
		}
		
		public function destroy():void
		{
			_game.removeChild(explosion);
			explosion.destroy();
			explosion = null;
			_game = null;
		}
	}
}