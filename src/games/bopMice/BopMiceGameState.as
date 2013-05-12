package
{
	
	import FrameSprite;
	
	import assets.Mallet;
	
	import com.citrusengine.core.CitrusObject;
	import com.citrusengine.core.StarlingState;
	import com.citrusengine.objects.CitrusSprite;
	import com.citrusengine.physics.box2d.Box2D;
	import com.citrusengine.system.components.box2d.hero.HeroViewComponent;
	import com.citrusengine.view.spriteview.SpriteArt;
	
	import flash.ui.Mouse;
	
	import starling.core.Starling;
	import starling.display.Image;
	import starling.display.MovieClip;
	import starling.display.Quad;
	import starling.events.EnterFrameEvent;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;
	
	public class BopMiceGameState extends StarlingState
	{
		
		[Embed(source="assets/bopMiceBG.jpg")]
		private var bg:Class;
		
		
		[Embed(source="assets/mallet.xml", mimeType="application/octet-stream")]
		private var _malletAtlas:Class;
		
		[Embed(source="assets/mallet.png")]
		private var _malletTexture:Class;
		
		private var player:FrameSprite;
		
		public function BopMiceGameState()
		{
			super();
		}
		
		override public function initialize():void 
		{
			super.initialize();
			
			var physics:Box2D = new Box2D("box2d");
			add(physics);
			
			var background:CitrusSprite = new CitrusSprite('bg');
			background.view = new bg();
			add(background);
			
			var texture:Texture = Texture.fromBitmap(new _malletTexture());
			var xml:XML = XML(new _malletAtlas());
			var atlas:TextureAtlas = new TextureAtlas(texture, xml);
			var malletIdle:MovieClip = new MovieClip(atlas.getTextures("mallet-idle"), 15);
			var malletHit:MovieClip = new MovieClip(atlas.getTextures("mallet-hit"), 15);
			Starling.juggler.add(malletIdle);
			Starling.juggler.add(malletHit);
			
			malletHit.loop = false;
			
			player = new FrameSprite();
			//we add the player sprite to the stage
			addChild(player);
//			player.loop = false;
			
			//first we must add a frame to the FrameSprite
			player.addFrame("idle");
			//with the addChildToFrame function you can add a mc to a specific frame within the player sprite a frame, both frame number and framelaber work here.
			player.addChildToFrame(malletIdle, "idle");
			
			//here we do the same as shown above but we give the seccond frame a diffrent name.
			player.addFrame("hit");
			player.addChildToFrame(malletHit, "hit");
			player.loop = false;

			stage.addEventListener(TouchEvent.TOUCH, onTouch);
			
		}
		
		private function onTouch(e:TouchEvent):void
		{
			var touch:Touch = e.getTouch(stage);
			if(touch)
			{
				if(touch.phase == TouchPhase.BEGAN)
				{
//					trace("down");
					player.gotoAndPlay("hit");
				}
					
				else if(touch.phase == TouchPhase.ENDED)
				{
//					trace("up");
					player.gotoAndStop("idle");
				}
					
//				else if(touch.phase == TouchPhase.MOVED)
				else if(touch.phase == TouchPhase.HOVER || touch.phase == TouchPhase.MOVED)
				{
					player.x = touch.globalX-(player.width/2)+20;
					player.y = touch.globalY-(player.height/2)+20;
				}
			}
			
		}
	}
}