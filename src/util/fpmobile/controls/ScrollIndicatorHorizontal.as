/**
 * Copyright (c) 2010 Adobe Systems Incorporated.
 * All rights reserved.
 * Permission is hereby granted, free of charge, to any person obtaining
 * a copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

package util.fpmobile.controls {
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	
	public class ScrollIndicatorHorizontal extends Sprite
	{
		public static const HEIGHT:Number = 10;
		
		private static const LEFT_SKIN_WIDTH:Number = 3;
		private static const RIGHT_SKIN_WIDTH:Number = 3;
		
		[Embed(source="scroll_indicator/scroll_indicator_horizontal_left.png")]
		private var leftSkinClass:Class;
		
		[Embed(source="scroll_indicator/scroll_indicator_horizontal_middle.png")]
		private var middleSkinClass:Class;
		
		[Embed(source="scroll_indicator/scroll_indicator_horizontal_right.png")]
		private var rightSkinClass:Class;
		
		private var leftSkin:DisplayObject;
		private var middleSkin:DisplayObject;
		private var rightSkin:DisplayObject;
		
		private var _width:Number;
		
		public function ScrollIndicatorHorizontal()
			{
				super();
			
			init();
		}
		
		private function init():void
		{
			leftSkin = new leftSkinClass();
			addChild(leftSkin);
			
			middleSkin = new middleSkinClass();
			middleSkin.x = LEFT_SKIN_WIDTH;
			addChild(middleSkin);
			
			rightSkin = new rightSkinClass();
			rightSkin.x = LEFT_SKIN_WIDTH + middleSkin.width;
			addChild(rightSkin);
		}
		
		override public function set width(value:Number):void
		{
			if (!isNaN(value) && value != _width)
			{
				middleSkin.width = Math.round(value - LEFT_SKIN_WIDTH - RIGHT_SKIN_WIDTH);
				rightSkin.x = Math.round(middleSkin.width + LEFT_SKIN_WIDTH);
			}
			
			_width = value;
		}
	}
}