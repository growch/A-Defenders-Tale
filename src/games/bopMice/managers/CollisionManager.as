package games.bopMice.managers
{
	import com.neriksworkshop.lib.ASaudio.Track;
	
	import flash.display.MovieClip;
	
	import games.bopMice.core.Game;
	import games.bopMice.objects.Enemy;
	

	public class CollisionManager
	{
		private var _game:Game;
		private var count:int = 0;
		private var _hit:MovieClip;
		private var _hitSound:Track;
		private var _ea:Array;
		private var _enem:Enemy;
		
		public function CollisionManager(game:Game)
		{
			_game = game;
			_hitSound = new Track("assets/audio/games/bopMice/hitMouse.mp3");
			_ea = _game.enemyManager.enemies;
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
//			_ea = _game.enemyManager.enemies;
//			var enem:Enemy;
			
//			trace("heroAndEnemies");
//			return;
			
			for(var i:int=_ea.length-1; i>=0; i--)
			{
				if (!_game.hero.malletDown) return;
				
				_enem = _ea[i];
				
				if(!_enem.showing) continue;
				
				_hit = _enem.hitMC;
				
				if (_hit.height <= 1) continue;
				
				if(_game.hero.hitMC.hitTestObject(_hit))
				{
					_enem.hitEnemy();
					_game.explosionManager.spawn(_game.stage.mouseX, _game.stage.mouseY);
					_game.score.addScore(1);
					_hitSound.start();
					return;
				}
			}
		}
		
		public function destroy():void
		{
			_game = null;
			_hitSound = null;
			_ea = null;
		}
	}
}