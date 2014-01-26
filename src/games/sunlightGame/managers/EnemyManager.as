package games.sunlightGame.managers
{
	import com.leebrimelow.starling.StarlingPool;
	
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import assets.sunlightGame.SundropMC;
	
	import games.sunlightGame.core.Game;
	import games.sunlightGame.objects.Enemy;
	
	import model.DataModel;
	
	public class EnemyManager
	{
		private var game:Game;
		public var enemies:Array;
		public var sundrops:Array;
		private var pool:StarlingPool;
		private var sunpool:StarlingPool;
		public var count:int = 0;
		private var _bottom:Number = DataModel.APP_HEIGHT;
		private var _spawnX:Number;
		private var _spawnY:Number;
		private var _dropTimer:Timer;
		private var _dropFrequency:int = 2000;
		private var spawnSpeed:Number = .008;
		
		public function EnemyManager(game:Game)
		{
			this.game = game;
			enemies = new Array();
			pool = new StarlingPool(Enemy, 80);
			
			sundrops = new Array();
			sunpool = new StarlingPool(SundropMC, 10);
			
			_spawnX = game.nero.neroMC.x + Math.round(game.nero.neroMC.width/2) - 17;
			_spawnY = game.nero.neroMC.y + Math.round(game.nero.neroMC.height) + 35;
			
			_dropTimer = new Timer(_dropFrequency);
			_dropTimer.addEventListener(TimerEvent.TIMER, addDrop);
			_dropTimer.start();
			
		}
		
		public function destroy():void
		{
			_dropTimer.stop();
			_dropTimer = null;
			
			pool.destroy();
			pool = null;
			
			var e:Enemy;
			var len:int = enemies.length;
			
			for(var i:int=len-1; i>=0; i--)
			{
				e = enemies[i];
				e.destroy();
			}
			
			enemies = null;
			sunpool.destroy();
			sunpool = null;
			sundrops = null;
			game = null;
		}
		
		public function speedUp():void
		{
//			trace("SPEED UPPPP!");
			spawnSpeed += .004;
			if (_dropFrequency > 500) {
				_dropFrequency -= 500;
				_dropTimer.delay = _dropFrequency;
			}
			
		}
		
		public function update():void
		{
			if(Math.random() < spawnSpeed) {
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
			
			var s:SundropMC;
			var slen:int = sundrops.length;
			
			for(var j:int=slen-1; j>=0; j--)
			{
				s = sundrops[j];
				s.y += 3;
				
				if(s.y > game.nero.neroMC.y + 20) {
					game.nero.getSunlight();
					removeDrop(s);
				}
					
			}
		}
		
		protected function addDrop(event:TimerEvent):void
		{
			sunlightDrop();
		}
		
		private function sunlightDrop():void {
			var s:SundropMC = sunpool.getSprite() as SundropMC;
			sundrops.push(s);
			s.x = _spawnX;
			s.y = 0;
			game.dropHolder.addChild(s);
		}
		
		private function removeDrop(s:SundropMC):void
		{
			var len:int = sundrops.length;
			
			for(var i:int=0; i<len; i++)
			{
				if(s == sundrops[i])
				{
					sundrops.splice(i, 1);
					game.dropHolder.removeChild(s);
					sunpool.returnSprite(s);
				}
			}
		}
		
		
		private function spawn():void
		{
			var e:Enemy = pool.getSprite() as Enemy;
			enemies.push(e);
			e.x = _spawnX;
			e.y = _spawnY;
			game.enemyHolder.addChild(e);
			
			e.reset();
		}
		
		public function destroyEnemy(e:Enemy):void
		{
			
			var len:int = enemies.length;
			
			for(var i:int=0; i<len; i++)
			{
				if(e == enemies[i])
				{
					e.heroCollision = false;
//					e.destroy();
					enemies.splice(i, 1);
					game.enemyHolder.removeChild(e);
					pool.returnSprite(e);
				}
			}
			
		}
		
		public function gameOver():void {
			_dropTimer.stop();
			
			var e:Enemy;
			var len:int = enemies.length;
			
			for(var i:int=len-1; i>=0; i--)
			{
				e = enemies[i];
				e.gameOver();
			}
		}
		
	}
}