package core
{
	import flash.media.Sound;
	import flash.media.SoundTransform;
	
	import starling.text.BitmapFont;
	import starling.text.TextField;
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;

	public class Assets
	{
		[Embed(source="../assets/bopMiceBG.jpg")]
		private static var bg:Class;
		public static var bgTexture:Texture;
		
		[Embed(source="../assets/bopMiceFrame.png")]
		private static var frame:Class;
		public static var frameTexture:Texture;
		
		[Embed(source="../assets/atlas.png")]
		private static var atlas:Class;
		
		public static var ta:TextureAtlas;
		
		[Embed(source="../assets/atlas.xml", mimeType="application/octet-stream")]
		private static var atlasXML:Class;
		
		[Embed(source="../assets/BaskervilleBoldScore.png")]
		private static var baskScore:Class;
		
		[Embed(source="../assets/BaskervilleBoldScore.fnt", mimeType="application/octet-stream")]
		private static var baskScoreXML:Class;
		
		[Embed(source="../assets/BaskervilleBoldTime.png")]
		private static var baskTime:Class;
		
		[Embed(source="../assets/BaskervilleBoldTime.fnt", mimeType="application/octet-stream")]
		private static var baskTimeXML:Class;
//		
//		[Embed(source="assets/smoke.pex", mimeType="application/octet-stream")]
//		public static var smokeXML:Class;
//		
		[Embed(source="../assets/stars.pex", mimeType="application/octet-stream")]
		public static var starsXML:Class;
		
		[Embed(source="../assets/sound/hitMouse.mp3")]
		private static var hitSound:Class;
		public static var enemyHit:Sound;
		
		[Embed(source="../assets/sound/bg.mp3")]
		private static var bgSound:Class;
		public static var bgMusic:Sound;
		
		public static function init():void
		{
			bgTexture = Texture.fromBitmap(new bg());
			frameTexture = Texture.fromBitmap(new frame());
			
			ta = new TextureAtlas(Texture.fromBitmap(new atlas()),
				XML(new atlasXML()));
			
			TextField.registerBitmapFont(new BitmapFont(Texture.fromBitmap(new baskScore()),
				XML(new baskScoreXML())));
			
			TextField.registerBitmapFont(new BitmapFont(Texture.fromBitmap(new baskTime()),
				XML(new baskTimeXML())));
			
			enemyHit = new hitSound();
			enemyHit.play(0, 0, new SoundTransform(0));
			
			bgMusic = new bgSound();
			bgMusic.play(0, 0, new SoundTransform(0));
		}
	}
}