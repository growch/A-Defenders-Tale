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

 /**
 * Very simple vertical container control which supports
 * a flick gesture to scroll.
 */

package util.fpmobile.controls {
	import util.fpmobile.constant.SwipeDirections;
	import util.fpmobile.events.ScrollEvent;
	import util.fpmobile.events.SwipeEvent;
	import util.fpmobile.events.TweenEvent;

//	import com.digitas.phobos.view.PHOBOS_IView;

	import mx.effects.easing.Quartic;

	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.utils.getTimer;

	/**
	 * Dispatched when a user has swiped horizontally before vertically.
	 */
	[Event(name="horizontalSwipe", type="com.adobe.lighthouse.events.HorizontalSwipeEvent")]
	
	/**
	 * Dispatched when the throw tweening has completed.
	 */
	[Event(name="tweenComplete", type="com.adobe.lighthouse.events.TweenEvent")]
	
	/**
	 * Dispatched when the list has started to scroll because of a user dragging.
	 */
	[Event(name="startScroll", type="com.adobe.lighthouse.events.ScrollEvent")]
	
	public class DraggableHorizontalContainer extends UIControl
	{
		public var maxScroll:Number;
		
		/**
		 * In seconds.
		 */
		private static const ANIMATION_DURATION:Number = 1.25;
		
		private static const MIN_SCROLL_INDICATOR_WIDTH:Number = 10;
		private static const SCROLL_FADE_TWEEN_DURATION:Number = .3;
		
		/**
		 * Right edge padding.
		 */
		private static const SCROLL_INDICATOR_RIGHT_PADDING:Number = 10;
		
		/**
		  *  The max number of pixels to move the list after a mouseUp event.
		  */
		private static const MAX_PIXEL_MOVE:Number = 300;
		
		/**
		 * The min number of pixels to move the list after a mouseUp event.
		 * If the amount to scroll is less than this value the list will
		 * not scroll. This is to prevent inadvertant flicks when a user
		 * slowly drags the list.
		 */
		private static const MIN_PIXEL_MOVE:Number = 10;
		
		/**
		 * The number of frames to wait to calculate speed when flicking.
		 */
		private static const NUM_FRAMES_TO_MEASURE_SPEED:Number = 2;
		
		/**
		 * The amount the mouse can move before dragging.
		 */
		public static const START_TO_DRAG_THRESHOLD:Number = 10;
		
		/**
		 * The amount the mouse must move horizontally to trigger a HorizontalSwipeEvent.
		 */
		private static const HORIZONTAL_DRAG_THRESHOLD:Number = 40;
		
		/**
		 *  The x offset in which to layout the first item.
		 */
		private var itemXOffsetTop:Number;
		
		/**
		 *  The x offset in which to layout the last item.
		 */
		private var itemXOffsetBottom:Number;
		
		/**
		 * The amount of top padding between scrollIndicator and the left edge.
		 */
		private var scrollIndicatorLeftPadding:Number;
		
		/**
		 * The amount of top padding between scrollIndicator and the right edge.
		 */
		private var scrollIndicatorRightPadding:Number;
		
		private var horizontalGap:Number;
		
		/**
		 * Contains the DisplayObjects which are dragged.
		 * Does not include scrollIndicator.
		 */
		private var itemContainer:Sprite;
		
		/**
		 * The target scroll value when a user flicks.
		 */
		private var targetScrollX:Number;
		
		/**
		 * The start scroll value when a user flicks.
		 */
		private var startScrollX:Number;
		
		/**
		 * The total amount to scroll when a user flicks.
		 */
		private var totalScrollX:Number;
		
		/**
		 * The amount a user has dragged the mouse between frames.
		 */
		private var deltaMouseX:Number;
		
		/**
		 * Used to calculate the number of pixel per millisecond when a user flicks.
		 */
		private var previousDragTime:Number;
		
		/**
		 * The value of the last drag mouseX.
		 * Used to calculate the number of pixel per millisecond when a user flicks.
		 */
		private var previousDragMouseX:Number;
		
		/**
		 * The scrollY when a user first starts to drag.
		 */
		private var beginDragScrollX:Number;
		
		/**
		 * The mouseY when a user first starts to drag.
		 */
		private var mouseXDown:Number;
		
		/**
		 * Used to track the y coords when a user is dragging.
		 */
		private var mouseDragCoords:Array;
		
		/**
		 * Used to track a mouse coord every other frame for more
		 * accurate measurement of speed.
		 * 
		 */
		private var enterFrameIndex:Number = 0;
		
		//private var scrollIndicator:ScrollIndicatorVertical;
		private var scrollIndicator:ScrollIndicatorHorizontal;
		
		/**
		 * The width of the scrollIndicator when a user has not dragged
		 * the content pass the left edge or pass the right edge,
		 * ie: scrollDelta > 0 && scrollDelta < 1
		 */
		private var scrollIndicatorWidth:Number;
		
		private var backgroundColor:Number;
		private var backgroundOpacity:Number;
		
		/**
		 * The difference between the scrollIndicator.height and _height.
		 */
		private var totalScrollAmount:Number;
		
		private var dispatchHorizontalSwipeEvents:Boolean;
		
		/**
		 * Used for detecting horizontal swipes.
		 */
		private var mouseYDownCoord:Number;
		
		/**
		 * Properties for tweening a user flick.
		 */
		private var tweenCurrentCount:Number;
		private var tweenTotalCount:Number;
		
		/**
		 * Used to store children which allow horizontal dragging
		 * such as a horizontal slideshow.
		 */
		private var horizontalDragChildren:Array;
		
		private var isDragging:Boolean;
		
		/**
		 * The amount to decrement scrollIndicator.alpha per frame
		 * when it fades out.
		 */
		private var scrollIndicatorAlphaDelta:Number;
		
		/**
		 * Flag for whether or not the flick tween is still playing.
		 */
		private var isTweening:Boolean;
		
		private var resetScrollY:Boolean;
		
		private var useScrollIndicator:Boolean;
		
		/**
		 * For the sake of simplicity, params are passed into the
		 * constructor rather than responding to new values after
		 * instantiation.
		 */
		public function DraggableHorizontalContainer(horizontalGap:Number=0,
												   backgroundColor:Number=0xffffff,
												   backgroundOpacity:Number=1,
												   dispatchHorizontalSwipeEvents:Boolean=false,
												   itemXOffsetTop:Number=0,
												   itemXOffsetBottom:Number=0,
												   scrollIndicatorLeftPadding:Number=0,
												   scrollIndicatorRightPadding:Number=0,
												   useScrollIndicator:Boolean=true)
		{
			super();
			
			this.backgroundColor = backgroundColor;
			this.backgroundOpacity = backgroundOpacity;
			this.horizontalGap = horizontalGap;
			this.dispatchHorizontalSwipeEvents = dispatchHorizontalSwipeEvents;
			this.itemXOffsetTop = itemXOffsetTop;
			this.itemXOffsetBottom = itemXOffsetBottom;
			this.scrollIndicatorLeftPadding = scrollIndicatorLeftPadding;
			this.scrollIndicatorRightPadding = scrollIndicatorRightPadding;
			this.useScrollIndicator = useScrollIndicator;
			
			init();
		}
		
		public function dispose() : void
		{
			stopTween();
			
			if ( hasEventListener( MouseEvent.MOUSE_DOWN ) ) removeEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			if ( hasEventListener( Event.REMOVED_FROM_STAGE ) ) removeEventListener(Event.REMOVED_FROM_STAGE, removedFromStageHandler);
			if ( hasEventListener( Event.ADDED_TO_STAGE ) ) removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
		}
		
		
		private function init():void
		{
			itemContainer = new Sprite();
			addChild(itemContainer);
			
			addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			addEventListener(Event.REMOVED_FROM_STAGE, removedFromStageHandler);
			addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			
			horizontalDragChildren = new Array();
			
			mouseDragCoords = new Array();
		}
		
		private function addedToStageHandler(e:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			
			// Calculate how much to decrement the alpha per frame when scrollIndicator fades out.
			scrollIndicatorAlphaDelta = 1 / (SCROLL_FADE_TWEEN_DURATION * stage.frameRate);
		}
		
		private function removedFromStageHandler(e:Event):void
		{
			stage.removeEventListener(Event.ENTER_FRAME, tween_enterFrameHandler);
			
			scrollIndicatorVisible = false;
		}
		
		/**
		 * Override the methods below since children are added to itemContainer.
		 */
		override public function get numChildren():int
		{
			return itemContainer.numChildren;
		}
		
		override public function contains(child:DisplayObject):Boolean
		{
			return itemContainer.contains(child);
		}
		
		override public function setChildIndex(child:DisplayObject, index:int):void
		{
			itemContainer.setChildIndex(child, index);
		}
		
		override public function addChildAt(child:DisplayObject, index:int):DisplayObject
		{
			if (child != scrollIndicator && child != itemContainer)
				itemContainer.addChildAt(child, index);
			else
				super.addChildAt(child, index);
	
			return child;
		}
		
		override public function addChild(child:DisplayObject):DisplayObject
		{
			if (child != scrollIndicator && child != itemContainer)
				itemContainer.addChild(child);
			else
				super.addChild(child);
				
			return child;
		}
		
		override public function removeChildAt(index:int):DisplayObject
		{
			if (index < numChildren - 1)
			{
				if (getChildAt(index) == scrollIndicator || getChildAt(index) == itemContainer)
					return null;
			}
			
			return itemContainer.removeChildAt(index);
		}
		
		override public function removeChild(child:DisplayObject):DisplayObject
		{
			if (child != scrollIndicator && child != itemContainer)
				itemContainer.removeChild(child);
			else
				super.removeChild(child);
				
			return child;
		}
		
		/**
		 * Lays out the children.
		 * This should always be called after children have been added or resized.
		 * 
		 * @param resetScrollY Indicates whether or not to reset scrollY when laying out the items.
		 */
		public function refreshView(resetScrollX:Boolean):void
		{
			for (var i:Number = 0; i < itemContainer.numChildren; i++)
			{
				var child:DisplayObject = itemContainer.getChildAt(i);
				if (i == 0)
				{
					child.x = itemXOffsetTop;
				}
				else
				{
					var previousChild:DisplayObject = itemContainer.getChildAt(i - 1);
					child.x = previousChild.x + previousChild.width + horizontalGap;
				}
			}
			
			if (stage)
				stage.removeEventListener(Event.ENTER_FRAME, tween_enterFrameHandler);
			
			scrollIndicatorVisible = false;
			
			this.resetScrollY = resetScrollY;
			updateDisplayList(width, height);
			
			this.resetScrollY = false;
		}
		
		override protected function updateDisplayList(width:Number, height:Number):void
		{
			super.updateDisplayList(width, height);
			
			stopTween();
			
			updateMaxScroll();
			
			if (resetScrollY || !itemContainer.scrollRect)
			{
				itemContainer.scrollRect = new Rectangle(0, 0, width, height);
			}
			else
			{
				scrollX = Math.min(maxScroll, scrollX);
				itemContainer.scrollRect = new Rectangle(0, scrollX, width, height);
			}
			
			graphics.clear();
			graphics.beginFill(backgroundColor, backgroundOpacity);
			graphics.drawRect(0, 0, width, height);
		}
		
		private function updateMaxScroll():void
		{
			if (itemContainer.numChildren > 0)
			{
				var lastChild:DisplayObject = itemContainer.getChildAt(itemContainer.numChildren - 1);
				var totalWidth:Number = lastChild.x + lastChild.width;
				maxScroll = Math.round(totalWidth - width) + itemXOffsetBottom;
				
				if (maxScroll > 0)
				{
					if ( useScrollIndicator ) {
						if (!scrollIndicator)
						{
							//scrollIndicator = new ScrollIndicatorVertical();
							scrollIndicator = new ScrollIndicatorHorizontal();
							scrollIndicator.mouseChildren = scrollIndicator.mouseEnabled = false;
							scrollIndicator.alpha = 0;
						}
						
						scrollIndicator.x = scrollIndicatorLeftPadding;
						scrollIndicator.y = _height - ScrollIndicatorHorizontal.HEIGHT - SCROLL_INDICATOR_RIGHT_PADDING;
						
						if (!contains(scrollIndicator))
							addChild(scrollIndicator);
						
						// Calculate the values used for sizing scrollIndicator.
						var availableWidth:Number = _width - scrollIndicatorLeftPadding - scrollIndicatorRightPadding;
						scrollIndicatorWidth = Math.max(Math.round((availableWidth / totalWidth) * availableWidth), MIN_SCROLL_INDICATOR_WIDTH);;
						scrollIndicator.width = scrollIndicatorWidth;
						totalScrollAmount = availableWidth - scrollIndicatorWidth;
					}
				}
				else
				{
					maxScroll = 0;
					if (useScrollIndicator && scrollIndicator && contains(scrollIndicator))
						removeChild(scrollIndicator);
				}
			}
		}
		
		private function mouseDownHandler(e:MouseEvent):void
		{
			mouseXDown = previousDragMouseX = root.mouseX;
			mouseYDownCoord = root.mouseY;
			
			if (maxScroll > 0)
			{
				isDragging = false;
				stage.removeEventListener(Event.ENTER_FRAME, tween_enterFrameHandler);
				
				deltaMouseX = 0;
				previousDragTime = getTimer();
				
				beginDragScrollX = scrollX;
				
				enterFrameIndex = 0;
			}
		
			// Listen for a mouseMove first to detect the initial direction
			// and when to start dragging.
			stage.addEventListener(MouseEvent.MOUSE_MOVE, detectDirection_mouseMoveHandler, false, 0,true);
			
			stage.addEventListener(MouseEvent.MOUSE_UP, drag_mouseUpHandler, false, 0,true);
		}
		
		private function detectDirection_mouseMoveHandler(e:Event):void
		{
			if (maxScroll > 0 && Math.abs(mouseXDown - root.mouseX) > START_TO_DRAG_THRESHOLD)
			{
				scrollIndicatorVisible = true;
				
				isDragging = true;
				
				stage.removeEventListener(MouseEvent.MOUSE_MOVE, detectDirection_mouseMoveHandler);
				stage.addEventListener(Event.ENTER_FRAME, drag_enterFrameHandler, false, 0,true);
				
				dispatchEvent(new ScrollEvent(ScrollEvent.START_SCROLL, false, false, mouseXDown > root.mouseX ? ScrollEvent.DIRECTION_LEFT : ScrollEvent.DIRECTION_RIGHT));
			}
			
			if (dispatchHorizontalSwipeEvents)
			{
				var deltaY:Number = mouseYDownCoord - root.mouseY;
				
				// To avoid inadvertant swipes make sure the user moved HORIZONTAL_DRAG_THRESHOLD.
				// Accidental swipes are more common when using fingers.
				if (Math.abs(deltaY) > HORIZONTAL_DRAG_THRESHOLD)
				{
					for each (var child:DisplayObject in horizontalDragChildren)
					{
						if (child.hitTestPoint(root.mouseX, root.mouseY))
						{
							// Mouse is over a horizontal drag child.
							stopHorizontalScrolling();
						}
					}
					
					// Make sure the user moved more along the y-axis more than the x-axis.
					var deltaX:Number = mouseXDown - root.mouseX;
					if (Math.abs(deltaX) > Math.abs(deltaY))
						dispatchEvent(new SwipeEvent(SwipeEvent.HORIZONTAL_SWIPE_START, false, false, deltaX < 0 ? SwipeDirections.RIGHT : SwipeDirections.LEFT));
				}
			}
		}
		
		/**
		 * The handler for fading out the scrollIndicator.
		 */
		private function scrollIndicatorFade_enterFrameHandler(e:Event):void
		{
			scrollIndicator.alpha -= scrollIndicatorAlphaDelta;
			
			if (scrollIndicator.alpha <= 0)
				removeEventListener(Event.ENTER_FRAME, scrollIndicatorFade_enterFrameHandler);
		}
		
		/**
		 * Can be used after dispatching a HorizontalSwipeEvent if
		 * a listener would like to stop the vertical scrolling.
		 */
		public function stopHorizontalScrolling():void
		{
			scrollIndicatorVisible = false;
			
			if ( stage ) {
				stage.removeEventListener(Event.ENTER_FRAME, drag_enterFrameHandler);
				stage.removeEventListener(MouseEvent.MOUSE_UP, drag_mouseUpHandler);
				stage.removeEventListener(MouseEvent.MOUSE_MOVE, detectDirection_mouseMoveHandler);
			}
			
			//dispatchEvent(new ScrollEvent(ScrollEvent.END_SCROLL) );
		}
		
		private function drag_enterFrameHandler(e:Event):void
		{
			e.stopImmediatePropagation();
			
			if (stage)
			{
				var newX:Number = beginDragScrollX + (mouseXDown - root.mouseX);
				
				scrollX = newX;
				
				enterFrameIndex += 1;
			
				if (enterFrameIndex % NUM_FRAMES_TO_MEASURE_SPEED)
				{
					deltaMouseX = root.mouseX - previousDragMouseX;
					previousDragTime = getTimer();
					previousDragMouseX = root.mouseX;
				}
				
				mouseDragCoords.push(root.mouseY);
				
				updateScrollIndicator();
			}
		}
		
		private function updateScrollIndicator():void
		{
			if (!useScrollIndicator) return;
			
			var delta:Number = scrollX / maxScroll;
			var newWidth:Number;
			
			if (delta < 0) // user dragged below the top edge.
			{
				scrollIndicator.x = Math.round(scrollIndicatorLeftPadding);
				
				// virtualScrollX will be < 0.
				// Shrink scrollIndicator.width by the amount a user has scrolled after the left edge.
				newWidth = scrollX + scrollIndicatorWidth;
				newWidth = Math.max(MIN_SCROLL_INDICATOR_WIDTH, newWidth);
				scrollIndicator.width = Math.round(newWidth);
			}
			else if (delta < 1)
			{
				if (scrollIndicator.width != scrollIndicatorWidth)
					scrollIndicator.width = Math.round(scrollIndicatorWidth);
				
				var newX:Number = Math.round(delta * totalScrollAmount);
				newX = Math.min(_width - scrollIndicatorWidth - scrollIndicatorRightPadding, newX);
				scrollIndicator.x = Math.round(newX + scrollIndicatorLeftPadding);
			}
			else	// User dragged above the bottom edge.
			{
				// Shrink scrollIndicator.width by the amount a user has scrolled pass the right edge.
				newWidth = scrollIndicatorWidth - (scrollX - maxScroll);
				newWidth = Math.max(MIN_SCROLL_INDICATOR_WIDTH, newWidth);
				scrollIndicator.width = Math.round(newWidth);
				scrollIndicator.x = Math.round(_width - newWidth - scrollIndicatorRightPadding);
			}
		}
		
		public function get scrollX():Number
		{
			return itemContainer.scrollRect.x;
		}
		
		public function set scrollX(value:Number):void
		{
			var rect:Rectangle = itemContainer.scrollRect;
			rect.x = value;
			itemContainer.scrollRect = rect;
		}
		
		private function drag_mouseUpHandler(e:MouseEvent):void
		{
			stopHorizontalScrolling();
			
			if (maxScroll > 0)
			{
				// Calculate the speed between the last mouse moves which
				// will determine the speed in which to scroll the items.
				var elapsedMiliseconds:Number = getTimer() - previousDragTime;
				var pixelsPerMillisecond:Number = deltaMouseX / elapsedMiliseconds;
				targetScrollX = Math.round(-pixelsPerMillisecond * MAX_PIXEL_MOVE + scrollX);
				
				if (targetScrollX >= 0) // Scrolling left.
					targetScrollX = Math.min(maxScroll, targetScrollX);
				else			  // Scrolling right.
					targetScrollX = Math.max(targetScrollX, 0);
					
				targetScrollX = Math.round(targetScrollX);
				
				var isFlick:Boolean = true;
				if (targetScrollX != maxScroll && targetScrollX != 0)
				{
					var len:Number = mouseDragCoords.length;
					// Compare the last coord (len - 1) and the one two before it (len - 3).
					// This is to ensure a user flicked the list. If a user is dragging the
					// list slowly there could be an inadvertant flick, so to avoid it
					// compare the two y coords.
					if (len > 3)
					{
						if (mouseDragCoords[len - 1] == mouseDragCoords[len - 3])
							isFlick = false;
					}
					
					if (Math.abs(scrollX - targetScrollX) < MIN_PIXEL_MOVE)
						isFlick = false;
				}
				
				// Remove all of the elements from the array.
				mouseDragCoords.splice(0, mouseDragCoords.length);
				
				if (targetScrollX != scrollX && isFlick)
				{
					doTween(targetScrollX);
				}
				else
				{
					// No flick so fade out scrollIndicator immediately.
					if ( useScrollIndicator ) addEventListener(Event.ENTER_FRAME, scrollIndicatorFade_enterFrameHandler, false, 0,true);
					
					if (isDragging)
						dispatchEvent(new TweenEvent(TweenEvent.TWEEN_COMPLETE));
				}
			}
		}
		
		/**
		 * The amount to tween is the amount itemContainer.scrollRect.y will change.
		 */
		private function doTween(value:Number):void
		{
			targetScrollX = Math.round(value);
			
			startScrollX = scrollX;
			totalScrollX = targetScrollX - startScrollX;
			
			tweenCurrentCount = 0;
			tweenTotalCount = Math.round(ANIMATION_DURATION * stage.frameRate);
			stage.addEventListener(Event.ENTER_FRAME, tween_enterFrameHandler, false, 0,true);
			
			isTweening = true;
			dispatchEvent(new TweenEvent(TweenEvent.TWEEN_START));
		}
		
		/**
		 * Tweens the content to a scrollY value.
		 */
		public function tweenScrollXTo(value:Number):void
		{
			if (maxScroll > 0)
			{
				// If a tween is still in process then take the amount of the 
				// remaining tween and add it to the value passed in.
				if (isTweening)
				{
					value += targetScrollX - scrollX;
					stage.removeEventListener(Event.ENTER_FRAME, tween_enterFrameHandler);
				}
				
				// Make sure the list does not scroll below the top edge and above the bottom edge.
				if (value > maxScroll)
					value = maxScroll;
				else if (value < 0)
					value = 0;
				
				scrollIndicatorVisible = true;
				if (scrollX != value)
				{
					dispatchEvent(new ScrollEvent(ScrollEvent.START_SCROLL, false, false, scrollX < value ? ScrollEvent.DIRECTION_LEFT : ScrollEvent.DIRECTION_RIGHT));
					doTween(value);
				}
				else // At the top or bottom scroll limits so fade out scrollIndicator.
				{
					addEventListener(Event.ENTER_FRAME, scrollIndicatorFade_enterFrameHandler, false, 0,true);
				}
			}
		}
		
		private function tween_enterFrameHandler(e:Event):void
		{
			scrollX = Math.round(Quartic.easeOut(tweenCurrentCount, startScrollX, totalScrollX, tweenTotalCount));
			tweenCurrentCount += 1;
			
			updateScrollIndicator();
	
			if (scrollX == targetScrollX)
			{
				stage.removeEventListener(Event.ENTER_FRAME, tween_enterFrameHandler);
				
				isTweening = false;
				
				// Fade out scrollIndicator.
				if (useScrollIndicator) addEventListener(Event.ENTER_FRAME, scrollIndicatorFade_enterFrameHandler, false, 0,true);
				
				dispatchEvent(new TweenEvent(TweenEvent.TWEEN_COMPLETE));
			}
		}
		
		/**
		 * Set a child which has horizontal dragging enabled/disabled.
		 * Excludes this control from dispatching a HorizontalSwipeEvent if a user swiped over the child.
		 */
		public function setHorizontalDragChild(child:DisplayObject, value:Boolean):void
		{
			var index:Number = horizontalDragChildren.indexOf(child);
			if (value)
			{
				if (index == -1)
					horizontalDragChildren.push(child);
			}
			else
			{
				if (index != -1)
					horizontalDragChildren.splice(index, 1);
			}
		}
		
		private function set scrollIndicatorVisible(value:Boolean):void
		{
			if (scrollIndicator)
			{
				removeEventListener(Event.ENTER_FRAME, scrollIndicatorFade_enterFrameHandler);
				scrollIndicator.alpha = value ? 1 : 0;
			}
		}
		
		/**
		 * Stops the flick tween.
		 */
		private function stopTween():void
		{
			if (isTweening)
			{
				scrollX = targetScrollX;
				
				if (stage)
					stage.removeEventListener(Event.ENTER_FRAME, tween_enterFrameHandler);
				
				scrollIndicatorVisible = false;
				
				dispatchEvent(new TweenEvent(TweenEvent.TWEEN_COMPLETE));
			}
		}
		
	}
}