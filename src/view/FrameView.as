package view
{
	import com.senocular.display.duplicateDisplayObject;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.StageQuality;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	import flash.utils.setTimeout;
	
	import model.DataModel;
	
	public class FrameView extends Sprite 
	{
		private var _mc:Sprite;
		private var _top:MovieClip;
		private var _mid:MovieClip;
		private var _bottom:MovieClip;
		private var _medium:MovieClip;
		private var _short:MovieClip;
		private var _mini:MovieClip;
		private var _middleTargetH:Number;
		private var _nextY:Number;
		private var _spacerArray:Array;
		private var onStage:Boolean;
		private var _frameSize:Number;
		
		public function FrameView(mc:Sprite)
		{
//			super();
			_mc = mc;
			_mc.addEventListener(Event.ADDED_TO_STAGE, addedToStage);
			init();
//			trace("frame view!!!!");
		}
		
		protected function addedToStage(event:Event):void
		{
			_mc.removeEventListener(Event.ADDED_TO_STAGE, addedToStage);
			
			onStage = true;
			
			sizeFrame(_frameSize);

			//put back on top just in case
			_mc.parent.addChild(_mc);
		}
		
		private function init():void {
			_top = _mc.getChildByName("top_mc") as MovieClip;
			_mid = _mc.getChildByName("mid_mc") as MovieClip;
			_bottom = _mc.getChildByName("bottom_mc") as MovieClip;
			_medium = _mc.getChildByName("medium_mc") as MovieClip;
			_short = _mc.getChildByName("short_mc") as MovieClip;
			_mini = _mc.getChildByName("mini_mc") as MovieClip;
			
			_medium.visible = false;
			_short.visible = false;
			_mini.visible = false;
			_mid.visible = false;
			
			//hackish?
			var singleMid:MovieClip = _mid.getChildAt(0) as MovieClip;
			singleMid.y = _top.height;
			_mc.addChild(singleMid);
			
			DataModel.getInstance().setGraphicResolution(_top);
			DataModel.getInstance().setGraphicResolution(singleMid);
			DataModel.getInstance().setGraphicResolution(_bottom);
			
			_spacerArray = new Array();
			
			_mc.mouseChildren = false;
			_mc.mouseEnabled = false;
			
		}
		
		public function sizeFrame(h:Number):void
		{
			if (!onStage) {
				_frameSize = h;
				return;
			}
			
			if (h < DataModel.APP_HEIGHT) h = DataModel.APP_HEIGHT;
//			trace("sizeFrame h:"+h);
			
			//cuz had to clip certain bg height
//			if (!this.parent.getChildByName("bg_mc").scrollRect) {
//				if (h < this.parent.getChildByName("bg_mc").height) h = this.parent.getChildByName("bg_mc").height;
////				trace("frame not tall enough");
//			} else {
////				trace("frame not tall enough SCROLLRECT");
//				if (h < this.parent.getChildByName("bg_mc").scrollRect.height) h = this.parent.getChildByName("bg_mc").scrollRect.height;
//			}
//			trace("sizeFrame h:"+h);
			
			_middleTargetH = h - (_top.height + _bottom.height) - _mid.height;
			_nextY = _mid.y + _mid.height;
			
			if(_middleTargetH<2) {
				makeBitmap(_mc.height);
//				trace("not big enough middle frame");
				return;
			}
			
			//random order
			var remainder:Number = _middleTargetH;
			var i:int;
			
			var longCount:int = Math.floor(remainder/_mid.height);
//			trace("longCount: "+longCount);
			for (i = 0; i < longCount; i++) 
			{
				_spacerArray.push(_mid);
				remainder -= _mid.height;
			}
			var mediumCount:int = Math.floor(remainder/_medium.height);
			for (i = 0; i < mediumCount; i++) 
			{
				_spacerArray.push(_medium);
				remainder -= _medium.height;
			}
			var shortCount:int = Math.floor(remainder/_short.height);
			for (i = 0; i < shortCount; i++) 
			{
				_spacerArray.push(_short);
				remainder -= _short.height;
			}
			var miniCount:int = Math.ceil(remainder/_mini.height);
			for (i = 0; i < miniCount; i++) 
			{
				_spacerArray.push(_mini);
				remainder -= _mini.height;
			}
			
			DataModel.getInstance().ShuffleArray(_spacerArray);
			
			var duplicate:*;
			
			for (i = 0; i < _spacerArray.length; i++) 
			{
//				duplicate = duplicateDisplayObject(_spacerArray[i], true);
				
//				var ClassDefinition:Class = Class(getDefinitionByName(getQualifiedClassName(_spacerArray[i]))); 
//				duplicate = new ClassDefinition();
//				_mc.addChild(duplicate);
				
				duplicate = getFromStockpile(_spacerArray[i]);
				_mc.addChild(duplicate);
				
				duplicate.y = _nextY;
				_nextY += _spacerArray[i].height;
//				duplicate = null;
//				trace("_nextY: "+_nextY);
			}
			
			_bottom.y = _nextY;
			
//			trace("_mc.height: "+_mc.height);
//			makeBitmap(_mc.height);
			
//			this was causing some frame pieces to not render on device?
			
//			_mc.cacheAsBitmap = true;
		}
		
		private function getFromStockpile(thisMC:MovieClip):DisplayObject {
			var thisAsset:DisplayObject = thisMC.getChildAt(0);
			DataModel.getInstance().setGraphicResolution(thisAsset as MovieClip);
			return thisAsset;
		}
		
		private function makeBitmap(h:int):void {
//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
			//not doing this anymore cuz iPad1 top/bottom looked bad
			//performance not an issue now that individually loading swfs
			return;
			_mc.stage.quality = StageQuality.HIGH;
//			trace("makeBitmap: h"+h);
			
			var bmd:BitmapData = new BitmapData(DataModel.APP_WIDTH, h, true, 0x00FF0000);
			var bm:Bitmap = new Bitmap(bmd);
			bm.smoothing = true;
//			var clipRect:Rectangle = new Rectangle(0, _top.height-1, DataModel.APP_WIDTH, Math.round(h-_top.height-_bottom.height)); 
//			trace(clipRect);
			bmd.draw(_mc);
//			bmd.drawWithQuality(_mc, null, null,null,null,true,StageQuality.HIGH);
//			removeAllButTopAndBottom();
			removeKids();
			_mc.addChild(bm);
			
			_mc.stage.quality = StageQuality.LOW;
		}
		
		public function destroy():void
		{
			removeKids();
			_top = null;
			_mid = null;
			_medium = null;
			_short = null;
			_mini = null;
			_bottom = null;
			_mc.parent.removeChild(_mc);
		}
		
		private function removeKids():void {
			while (_mc.numChildren > 0) {
				_mc.removeChildAt(0);
			}
		}
		
		private function removeAllButTopAndBottom():void {
			var tempArray:Array = new Array();
//			trace("total kids: "+_mc.numChildren);
			var i:int;
			var thisChild:*;
			for (i = 0; i < _mc.numChildren; i++) 
			{
				thisChild = _mc.getChildAt(i);
				tempArray.push(thisChild);
//				trace(i + ":"+thisChild);
				
			}
			for (i = 0; i < tempArray.length; i++) 
			{
				thisChild = tempArray[i];
				if (thisChild != _top && thisChild != _bottom) {
					_mc.removeChild(thisChild);
//					trace("removing: "+thisChild);
				}	
			}
		}
		
		public function extraDecisionAdjust(h:int):void
		{
			_bottom.height += h;
		}
	}
}