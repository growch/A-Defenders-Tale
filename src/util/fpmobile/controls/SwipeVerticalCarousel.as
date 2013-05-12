package util.fpmobile.controls {
	import util.fpmobile.constant.SwipeDirections;
	import util.fpmobile.events.SwipeEvent;

	import com.digitas.phobos.view.PHOBOS_IView;
	import com.greensock.TweenLite;
	import com.greensock.easing.Quad;

	import flash.display.DisplayObject;
	import flash.events.MouseEvent;
	import flash.events.TransformGestureEvent;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;

	/**
	 * @author Francois Balmelle
	 */
	public class SwipeVerticalCarousel extends UIControl implements PHOBOS_IView
	{
		private var _assetList : Vector.<DisplayObject>;
		private var _currentAsset : DisplayObject;
		private var _nextAsset : DisplayObject;
		private var _assetIndex : int;
		private var _swipeDirection : String;
		private var _mousePosition : Number;
		private var _useSwipeEvent : Boolean;
		private var _swipping : Boolean;
		private var _active : Boolean;

		protected const TIMING : Number = 0.5;
		protected const EASING : Function = Quad.easeInOut;
		protected const THRESHOLD : Number = 100;

		public function SwipeVerticalCarousel( assetList:Vector.<DisplayObject>, initialIndex:int=0, useSwipeEvent:Boolean=true )
		{
			super();
			_assetList = assetList;
			if (_assetList.length <= 0 ) return;
			_assetIndex = initialIndex;
			if (_assetIndex > (_assetList.length - 1) ) _assetIndex = 0;
			_useSwipeEvent = useSwipeEvent;
			
			init();
		}
		
		public function setAsset( index:int ) :void
		{
			if ( (index < 0) || (index > (_assetList.length - 1) || ( index == _assetIndex)) ) return;
			
			if ( index > _assetIndex ) {
				_swipeDirection = SwipeDirections.UP;
			} else {
				_swipeDirection = SwipeDirections.DOWN;
			}
			
			_assetIndex = index;
			swipeAsset();
		}
		
		
		public function dispose() : void
		{
			if ( _useSwipeEvent ) removeEventListener (TransformGestureEvent.GESTURE_SWIPE, swipeHandler);		
			
			removeEventListener( MouseEvent.MOUSE_DOWN, onMouseDown );
			removeEventListener( MouseEvent.MOUSE_UP, onMouseUp);
		}
		
		public function set active( value:Boolean ) : void
		{
			_active = value;
		}

		public function get active() : Boolean
		{
			return _active;
		}
		
		private function init() : void
		{
			_currentAsset = _assetList[ _assetIndex ];
			_nextAsset = null;
			_swipping = false;
			_active = true;
			
			addChild( _currentAsset );
			
			if ( _useSwipeEvent ) {
				Multitouch.inputMode = MultitouchInputMode.GESTURE; 
				addEventListener (TransformGestureEvent.GESTURE_SWIPE, swipeHandler);
			}
			
			addEventListener( MouseEvent.MOUSE_DOWN, onMouseDown );
			addEventListener( MouseEvent.MOUSE_UP, onMouseUp);
		}

		private function canSwipe() : Boolean {
			//trace('_active: ' + this.name  + (_active));
			if ( !_active ) return false;
			
			if ( ( (_swipeDirection == SwipeDirections.UP) && (_assetIndex == (_assetList.length - 1) ) ) ||
				 ( (_swipeDirection == SwipeDirections.DOWN) && (_assetIndex == 0) ) ) {
				 	return false;
				 } else {
				 	return true;
				 }
		}
		
		
		private function setAssetIndex() : void
		{
			if (_swipeDirection == SwipeDirections.UP) {
				_assetIndex++;
				if (_assetIndex == _assetList.length) _assetIndex = _assetList.length - 1;
				
			} else if (_swipeDirection == SwipeDirections.DOWN) {
				_assetIndex--;
				if (_assetIndex < 0 ) _assetIndex = 0;
			}
		}
		
		
		private function swipeAsset() : void
		{
			var tweenParams:Object;
			var delay : Number = 0;
			var onScreenY : Number = _currentAsset.y;
			var offScreenY : Number;
			
			_swipping = true;
			
			_nextAsset = _assetList[ _assetIndex ];

			_nextAsset.x = _currentAsset.x;
			if (_swipeDirection == SwipeDirections.UP) {
				_nextAsset.y = _currentAsset.y + _currentAsset.height;
				offScreenY = _currentAsset.y - _currentAsset.height;
			} else if (_swipeDirection == SwipeDirections.DOWN) {
				_nextAsset.y = _currentAsset.y - _nextAsset.height;
				offScreenY = _currentAsset.y + _currentAsset.height;
			}
			addChild( _nextAsset);
			
			tweenParams = {y : offScreenY, delay : delay, ease:EASING };
			TweenLite.to(_currentAsset, TIMING, tweenParams);
			
			tweenParams = {y : onScreenY, delay : delay, ease:EASING, onComplete: cleanUpAfterSwipe };
			TweenLite.to(_nextAsset, TIMING, tweenParams);
			
			dispatchEvent( new SwipeEvent( SwipeEvent.VERTICAL_SWIPE_START, true, false, _swipeDirection, _assetIndex ) );
		}

		
		private function cleanUpAfterSwipe() : void
		{
			removeChild( _currentAsset );
			_currentAsset = _nextAsset;
			_nextAsset = null;
			dispatchEvent( new SwipeEvent( SwipeEvent.VERTICAL_SWIPE_END, true, false, _swipeDirection, _assetIndex ) );
			
			_swipping = false;
			//trace("cleanUpAfterSwipe",_swipeDirection,_assetIndex);
		}
		
		
		private function prepareSwipe() : void
		{
			if ( canSwipe() && !_swipping ) {
				setAssetIndex();
				swipeAsset();
			}
		}
		
		
		private function swipeHandler(event:TransformGestureEvent) : void 
		{ 
			/*switch(event.offsetX) { 
				case 1: 
					// swiped right
					_swipeDirection = SwipeDirections.RIGHT;
					break;
				case -1: 
					// swiped left 
					_swipeDirection = SwipeDirections.LEFT;
					break; 
			} 
			 * 
			 */
			
			switch(event.offsetY) { 
				case 1: 
					// swiped down 
					_swipeDirection = SwipeDirections.DOWN;
					break; 
				case -1: 
					// swiped up 
					_swipeDirection = SwipeDirections.UP;
					break;  
			} 
			
			prepareSwipe();
		}
		
		private function onMouseDown(event : MouseEvent) : void 
		{
			
			_mousePosition = event.stageY;
		}

		private function onMouseUp(event : MouseEvent) : void 
		{
			var delta : Number = event.stageY - _mousePosition;
			
			if ( Math.abs( delta ) > THRESHOLD ) {
				if ( delta > 0 ) {
					_swipeDirection = SwipeDirections.DOWN;
				} else {
					_swipeDirection = SwipeDirections.UP;
				}
				
				prepareSwipe();
			}
			
		}

		
				
	}
}
