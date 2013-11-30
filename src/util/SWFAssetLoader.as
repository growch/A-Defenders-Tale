package util
{
	import com.greensock.TweenMax;
	import com.greensock.events.LoaderEvent;
	import com.greensock.loading.SWFLoader;
	
	import flash.display.MovieClip;
	
	import control.EventController;
	
	import events.ViewEvent;
	
	import model.DataModel;

	public class SWFAssetLoader
	{
		private var _loader:SWFLoader;
		public var assetMC:MovieClip;
		
		public function SWFAssetLoader(thisSWF:String, thisContainer:MovieClip)
		{
//			_loader = new SWFLoader("app:/assets/swfs/"+thisSWF+".swf", {container:thisContainer, noCache:true, context:DataModel.LoadContext, onInit:initLoadedSWF});
			_loader = new SWFLoader("app:/assets/swfs/"+thisSWF+".swf", {container:thisContainer, noCache:true, context:DataModel.LoadContext, onComplete:initLoadedSWF});
//			_loader = new SWFLoader("assets/swfs/"+thisSWF+".swf", {container:thisContainer, noCache:true, context:DataModel.LoadContext, onInit:initLoadedSWF});
			_loader.load();
		}
		
		private  function initLoadedSWF(event:LoaderEvent):void {
//			trace("initLoadedSWF");
			assetMC = _loader.getSWFChild("mc_mc") as MovieClip;
			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.ASSET_LOADED));
			_loader.addEventListener(LoaderEvent.UNLOAD, swfUnloaded);
		}
		
		protected function swfUnloaded(event:LoaderEvent):void
		{
			
//			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.ASSET_UNLOADED));
//			TweenMax.delayedCall(2, unloadNotification); 
			unloadNotification();
		}
		
		private function unloadNotification():void {
			trace("$$$%$%$%$%$%$%%$ unloadNotification");
			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.ASSET_UNLOADED));
		}
		
		public function destroy():void
		{
//			trace("destroy");
//			_loader.unload();
			_loader.dispose(true);
			_loader.removeEventListener(LoaderEvent.UNLOAD, swfUnloaded);
			_loader = null;
		}
	}
}