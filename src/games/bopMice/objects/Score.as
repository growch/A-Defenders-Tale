package games.bopMice.objects
{
	import flash.display.MovieClip;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	
	import model.DataModel;
	
	import util.Formats;
	import util.Text;
	

	public class Score extends MovieClip
	{
		private var _shadow:Text; 
		private var _score:Text; 
		private var _highlight:Text; 
		private var _mc:MovieClip;
		
		public function Score(mc:MovieClip)
		{
			_mc = mc;
			
			_shadow = new Text("00",Formats.businessCardFormat(52,"center",0,0x000000), 87);
			_score = new Text("00",Formats.businessCardFormat(52,"center",0,0x000000), 87);
			_highlight = new Text("00",Formats.businessCardFormat(52,"center",0,0x000000), 87);
			
			_shadow.y = _score.y = _highlight.y = -33;
			
			_mc.shadow_mc.addChild(_shadow);
			_mc.score_mc.addChild(_score);
			_mc.highlight_mc.addChild(_highlight);
			
			_mc.shadow_mc.removeChild(_mc.shadow_mc.counter_txt);
			_mc.score_mc.removeChild(_mc.score_mc.counter_txt);
			_mc.highlight_mc.removeChild(_mc.highlight_mc.counter_txt);
			
			_shadow.text = "00";
			_score.text = "00";
			_highlight.text = "00";
		}
		
		public function addScore(amt:Number):void
		{
			_score.text = (parseInt(_score.text) + amt).toString();
			if (int(_score.text) < 10) {
				_score.text = "0" +_score.text;
			}
			_shadow.text = _score.text;
			_highlight.text = _score.text;
		}
		
		public function getScore():int
		{
			return int(_score.text);
		}
		
		public function resetScore():void {
			_score.text = "00";
			_shadow.text = _score.text;
			_highlight.text = _score.text;
		}
		
		public function destroy():void
		{
			_mc = null;
			_shadow = null;
			_score = null;
			_highlight = null;
		}
	}
}