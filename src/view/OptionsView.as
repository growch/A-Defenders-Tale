package view
{
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	public class OptionsView extends MovieClip
	{
		private var _optionCount:int;
		private var _mc:MovieClip;
		
		private var _error:MovieClip;
		
		public var _selected:Boolean;
		
		public var optionNumSelected:int;
		
		public function OptionsView(mc:MovieClip, optionCount:int)
		{
			_mc = mc;
			_optionCount = optionCount;
//			super();
			init();
		}
		
		public function destroy():void
		{
			var thisOption: MovieClip;
			for (var i:int = 0; i < _optionCount; i++) 
			{
				thisOption = _mc.getChildByName("option"+i+"_mc") as MovieClip;
				thisOption.ID = null;
				thisOption.removeEventListener(MouseEvent.CLICK, optionClick);
			}
			thisOption = null;
			_error = null;
			_mc = null;
		}
		
		public function init() : void {
			var thisOption: MovieClip;
			for (var i:int = 0; i < _optionCount; i++) 
			{
				thisOption = _mc.getChildByName("option"+i+"_mc") as MovieClip;
				thisOption.alpha = 0;
				thisOption.ID = i;
				thisOption.mouseChildren = false;
				thisOption.addEventListener(MouseEvent.CLICK, optionClick);
			}
			thisOption = null
			_error = _mc.getChildByName("error_mc") as MovieClip;
			_error.visible = false;
		}
		
		private function optionClick(e:MouseEvent) : void {
			var thisBtn:MovieClip = MovieClip(e.target);
			for (var i:int = 0; i < _optionCount; i++) 
			{
				var thisOption: MovieClip = _mc.getChildByName("option"+i+"_mc") as MovieClip;
				thisOption.alpha = 0;
			}
			thisBtn.alpha = 1;
			
			optionNumSelected = thisBtn.ID;
			_selected = true;
		}
		
		
		public function isSelected(): Boolean
		{
			if (!_selected) {
				_error.visible = true;
				return false;
			} else {
				_error.visible = false;
				return true;
			}
		}
	}
}