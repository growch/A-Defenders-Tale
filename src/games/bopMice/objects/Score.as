package games.bopMice.objects
{
	import flash.display.MovieClip;
	import flash.text.TextField;

	public class Score extends MovieClip
	{
		private var _shadow:TextField; 
		private var _score:TextField; 
		private var _highlight:TextField; 
		private var _mc:MovieClip;
		
		public function Score(mc:MovieClip)
		{
			_mc = mc;
			_shadow = _mc.shadow_mc.counter_txt;
			_score = _mc.score_mc.counter_txt;
			_highlight = _mc.highlight_mc.counter_txt;
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
	}
}