package view.map
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.geom.Point;
	
	import control.EventController;
	
	import events.ViewEvent;
	
	import org.flintparticles.common.counters.Steady;
	import org.flintparticles.common.displayObjects.RadialDot;
	import org.flintparticles.common.initializers.ColorInit;
	import org.flintparticles.common.initializers.ImageClass;
	import org.flintparticles.common.initializers.ScaleImageInit;
	import org.flintparticles.twoD.actions.DeathZone;
	import org.flintparticles.twoD.actions.Move;
	import org.flintparticles.twoD.actions.RandomDrift;
	import org.flintparticles.twoD.emitters.Emitter2D;
	import org.flintparticles.twoD.initializers.Position;
	import org.flintparticles.twoD.initializers.Velocity;
	import org.flintparticles.twoD.renderers.DisplayObjectRenderer;
	import org.flintparticles.twoD.zones.LineZone;
	import org.flintparticles.twoD.zones.PointZone;
	import org.flintparticles.twoD.zones.RectangleZone;
	
	import view.IPageView;
	
	public class MapJoylessView extends MovieClip implements IPageView
	{
		private var _mc:MovieClip;
		private var _emitter:Emitter2D;
		private var _renderer:DisplayObjectRenderer;
		private var _stone:MovieClip;
		
		public function MapJoylessView(mc:MovieClip)
		{
			_mc = mc;
			init();
			
			EventController.getInstance().addEventListener(ViewEvent.PAGE_ON, pageOn);
		}
		
		protected function pageOn(event:Event):void
		{
			EventController.getInstance().removeEventListener(ViewEvent.PAGE_ON, pageOn);
			
			if (_emitter) {
				_emitter.start();
			}
			
		}
		
		private function init():void
		{
			_mc.snow_mc.visible = false;
			_mc.snow_mc.stop();
			
			_stone = _mc.name_mc.stone_mc;
			_stone.visible = false;
			
			//!IMPORTANT otherwise chugs on iPad1
//			if (DataModel.ipad1) { 
				_mc.snow_mc.visible = true;
				_mc.snow_mc.play();
				return;
//			}
			
			//snowfall
			_emitter = new Emitter2D();
			
			_emitter.counter = new Steady( 15 );
			
			_emitter.addInitializer( new ImageClass( RadialDot, [2] ) );
			_emitter.addInitializer(new ColorInit(4293710515,4294960329));
			_emitter.addInitializer( new Position( new LineZone( new Point( 10, -5 ), new Point( 90, -5 ) ) ) );
			_emitter.addInitializer( new Velocity( new PointZone( new Point( 0, 45 ) ) ) );
			_emitter.addInitializer( new ScaleImageInit( 1.0, 1.5 ) );
			
			_emitter.addAction( new Move() );
			_emitter.addAction( new DeathZone( new RectangleZone( -10, -10, 100, 220 ), true ) );
			_emitter.addAction( new RandomDrift( 50, 40 ) );
			
			_renderer = new DisplayObjectRenderer();
			_renderer.addEmitter( _emitter );
			_mc.cloud_mc.addChild( _renderer );
			_renderer.y = _mc.cloud_mc.height;
			
		}
		
		public function showStone():void {
			_stone.visible = true;
		}
		
		public function destroy():void {
			
			if (_emitter) {
				_emitter.stop();
				_emitter.killAllParticles();
				_renderer.removeEmitter( _emitter );
				_mc.cloud_mc.removeChild( _renderer );
				_renderer = null;
				_emitter = null;
			}
			
			_stone = null;
			
			_mc = null;
		}
	}
}