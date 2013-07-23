package games.sunlightGame.objects
{
	import flash.display.DisplayObject;
	import flash.geom.Point;
	
	import org.flintparticles.common.actions.Age;
	import org.flintparticles.common.counters.Blast;
	import org.flintparticles.common.displayObjects.Line;
	import org.flintparticles.common.initializers.ColorInit;
	import org.flintparticles.common.initializers.Lifetime;
	import org.flintparticles.common.initializers.SharedImage;
	import org.flintparticles.twoD.actions.Move;
	import org.flintparticles.twoD.actions.RotateToDirection;
	import org.flintparticles.twoD.actions.ScaleAll;
	import org.flintparticles.twoD.emitters.Emitter2D;
	import org.flintparticles.twoD.initializers.Velocity;
	import org.flintparticles.twoD.zones.DiscZone;
	
	public class Sparkler extends Emitter2D
	{
		public function Sparkler( renderer:DisplayObject )
		{
			counter = new Blast( 100 );
			
			addInitializer( new SharedImage( new Line( 8 ) ) );
			addInitializer( new ColorInit( 0xFFFFCC00, 0xFFfffe1c ) );
			addInitializer( new Velocity( new DiscZone( new Point( 0, 0 ), 200, 100 ) ) );
			addInitializer( new Lifetime( 0.1, 0.3 ) );
			
			addAction( new Age() );
			addAction( new Move() );
			addAction( new RotateToDirection() );
			addAction( new ScaleAll(1, 2) );
			
		}
	}
}