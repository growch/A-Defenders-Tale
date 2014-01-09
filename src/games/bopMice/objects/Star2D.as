package games.bopMice.objects
{
import flash.display.Bitmap;
import flash.display.DisplayObject;
import flash.geom.Point;

import org.flintparticles.common.actions.Age;
import org.flintparticles.common.counters.Blast;
import org.flintparticles.common.initializers.AlphaInit;
import org.flintparticles.common.initializers.CollisionRadiusInit;
import org.flintparticles.common.initializers.ColorInit;
import org.flintparticles.common.initializers.Lifetime;
import org.flintparticles.common.initializers.MassInit;
import org.flintparticles.common.initializers.ScaleImageInit;
import org.flintparticles.common.initializers.SharedImages;
import org.flintparticles.twoD.actions.Move;
import org.flintparticles.twoD.actions.Rotate;
import org.flintparticles.twoD.emitters.Emitter2D;
import org.flintparticles.twoD.initializers.Position;
import org.flintparticles.twoD.initializers.RotateVelocity;
import org.flintparticles.twoD.initializers.Rotation;
import org.flintparticles.twoD.initializers.Velocity;
import org.flintparticles.twoD.zones.DiscSectorZone;

	public class Star2D extends Emitter2D
	{
		[Embed (source="../assets/star-small.png")]
		private var imgClass_emitter_0:Class;
		private var bitmap_emitter_0:Bitmap = new imgClass_emitter_0();
		
		public function Star2D(renderer:DisplayObject) : void
		{
		var emitter_counter:Blast = new Blast(7);
		counter = emitter_counter;
		
		var emitter_action0:Move = new Move();
		var emitter_action1:Age = new Age();
		var emitter_action2:Rotate = new Rotate();
		addAction(emitter_action0);
		addAction(emitter_action1);
		addAction(emitter_action2);
		
		var emitter_initializer1:Position = new Position(new DiscSectorZone(new Point(0,0),60,0,360,0));
		var emitter_initializer2:AlphaInit = new AlphaInit(0.6,0.9);
//		var emitter_initializer3:ColorInit = new ColorInit(4294927872,4294967295);
		var emitter_initializer4:Lifetime = new Lifetime(0.2,0.4);
		var emitter_initializer5:ScaleImageInit = new ScaleImageInit(0.6,1);
		var emitter_initializer6:ScaleImageInit = new ScaleImageInit(0.5,1);
		var emitter_initializer7:Rotation = new Rotation(0,1);
		var emitter_initializer8:Rotation = new Rotation(0,1);
		var emitter_initializer9:Velocity = new Velocity(new DiscSectorZone(new Point(0,0),60,0,360,360));
		var emitter_initializer10:RotateVelocity = new RotateVelocity(-3,5);
		var emitter_initializer11:RotateVelocity = new RotateVelocity(-4,5);
		var emitter_initializer12:RotateVelocity = new RotateVelocity(-5,5);
		var emitter_initializer13:RotateVelocity = new RotateVelocity(-6,6);
//		var emitter_initializer14:CollisionRadiusInit = new CollisionRadiusInit(1);
//		var emitter_initializer15:MassInit = new MassInit(6);
		addInitializer(emitter_initializer1);
		addInitializer(emitter_initializer2);
//		addInitializer(emitter_initializer3);
		addInitializer(emitter_initializer4);
		addInitializer(emitter_initializer5);
		addInitializer(emitter_initializer6);
		addInitializer(emitter_initializer7);
		addInitializer(emitter_initializer8);
		addInitializer(emitter_initializer9);
		addInitializer(emitter_initializer10);
		addInitializer(emitter_initializer11);
		addInitializer(emitter_initializer12);
		addInitializer(emitter_initializer13);
//		addInitializer(emitter_initializer14);
//		addInitializer(emitter_initializer15);
		bitmap_emitter_0.blendMode = "normal";
		addInitializer(new SharedImages([bitmap_emitter_0]));
		}
	}
}