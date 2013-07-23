package games.sunlightGame.managers
{
	import com.leebrimelow.starling.StarlingPool;
	
	import games.sunlightGame.core.Game;
	import games.sunlightGame.objects.Bullet;

	public class BulletManager
	{
		private var game:Game;
		public var bullets:Array;
		private var pool:StarlingPool;
		public var count:int = 0;
		
		public function BulletManager(game:Game)
		{
			this.game = game;
			bullets = new Array();
			pool = new StarlingPool(Bullet, 50);
		}
		
		public function update():void
		{
			var b:Bullet;
			var len:int = bullets.length;
//			trace("len: "+len);
			
			for(var i:int=len-1; i>=0; i--)
			{
				b = bullets[i];
				b.y -= 12;
				if(b.y < 0)
					destroyBullet(b);
			}
			
//			if(game.fire && count%10 == 0)
//				fire();
			
			count++;
		}
		
		public function fire():void
		{
//			trace("fire");
			var b:Bullet = pool.getSprite() as Bullet;
			game.bulletHolder.addChild(b);
			b.x = game.hero.player.x;
			b.y = game.hero.player.y - 75;
			bullets.push(b);
		}
		
		public function destroyBullet(b:Bullet):void
		{
			var len:int = bullets.length;
			
			for(var i:int=0; i<len; i++)
			{
				if(bullets[i] == b)
				{
					bullets.splice(i, 1);
//					b.removeFromParent(true);
					game.bulletHolder.removeChild(b);
//					b.explode();
					pool.returnSprite(b);
				}
			}

		}
		
		public function destroy():void
		{
			pool.destroy();
			pool = null;
			bullets = null;
		}
	}
}