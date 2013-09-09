package view
{
	import com.greensock.TweenMax;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import control.EventController;
	
	import events.ViewEvent;
	
	import util.SWFAssetLoader;
	
	
	public class _DebugView extends MovieClip implements IPageView
	{
		private var _mc:MovieClip;
		private var _SAL:SWFAssetLoader;
		
		public function _DebugView()
		{
			_SAL = new SWFAssetLoader("_empty", this);
			EventController.getInstance().addEventListener(ViewEvent.ASSET_LOADED, init);

		}
		
		public function destroy() : void {
			EventController.getInstance().removeEventListener(ViewEvent.DECISION_CLICK, decisionMade);
			
			removeChild(_mc);
			stage.removeEventListener(MouseEvent.CLICK, mcClick);
			_mc = null;
			
			_SAL.destroy();
			_SAL = null;
			
		}
		
		private function init(e:Event) : void {
			EventController.getInstance().removeEventListener(ViewEvent.ASSET_LOADED, init);
			_mc = _SAL.assetMC;	
			
			EventController.getInstance().addEventListener(ViewEvent.DECISION_CLICK, decisionMade);
			
			addChild(_mc);
			
			stage.addEventListener(MouseEvent.CLICK, mcClick);
			
		}
		
		protected function mcClick(event:MouseEvent):void
		{
//			!!!!!!! THINGS CAUSING SWFS TO NOT UNLOAD !!!!!!!!!!!
//			•	NOT HAVING THIS -> loader.autoDispose = true;
//			•	NOT NULLIFYING private vars referencing mcs
//			• setTimeouts that didn't fire - fixed with TM delayed calls
//			• having fonts embedded in library
//			• 1 stop() on any frame
			
			var tempObj:Object = new Object();
			//CRASHES iPAD1
//			tempObj.id = "theCattery.FollowView"; !!!! look into cache _tf as bitmap

			
			//DON'T UNLOAD
//			tempObj.id = "ApplicationView";
//			tempObj.id = "TitleScreenView";
			
//			tempObj.id = "prologue.IntroAllIslandsView";
//			tempObj.id = "sandlands.Sand2View";
//			tempObj.id = "sandlands.FindWizardView";
//

			
//			tempObj.id = "shipwreck.CaptainView";
//
//			tempObj.id = "capitol.GoWithPreviousView";
			

			
//			?????? QUESTIONABLE IN STORY ORDER
//			tempObj.id = "theCattery.BallView";
//			tempObj.id = "prologue.IntroAllIslandsView";
			
			//THESE UNLOAD
//			tempObj.id = "theCattery.AcceptOfferView";
//			tempObj.id = "theCattery.BallView";
//			tempObj.id = "theCattery.CatlingAffairsView";
//			tempObj.id = "theCattery.CatRanchShoreView";
//			tempObj.id = "theCattery.FollowView";
//			tempObj.id = "theCattery.FourthDoorView";
//			tempObj.id = "theCattery.GameWonView";
//			tempObj.id = "theCattery.Island1View";
//			tempObj.id = "theCattery.LingerView";
//			tempObj.id = "theCattery.MouseConsultationView";
//			tempObj.id = "theCattery.NoTrespassingView";
//			tempObj.id = "theCattery.PrivateAudienceView";
//			tempObj.id = "theCattery.RefuseOfferView";
//			tempObj.id = "theCattery.RendezvousView";
//			tempObj.id = "theCattery.ReturnToBoatView";
//			tempObj.id = "theCattery.ScratchEarsView";
//			tempObj.id = "theCattery.ThirdDoorView";
			
//			tempObj.id = "sandlands.ApprenticeView";
//			tempObj.id = "sandlands.HutView";
			
			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.DECISION_CLICK, tempObj));
			tempObj = null;
		}		
		
		protected function decisionMade(event:ViewEvent):void
		{
			TweenMax.killAll();
			_mc.stopAllMovieClips();
			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.SHOW_PAGE, event.data));
		}
	}
}