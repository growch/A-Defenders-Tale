package games.sunlightGame.managers
{
	import com.neriksworkshop.lib.ASaudio.Track;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.geom.Point;
	
	import games.sunlightGame.core.Game;
	import games.sunlightGame.objects.Bullet;
	import games.sunlightGame.objects.Enemy;
	

	public class CollisionManager
	{
		private var _game:Game;
		private var count:int = 0;
		private var _enemHit:MovieClip;
		private var _enemHitSound:Track;
		private var _ea:Array;
		private var _enem:Enemy;
		private var p1:Point = new Point();
		private var p2:Point = new Point(); 
		private var yDistance:Number;
		private var xDistance:Number;
		private var yThresh:int = 25;
		private var leftBlockDistance:int = 33;
		private var rightBlockDistance:int;
		private var _heroHitSound:Track;
		private var _heroHeartSound:Track;
		
		public function CollisionManager(game:Game)
		{
			_game = game;
			_enemHitSound = new Track("assets/audio/games/sunlightGame/capitol_LightPop.mp3");
			_heroHitSound = new Track("assets/audio/games/sunlightGame/heroHit_laser.mp3");
			_heroHeartSound = new Track("assets/audio/games/sunlightGame/heartbeat.mp3");
			
			_heroHitSound.addEventListener(Event.COMPLETE, heroHitComplete);
			
			_ea = _game.enemyManager.enemies;
		}
		
		private function heroHitComplete(e:Event):void {
			_heroHeartSound.start();
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
				enemiesAndBlocks();
			}
				
			count++;
		}
		
		public function destroy():void
		{
			_game = null;
			_enemHitSound.destroy();
			_enemHitSound = null;
			_ea = null;
			_enemHit = null;
			_enem = null;
			_heroHitSound.removeEventListener(Event.COMPLETE, heroHitComplete);
		}
		
		private function heroAndEnemies():void
		{
			_ea = _game.enemyManager.enemies;
			
			var len:int = _ea.length-1;
			for(var i:int=len; i>=0; i--)
			{
				_enem = _ea[i];
				_enemHit = _enem.hitMC;
				
				if (!_enem.heroCollision) {
					if(_game.hero.hit1MC.hitTestObject(_enemHit))
					{
						_enem.heroCollision = true;
						_game.heroHit();
						_game.hero.showDamage();
						_heroHitSound.start();
						return;
					}
				}
//				
				
			}
		}
		
		private function enemiesAndBlocks():void
		{
			_ea = _game.enemyManager.enemies;
			var bla:Array = _game.blockArray;
			var block:MovieClip;
			
			var len:int = _ea.length-1;
			for(var i:int=len; i>=0; i--)
			{
				_enem = _ea[i];
				_enemHit = _enem.hitBigMC;
				_enem.moveLateral = false;
//				trace("_enem i: "+i);
				
				var leng:int = bla.length-1;
				
				for(var j:int=leng; j>=0; j--)
				{
					block = bla[j];

					p1.x = _enem.x;
					p1.y = _enem.y;
					p2.x = 92 + block.x;
					p2.y = 426 + block.y;

					yDistance = Math.abs(p2.y - p1.y);
					xDistance = (p2.x - p1.x);
					
					rightBlockDistance = p2.x + block.width - p1.x;

					if(yDistance < yThresh && xDistance < leftBlockDistance && rightBlockDistance > -leftBlockDistance)
					{
						
						if (yDistance < 11) {
							_enem.bounceOff();
//							trace("sideCollision");
							return;
						}
//						trace("hiTTTTT");
						_enem.moveLateral = true;
						
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
					_enemHit = _enem.hitMC;
					
					if (b.hitTestObject(_enemHit)) {
						_game.explosionManager.spawn(_enem.x, _enem.y);
						_game.enemyManager.destroyEnemy(_enem);
						_game.bulletManager.destroyBullet(b);
						_game.nero.enemyHit();
						_enemHitSound.start();
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
		
	}
}