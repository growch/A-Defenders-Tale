package games.sunlightGame.managers
{
	import com.neriksworkshop.lib.ASaudio.Track;
	
	import flash.display.MovieClip;
	
	import games.sunlightGame.core.Game;
	import games.sunlightGame.objects.Bullet;
	import games.sunlightGame.objects.Enemy;
	

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
			_hitSound = new Track("assets/audio/games/sunlightGame/hitEnemy.mp3");
			_ea = _game.enemyManager.enemies;
		}
		
		public function update():void
		{
			// alternates so both not happening every single frame
			if(count & 1) {
				bulletsAndEnemies();
				bulletsAndBlocks();	
			}		
			else {
				heroAndEnemies();
			}
				
			count++;
		}
		
		private function heroAndEnemies():void
		{
			_ea = _game.enemyManager.enemies;
//			var enem:Enemy;
			
			
			for(var i:int=_ea.length-1; i>=0; i--)
			{
				_enem = _ea[i];
//				
//				if(!_enem.showing) continue;
//				
				_hit = _enem.hitMC;
//				
//				if (_hit.height <= 1) continue;
//				trace(_game.hero.hitMC);
//				
//				if(_game.hero.hit1MC.hitTestObject(_hit) || _game.hero.hit2MC.hitTestObject(_hit))
				if(_game.hero.hit1MC.hitTestObject(_hit))
				{
//					_enem.hitEnemy();
//					_game.explosionManager.spawn(_game.stage.mouseX, _game.stage.mouseY);
					_hitSound.start();
					_game.gameOver();
					return;
				}
			}
		}
		
		private function enemiesAndBlocks():void
		{
			_ea = _game.enemyManager.enemies;
			var bla:Array = _game.blockArray;
			//			var enem:Enemy;
			var block:MovieClip;
			
			for(var i:int=_ea.length-1; i>=0; i--)
			{
				_enem = _ea[i];
				_hit = _enem.hitMC;
				
				for(var j:int=bla.length-1; j>=0; j--)
				{
					block = bla[j];
					
					if (_hit.hitTestObject(block)) {
//						_game.bulletManager.destroyBullet(b);
					}
				}

			}
		}
		
		private function bulletsAndEnemies():void
		{
			var ba:Array = _game.bulletManager.bullets;
			var ea:Array = _game.enemyManager.enemies;
			
			var b:Bullet;
//			var e:En;
			
			for(var i:int=ba.length-1; i>=0; i--)
			{
				b = ba[i];
				for(var j:int=ea.length-1; j>=0; j--)
				{
					_enem = ea[j];
					_hit = _enem.hitMC;
					
					if (b.hitTestObject(_hit)) {
						_game.explosionManager.spawn(_enem.x, _enem.y);
						_game.enemyManager.destroyEnemy(_enem);
						_game.bulletManager.destroyBullet(b);
//						_hitSound.start();
					}
				}
			}
		}
		
		private function bulletsAndBlocks():void
		{
			var ba:Array = _game.bulletManager.bullets;
			var bla:Array = _game.blockArray;
			
			var b:Bullet;
			var block:MovieClip;
			
			for(var i:int=ba.length-1; i>=0; i--)
			{
				b = ba[i];
				for(var j:int=bla.length-1; j>=0; j--)
				{
					block = bla[j];
					
					if (b.hitTestObject(block)) {
						_game.bulletManager.destroyBullet(b);
					}
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