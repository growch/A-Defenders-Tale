package games.sunlightGame.managers
{
	import com.leebrimelow.starling.StarlingPool;
	
	import games.sunlightGame.core.Game;
	import games.sunlightGame.objects.Bullet;
	
	import model.DataModel;

	public class BulletManager
	{
		private var game:Game;
		public var bullets:Array;
		private var pool:StarlingPool;
		
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
				if (game.gameFlipped) {
					b.y += 12;
					if(b.y > DataModel.APP_HEIGHT)
						destroyBullet(b);
					if(b.hitTestObject(game.lightSource)) {
						game.gameOver("winner");
						return;
					}
				} else {
					b.y -= 12;
					if(b.y < 0)
						destroyBullet(b);
					
				}
			}
			
		}
		
		public function fire():void
		{
//			trace("fire");
			var b:Bullet = pool.getSprite() as Bullet;
			game.bulletHolder.addChild(b);
			b.x = game.hero.player.x;
			if (game.gameFlipped) {
				b.y = game.hero.player.y + 70;
			} else {
				b.y = game.hero.player.y - 75;
			}
			
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