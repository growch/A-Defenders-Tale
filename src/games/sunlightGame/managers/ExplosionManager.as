package games.sunlightGame.managers
{
	import games.sunlightGame.core.Game;
	import games.sunlightGame.objects.SparklerExplosion;
	
	public class ExplosionManager
	{
		private var _game:Game;
		public var explosion:SparklerExplosion;
		
		public function ExplosionManager(game:Game)
		{
			_game = game;
			explosion = new SparklerExplosion();
			_game.addChild(explosion);
		}
		
		public function spawn(x:int, y:int):void
		{
			explosion.shootStars(x, y);
		}
		
		public function destroy():void
		{
			explosion.destroy();
			explosion = null;
			_game = null;
		}
	}
}