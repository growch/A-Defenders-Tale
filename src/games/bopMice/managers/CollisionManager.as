package games.bopMice.managers
{
	import com.neriksworkshop.lib.ASaudio.Track;
	
	import flash.display.MovieClip;
	import flash.display.Stage;
	
	import games.bopMice.core.Game;
	import games.bopMice.objects.Enemy;
	

	public class CollisionManager
	{
		private var _game:Game;
		private var count:int = 0;
		private var _hit:MovieClip;
		private var _hitSound:Track;
		
		public function CollisionManager(game:Game)
		{
			_game = game;
			_hitSound = new Track("assets/audio/games/bopMice/hitMouse.mp3");
		}
		
		public function update():void
		{
			// alternates so both not happening every single frame
//			if(count & 1)
//				bulletsAndAliens();
//			else
//				heroAndEnemies();
//			count++;
			heroAndEnemies();
		}
		
		private function heroAndEnemies():void
		{
			var ea:Array = _game.enemyManager.enemies;
			var enem:Enemy;
			
//			trace("heroAndEnemies");
//			return;
			
			for(var i:int=ea.length-1; i>=0; i--)
			{
				if (!_game.hero.malletDown) return;
				
				enem = ea[i];
				
				if(!enem.showing) continue;
				
				_hit = enem.hitMC;
				
				if (_hit.height <= 1) continue;
				
				if(_game.hero.hitMC.hitTestObject(_hit))
				{
//					trace("enem: "+enem.name + " || hit: " +_game.hero.hitMC.hitTestObject(enem.hitMC));
					enem.hitEnemy();
					_game.explosionManager.spawn(_game.stage.mouseX, _game.stage.mouseY);
					_game.score.addScore(1);
					//					Assets.enemyHit.play(); // sound
					_hitSound.start();
					return;
				}
			}
		}
	}
}