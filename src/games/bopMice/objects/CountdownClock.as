package games.bopMice.objects
{
	import com.greensock.TweenMax;
	
	import flash.display.MovieClip;
	
	import games.bopMice.core.Game;
	
	import model.DataModel;
	
	
	public class CountdownClock extends MovieClip
	{
		private var _mc:MovieClip;
		private var _hourglass:MovieClip;
		private var _num1:MovieClip;
		private var _num2:MovieClip;
		private var _countdownTime:String;
		private var _maskInitHeight:Number;
		private var _topMask:MovieClip;
		private var _percent:Number;
		private var _botInitY:Number = 113;
		private var _botTargetY:Number = 69;
		private var _colTargetHeight:Number = 56;
		private var _botDiff:Number;
		private var _bottomSand:MovieClip;
		private var _columnMask:MovieClip;
		private var _game:*;
		
		public function CountdownClock(mc:MovieClip, game:*)
		{
			_game = game;
			_mc = mc;
			_num1 = _mc.number1_mc;
			_num2 = _mc.number2_mc;
			
			_num1.stop();
			_num2.stop();
			
			_hourglass = _mc.hourglass_mc;
			_topMask =  _hourglass.maskTop_mc;
			_maskInitHeight = _topMask.height;
			_bottomSand = _hourglass.bottom_mc;
			_columnMask = _hourglass.columnMask_mc;
			
			//GRAPHICS
			DataModel.getInstance().setGraphicResolution(_num1.font_mc);
			DataModel.getInstance().setGraphicResolution(_num2.font_mc);
			DataModel.getInstance().setGraphicResolution(_hourglass.glass_mc);
			DataModel.getInstance().setGraphicResolution(_hourglass.bottom_mc);
			DataModel.getInstance().setGraphicResolution(_hourglass.column_mc);
			DataModel.getInstance().setGraphicResolution(_hourglass.top_mc);
			
			_botDiff = _botInitY-_botTargetY;
			
			resetSand();
		}
		
		public function destroy():void
		{
			_game = null;
			_mc = null;
			_num1 = null;
			_num2 = null;
			
			_hourglass = null;
			_topMask =  null;
			_bottomSand = null;
			_columnMask = null;	
		}
		
		public function startClock():void {
			setTime(_game.DURATION.toString());
			
			_percent = 100;
			resetSand();
			TweenMax.to(_columnMask, 1, {height:_colTargetHeight});
		}
		
		private function resetSand():void {
			_bottomSand.y = _botInitY;
			_columnMask.height = 0;
			_topMask.height = _maskInitHeight;
		}
		
		public function updateClock(seconds:int):void
		{
			setTime(seconds.toString());
			
			_percent = seconds/_game.DURATION;
			
			_bottomSand.y = _botInitY - ((1 - _percent)*_botDiff);
			_topMask.height = _maskInitHeight * _percent;
		}
		
		private function setTime(str:String):void {
			_countdownTime = str;
			if (_countdownTime.length <= 1) {
				_countdownTime = "0" + _countdownTime;	
			}
			_num1.gotoAndStop(int(_countdownTime.charAt(0)) +1);
			_num2.x  = Math.round(_num1.x + _num1.mask_mc.width+1);
			_num2.gotoAndStop(int(_countdownTime.charAt(1)) +1);
		}
		
	}
}