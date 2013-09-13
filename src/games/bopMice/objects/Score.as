package games.bopMice.objects
{
	import flash.display.MovieClip;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	

	public class Score extends MovieClip
	{
		private var _shadow:TextField; 
		private var _score:TextField; 
		private var _highlight:TextField; 
		private var _mc:MovieClip;
		
		public function Score(mc:MovieClip)
		{
			_mc = mc;
			
			var tf:TextFormat = new TextFormat();
			tf.size = 52;
			tf.color = 0x000000;
			tf.align = "center";
			tf.font = new BaskervilleBold().fontName;
			
			_shadow = new TextField();
			_score = new TextField();
			_highlight = new TextField();
			
			
			
			_shadow.antiAliasType = AntiAliasType.ADVANCED;
			_score.antiAliasType = AntiAliasType.ADVANCED;
			_highlight.antiAliasType = AntiAliasType.ADVANCED;
			
			_shadow.width = _score.width = _highlight.width = 87;
			
			_shadow.defaultTextFormat = tf;
			_score.defaultTextFormat = tf;
			_highlight.defaultTextFormat = tf;
			
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