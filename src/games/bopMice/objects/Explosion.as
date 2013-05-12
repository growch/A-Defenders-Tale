package objects
{
	import core.Assets;
	
	import starling.extensions.PDParticleSystem;
	import starling.textures.Texture;
	
	public class Explosion extends PDParticleSystem
	{
		public function Explosion()
		{
			super(XML(new Assets.starsXML()), Assets.ta.getTexture("star"));
		}
	}
}