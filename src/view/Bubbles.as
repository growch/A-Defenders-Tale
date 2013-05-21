/*
 * FLINT PARTICLE SYSTEM
 * .....................
 * 
 * Author: Richard Lord
 * Copyright (c) Richard Lord 2008-2011
 * http://flintparticles.org/
 * 
 * Licence Agreement
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

package view
{
	import flash.geom.Point;
	
	import assets.BubbleMC;
	
	import org.flintparticles.common.actions.Age;
	import org.flintparticles.common.counters.Steady;
	import org.flintparticles.common.initializers.AlphaInit;
	import org.flintparticles.common.initializers.ColorInit;
	import org.flintparticles.common.initializers.ImageClass;
	import org.flintparticles.common.initializers.Lifetime;
	import org.flintparticles.common.initializers.ScaleImageInit;
	import org.flintparticles.twoD.actions.Move;
	import org.flintparticles.twoD.actions.RandomDrift;
	import org.flintparticles.twoD.emitters.Emitter2D;
	import org.flintparticles.twoD.initializers.Position;
	import org.flintparticles.twoD.initializers.Velocity;
	import org.flintparticles.twoD.zones.LineZone;
	import org.flintparticles.twoD.zones.PointZone;

	public class Bubbles extends Emitter2D
	{
		public function Bubbles(tint:Boolean=false, distance:int=-100)
		{
			counter = new Steady( 3 );
      
			
			addInitializer( new ImageClass( BubbleMC ) );
			addInitializer( new Position( new LineZone( new Point( -5, 0 ), new Point( 5, 0 ) ) ) );
			addInitializer( new Velocity( new PointZone( new Point( 0, distance ) ) ) );
			addInitializer( new ScaleImageInit( 0.1, .5 ) );
			addInitializer( new AlphaInit (.7, .9) );
			
			if (tint) {
				addInitializer(new ColorInit(0xd7dbe4, 0x4b5f8d));
			}
			
			if (distance) {
				addInitializer( new Lifetime (2, 4) );
			} else {
				addInitializer( new Lifetime (2, 3) );
			}
			
			
			addAction( new Move() );
//			addAction( new DeathZone( new RectangleZone( -50, -200, 200, 200 ), true ) );
			addAction( new RandomDrift( 20, 20 ) );
			addAction( new Age() );
			
		}
		
		public function destroy():void {
			
		}
	}
}