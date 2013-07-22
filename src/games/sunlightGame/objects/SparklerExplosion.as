package games.sunlightGame.objects
{
import flash.display.Sprite;
import flash.events.Event;
import flash.geom.Rectangle;

import org.flintparticles.common.events.EmitterEvent;
import org.flintparticles.twoD.emitters.Emitter2D;
import org.flintparticles.twoD.renderers.BitmapRenderer;

	public class SparklerExplosion extends Sprite
	{
			private var emitter:Emitter2D; 
			private var renderer:BitmapRenderer; 
	
			public function SparklerExplosion() : void
			{
				renderer = new BitmapRenderer( new Rectangle( 0, 0, 768, 1024) );
				addChild( renderer );
				
				emitter = new Sparkler( renderer );
				renderer.addEmitter( emitter );
				
				emitter.addEventListener( EmitterEvent.EMITTER_EMPTY, cleanUp ); 
				emitter.start();
			}
			
			protected function cleanUp(event:Event):void
			{
				emitter.stop();
//				renderer.removeEmitter( emitter );
//				removeChild( renderer );
//				renderer = null;
//				emitter = null;		
			}
			public function shootStars(x:Number, y:Number):void {
				emitter.x = x;
				emitter.y = y;
				emitter.start();
			}
			
			public function destroy():void {
				emitter.stop();
				renderer.removeEmitter( emitter );
				removeChild( renderer );
				renderer = null;
				emitter = null;	
			}
	}
}