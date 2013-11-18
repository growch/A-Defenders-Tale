/** * @author: * 		Itai Asseo -		iasseo@digitas.com * 		Manuel Joachim -	mjoachim@digitas.com * */package util{	import flash.events.Event;	import flash.text.AntiAliasType;	import flash.text.TextField;	import flash.text.TextFormat;		import control.EventController;		import events.ViewEvent;
	public class Text extends TextField	{		public function Text(str:String, format:TextFormat, w:Number=100, wrapMe:Boolean=true, isHtmlText:Boolean=false, embed:Boolean=true)		{			super();			//			needed because cacheAsBitmap was causing text to disappear on VC screenshot//			WTF?			addEventListener(Event.ADDED_TO_STAGE, textAddedToStage);			addEventListener(Event.REMOVED, textRemovedToStage);			if (format)				defaultTextFormat=format;			if (isHtmlText)			{				htmlText=str;			}			else			{				text=str;			}			embedFonts=embed;			selectable=false;								cacheAsBitmap = true;			wordWrap=wrapMe;			multiline=wrapMe;			if (w == 0)			{				width=textWidth + 5;			}			else			{				width=w;			}			height=textHeight + 5;//			background=true;//			backgroundColor=0xFF0000;			mouseEnabled=false;			mouseWheelEnabled=false;						antiAliasType=AntiAliasType.ADVANCED; 		}				protected function textAddedToStage(event:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, textAddedToStage);			EventController.getInstance().addEventListener(ViewEvent.TAKE_SCREENSHOT, navOpen);			EventController.getInstance().addEventListener(ViewEvent.REMOVE_SCREENSHOT, navClosed);//			trace("textAddedToStage");		}				protected function navOpen(event:Event):void
		{
			cacheAsBitmap = false;		}		protected function navClosed(event:Event):void
		{
			cacheAsBitmap = true;
		}				protected function textRemovedToStage(event:Event):void
		{
			removeEventListener(Event.REMOVED, textRemovedToStage);			EventController.getInstance().removeEventListener(ViewEvent.TAKE_SCREENSHOT, navOpen);			EventController.getInstance().removeEventListener(ViewEvent.REMOVE_SCREENSHOT, navClosed);//			trace("textRemovedToStage");
		}	}}