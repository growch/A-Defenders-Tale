/** * @author: * 		Itai Asseo -		iasseo@digitas.com * 		Manuel Joachim -	mjoachim@digitas.com * */package util{	import flash.text.AntiAliasType;	import flash.text.TextField;	import flash.text.TextFormat;
	public class Text extends TextField	{		public function Text(str:String, format:TextFormat, w:Number=100, wrapMe:Boolean=true, isHtmlText:Boolean=false, embed:Boolean=true)		{			super();			if (format)				defaultTextFormat=format;			if (isHtmlText)			{				htmlText=str;			}			else			{				text=str;			}			embedFonts=embed;			selectable=false;						cacheAsBitmap = true;			wordWrap=wrapMe;			multiline=wrapMe;			if (w == 0)			{				width=textWidth + 5;			}			else			{				width=w;			}			height=textHeight + 5;//			background=true;//			backgroundColor=0xFF0000;			mouseEnabled=false;			mouseWheelEnabled=false;						antiAliasType=AntiAliasType.ADVANCED; 		}	}}