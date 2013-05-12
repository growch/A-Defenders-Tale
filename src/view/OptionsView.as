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
			super();
			init();
		}
		
		public function init() : void {
			
			for (var i:int = 0; i < _optionCount; i++) 
			{
				var thisOption: MovieClip = _mc.getChildByName("option"+i+"_mc") as MovieClip;
				thisOption.alpha = 0;
				thisOption.ID = i;
				thisOption.mouseChildren = false;
				thisOption.addEventListener(MouseEvent.CLICK, optionClick);
			}
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
		
		public function destroy():void
		{
			for (var i:int = 0; i < _optionCount; i++) 
			{
				var thisOption: MovieClip = _mc.getChildByName("option"+i+"_mc") as MovieClip;
				thisOption.removeEventListener(MouseEvent.CLICK, optionClick);
			}
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