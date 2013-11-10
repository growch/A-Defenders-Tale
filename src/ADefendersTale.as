package
{
	import flash.desktop.NativeApplication;
	import flash.desktop.SystemIdleMode;
	import flash.display.MovieClip;
	import flash.display.StageAlign;
	import flash.display.StageQuality;
	import flash.events.Event;
	import flash.events.StatusEvent;
	import flash.net.URLRequest;
	import flash.text.AntiAliasType;
	
	import mx.controls.Alert;
	
	import air.net.URLMonitor;
	
	import control.ViewController;
	
	import events.ApplicationEvent;
	
	import model.DataModel;
	
	import util.Formats;
	import util.Logger;
	import util.Text;
	
	// THINK ABOUT FRAME RATE AND CHANGING FOR PERFORMANCE
// ++++++++++++++++++
	[SWF(width="768", height="1024", frameRate="60", backgroundColor="0x000000")]
// FOR TESTING TO FIT LAPPY SCREEN
//	[SWF(width="1050", height="1400", frameRate="60", backgroundColor="0x000000")] 
	
	public class ADefendersTale extends MovieClip
	{
		private var _dm:DataModel;
		private var _vc:ViewController; 
		private var monitor:URLMonitor;
		
		public function ADefendersTale()
		{
			super();
			
			addEventListener(Event.ADDED_TO_STAGE, init); 
		}
		
		private function init(e:Event): void {
			stage.align = StageAlign.TOP_LEFT;
			stage.quality = StageQuality.LOW; //HUGE PERFOMANCE BOOST!!!!!!!!
			
			//SunlightGame turns this on temporarily
			stage.autoOrients = false;
			
			// This will keep the device from "sleeping"
			NativeApplication.nativeApplication.systemIdleMode = SystemIdleMode.KEEP_AWAKE; 
			
			// Detects a general change in network status
			NativeApplication.nativeApplication.addEventListener(Event.NETWORK_CHANGE,onNetworkChange);
			//check for initial connection
			NativeApplication.nativeApplication.dispatchEvent(new Event(Event.NETWORK_CHANGE));
			
			_dm = DataModel.getInstance(); 
			
			_dm.addEventListener( ApplicationEvent.APP_DATA_LOADED, onApplicationDataLoaded ); 
			_dm.addEventListener( ApplicationEvent.DISPLAY_ERROR, onLoadingError );
			_dm.loadApplicationConfigurationFile();
			
			//set security
//			Security.allowDomain("*"); 
			
		}
		
		//Checking for network connectivity
		protected function onNetworkChange(e:Event):void
		{
			monitor = new URLMonitor(new URLRequest('http://www.adobe.com'));
			monitor.addEventListener(StatusEvent.STATUS, netConnectivity);
			monitor.start();
		}
		
		protected function netConnectivity(e:StatusEvent):void 
		{
			if(monitor.available)
			{
				DataModel.getInstance().networkConnected = true;
			}
			else
			{
				DataModel.getInstance().networkConnected = false;
			}
			monitor.stop();
		}
				
		
		private function onLoadingError(e : ApplicationEvent) : void 
		{
			var error : Text = new Text(String(e.data), Formats.errorFormat(), 450, true, true, false);  
			error.antiAliasType = AntiAliasType.ADVANCED; 
			error.x = 10;
			error.y = 10;
			error.selectable = true;
			error.mouseEnabled = false;
			addChild(error);
			
			Logger.log( String(e.data)); 
		}
		
		private function onApplicationDataLoaded( e:ApplicationEvent):void
		{
			_vc = new ViewController( MovieClip(this) );
			
//			var stats:Stats = new Stats();
//			addChild(stats);
			
			_dm.removeEventListener( ApplicationEvent.APP_DATA_LOADED, onApplicationDataLoaded );
		}
		
	}
}