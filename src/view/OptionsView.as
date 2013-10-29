package view
{
	
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	
	import control.EventController;
	
	import events.ViewEvent;
	
	import model.DataModel;
	
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
//				trace(thisOption.name);
			}
			thisOption = null;
			
			DataModel.getInstance().removeAllChildren(_mc);
//			_selected = null;
			_error = null;
			_mc = null;
		}
		
		private function init() : void {
			var thisOption: MovieClip;
			for (var i:int = 0; i < _optionCount; i++) 
			{
				thisOption = _mc.getChildByName("option"+i+"_mc") as MovieClip;
				thisOption.alpha = 0;
				thisOption.ID = i;
				thisOption.mouseChildren = false;
				thisOption.addEventListener(MouseEvent.CLICK, optionClick);
			}
			thisOption = null;
			_error = _mc.getChildByName("error_mc") as MovieClip;
			_error.alpha = 0;
		}
		
		private function optionClick(e:MouseEvent) : void {
			var thisBtn:MovieClip = MovieClip(e.target);
			for (var i:int = 0; i < _optionCount; i++) 
			{
				var thisOption: MovieClip = _mc.getChildByName("option"+i+"_mc") as MovieClip;
				thisOption.alpha = 0;
			}
			thisBtn.alpha = 1;
			
			var tempObj:Object = new Object();
			tempObj.x = _mc.x + thisBtn.x - 2;
			tempObj.y = _mc.y + thisBtn.y - 4;
			
			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.APPLICATION_OPTION_CLICK, tempObj));
			
			optionNumSelected = thisBtn.ID;
			_selected = true;
		}
		
		
		public function isSelected(): Boolean
		{
//			LESSON???
//			for some reason setting these to visible/not-visible was 
//			causing them to not unload? WTF?
			
			if (!_selected) {
				_error.alpha = 1;
				return false;
			} else {
				_error.alpha = 0;
				return true;
			}
		}
	}
}