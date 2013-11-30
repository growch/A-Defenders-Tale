package games.bopMice.managers
{
	import flash.display.Sprite;
	
	import games.bopMice.core.Game;
	import games.bopMice.objects.StarExplosion;
	
	public class ExplosionManager extends Sprite
	{
		private var _game:Game;
		public var explosion:StarExplosion;
		
		public function ExplosionManager(game:Game)
		{
			_game = game;
			explosion = new StarExplosion();
			_game.explosionHolder.addChild(explosion);
		}
		
		public function spawn(x:int, y:int):void
		{
			explosion.shootStars(x, y);
		}
		
		public function destroy():void
		{
			_game.explosionHolder.removeChild(explosion);
			explosion.destroy();
			explosion = null;
			_game = null;
		}
	}
}