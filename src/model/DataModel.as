﻿package model {	import com.greensock.loading.SWFLoader;	import com.neriksworkshop.lib.ASaudio.Track;		import flash.display.MovieClip;	import flash.events.ErrorEvent;	import flash.events.Event;	import flash.events.EventDispatcher;	import flash.events.IOErrorEvent;	import flash.net.URLLoader;	import flash.net.URLRequest;	import flash.system.LoaderContext;		import control.EventController;	import control.GoViralService;		import events.ApplicationEvent;		import util.StringUtil;
	/**	 * @author Mark Grochowski	 */	public class DataModel extends EventDispatcher	{				//Singleton instance		private static var inst : DataModel;		//path to application configuration  file		//this is the default value in case no value is passed through flashvars		public static var MAINAPPPATH : String = "";		public static var XML_DIR : String = "xml/";		public static var APPDATAURL : String = "config.xml"; 		public static var ALLOWDOWNLOAD : Boolean = true;		public static var APPLICATIONNAME : String = "";		public static var trackInfo : Object;				public static var resMultiplier:int = 1;				public static const APP_WIDTH:int = 768*resMultiplier;		public static const APP_HEIGHT:int = 1024*resMultiplier;				//application data object		public static var appData: ApplicationInfo;				public static var defenderInfo: DefenderApplicationInfo;		public static var defenderOptions : DefenderOptions = new DefenderOptions();				public static var goViralService: GoViralService;				private var _loader:URLLoader;				private var _cntr : Number = 0;				/** The list of loading methods, used to check if we fire onApplicationDataLoaded event. **/		private const _loadingMethods : Array = [ "onApplicationDataLoaded"];		public static const SOCIAL_FACEBOOK:String = "social_facebook";		public static const SOCIAL_TWITTER:String = "social_twitter";				public static var CURRENT_PAGE_ID : String = "";		public static var GOD_MODE : Boolean;		public static var CURRENT_ISLAND_INT: int;		public static var ISLANDS: Array = ["The Cattery", "Joyless Mountains", "Shipwreck Cove", "The Sandlands", "The Capitol"];		public static var ISLAND_NAMESPACE: Array = ["theCattery", "joylessMountains", "shipwreck", "sandlands", "capitol"];		public static var ISLAND_SELECTED: Array = [];		public static var WEAPON_SOUND_ARRAY:Array = ["assets/audio/global/Dagger.mp3","assets/audio/global/Quill.mp3","assets/audio/global/Spells.mp3"];		public static var COMPANION_SOUND_ARRAY:Array = ["assets/audio/global/Ostrich.mp3","assets/audio/global/Lizard.mp3","assets/audio/global/Goldfish.mp3"];		public static var INSTRUMENT_SOUND_ARRAY:Array = ["assets/audio/global/Flute.mp3","assets/audio/global/Kazoo.mp3","assets/audio/global/Guitar.mp3"];		public static var BALLAD_SOUND_ARRAY:Array = ["assets/audio/global/BalladFlute.mp3","assets/audio/global/BalladKazoo.mp3","assets/audio/global/BalladGuitar.mp3"];		//MIGHT NEED TO RESET ON RESTART/MAP		public static var SOCIAL_PLATFROM: String;		public static var COMPANION_TAKEN: Boolean = false;		public static var STONE_COUNT: int = 0;		public static var STONE_CAT: Boolean = false;		public static var STONE_PEARL: Boolean = false;		public static var STONE_SAND: Boolean = false;		public static var STONE_SERPENT: Boolean = false;		//MIGHT NEED TO RESET ON RESTART/MAP		public static var coinCount:int;		public static var captainBattled:Boolean;		public static var climbDone:Boolean;		public static var escalator1:Boolean;		public static var impatience3:Boolean;		public static var rally:Boolean;		public static var supplies:Boolean;		public static var smegTalk:Boolean;		public static var sandpit:Boolean;		public static var well:Boolean;		public static var sand5Ft:Boolean;		public static var dropsCorrect:Boolean;				public static var BOP_MICE_FPS:int = 44;		//IMPORTANT CUZ IPAD1 DOESN'T PERFORM VERY WELL		public static var ipad1:Boolean;		private var _swfLoader:SWFLoader;		public static var LoadContext:LoaderContext;		private var _btnTapSound:Track;		private var _endSound:Track;		private var _companionSound:Track;		private var _weaponSound:Track;		private var _instrumentSound:Object;		private var _oceanSound:Track;						/**		 * contructor.		 * 		 * @return nothing		 */			public function DataModel():void		{		}				/**		 * singleton.		 * 		 * @return instance of DataLoader		 */			public static function getInstance():DataModel{			if( inst == null ) inst = new DataModel();			return inst;		}			public function loadApplicationConfigurationFile():void		{			_loader = new URLLoader();			_loader.addEventListener( Event.COMPLETE, onApplicationDataLoaded );			_loader.addEventListener(IOErrorEvent.IO_ERROR, errorLoadingAppData );			_loader.load(new URLRequest( XML_DIR+APPDATAURL ));		}				private function errorLoadingAppData(e : ErrorEvent) : void 		{			dispatchEvent(new ApplicationEvent(ApplicationEvent.DISPLAY_ERROR, e.text));		}		/*public function loadTrackingFile():void		{			_loader = new URLLoader();			_loader.addEventListener( Event.COMPLETE, onTrackingDataLoaded );			_loader.load(new URLRequest( TRACKINGDATAURL ));			}		 * 		 */				private function onApplicationDataLoaded( e:Event ) : void		{			XML.ignoreWhitespace = true;			var xml:XML = new XML(e.target["data"]);						appData = ApplicationInfo.parseInfo( xml );			_loader.removeEventListener( Event.COMPLETE, onApplicationDataLoaded );			_loader.removeEventListener(IOErrorEvent.IO_ERROR, errorLoadingAppData );						// call the method to broadcast applicationDataLoaded event			applicationDataLoaded();			//			System.disposeXML(xml);			xml = null;		}				public function resetBookData():void		{			defenderInfo = null;			SOCIAL_PLATFROM = null;			GOD_MODE = false;			CURRENT_PAGE_ID = "";			ISLAND_SELECTED = [];			STONE_COUNT = 0;			coinCount = 0;			COMPANION_TAKEN =  false;			STONE_CAT = false;			STONE_PEARL = false;			STONE_SAND = false;			STONE_SERPENT = false;			captainBattled = false; 			climbDone = false; 			escalator1 = false; 			impatience3 = false; 			rally = false; 			supplies = false; 			smegTalk = false; 			sandpit = false; 			well = false; 			sand5Ft = false; 			dropsCorrect = false;			dispatchEvent(new ApplicationEvent(ApplicationEvent.RESTART_BOOK));		}				/*private function onTrackingDataLoaded ( event:Event ) : void		{			XML.ignoreWhitespace = true;			var xml:XML = new XML( event.target.data );						// Initialise tracking			trackingManager = TrackingManager.getInstance();			trackingManager.init( xml );						_loader.removeEventListener( Event.COMPLETE , onTrackingDataLoaded );						// call the method to broadcast applicationDataLoaded event			applicationDataLoaded();		}		 * 		 */				public function removeAllChildren(thisMC:MovieClip):void {//			trace("removeAllChildren");			while (thisMC.numChildren > 0) {//				trace(thisMC.getChildAt(0));				thisMC.removeChildAt(0);			}		}				private function applicationDataLoaded () : void		{			_cntr++;			if( _cntr == _loadingMethods.length )			{				dispatchEvent( new ApplicationEvent( ApplicationEvent.APP_DATA_LOADED ) );			}		}				public static function getGoViral():GoViralService{			if( goViralService == null ) goViralService = new GoViralService();			return goViralService;		}				public function randomRange(min:Number, max:Number) : Number {			return ((Math.random()*(max-min)) + min); 		}				public function replaceVariableText(thisString:String) : String {			// +++ DICTIONARY ITEMS			var pronoun1:String = appData.dictionary.pronoun1[defenderInfo.gender];			if (StringUtil.contains(thisString, "[Pronoun1]")) { 				thisString = StringUtil.replace(thisString, "[Pronoun1]", StringUtil.ucFirst(pronoun1));			}			thisString = StringUtil.replace(thisString, "[pronoun1]", pronoun1);			//			var pronoun2:String = appData.dictionary.pronoun2[defenderInfo.gender];			if (StringUtil.contains(thisString, "[Pronoun2]")) {				thisString = StringUtil.replace(thisString, "[Pronoun2]", StringUtil.ucFirst(pronoun2));			}			thisString = StringUtil.replace(thisString, "[pronoun2]", pronoun2);			//			var pronoun3:String = appData.dictionary.pronoun3[defenderInfo.gender];			if (StringUtil.contains(thisString, "[Pronoun3]")) {				thisString = StringUtil.replace(thisString, "[Pronoun3]", StringUtil.ucFirst(pronoun3));			}			thisString = StringUtil.replace(thisString, "[pronoun3]", pronoun3);			//			var pronoun4:String = appData.dictionary.pronoun4[defenderInfo.gender];			if (StringUtil.contains(thisString, "[Pronoun4]")) {				thisString = StringUtil.replace(thisString, "[Pronoun4]", StringUtil.ucFirst(pronoun4));			}			thisString = StringUtil.replace(thisString, "[pronoun4]", pronoun4);						// +++ DEFENDER DETAILS							thisString = StringUtil.replace(thisString, "[defender]", defenderInfo.defender);			thisString = StringUtil.replace(thisString, "[Defender]", StringUtil.ucFirst(defenderInfo.defender));			thisString = StringUtil.replace(thisString, "[age]", defenderInfo.age);			thisString = StringUtil.replace(thisString, "[hair]", defenderInfo.hair);			thisString = StringUtil.replace(thisString, "[beverage]", defenderInfo.beverage);			thisString = StringUtil.replace(thisString, "[gender]", defenderOptions.genderArray[defenderInfo.gender]);			thisString = StringUtil.replace(thisString, "[genderSpoken]", defenderOptions.genderSpokenArray[defenderInfo.gender]);			thisString = StringUtil.replace(thisString, "[romantic]", defenderOptions.romanticArray[defenderInfo.romantic]);			thisString = StringUtil.replace(thisString, "[companion]", defenderOptions.companionArray[defenderInfo.companion]);			thisString = StringUtil.replace(thisString, "[companionName]", defenderOptions.companionNameArray[defenderInfo.companion]);			thisString = StringUtil.replace(thisString, "[instrument]", defenderOptions.instrumentArray[defenderInfo.instrument]);			thisString = StringUtil.replace(thisString, "[wardrobeLong]", defenderOptions.wardrobeLongArray[defenderInfo.wardrobe]);			thisString = StringUtil.replace(thisString, "[wardrobeShort]", defenderOptions.wardrobeShortArray[defenderInfo.wardrobe]);			thisString = StringUtil.replace(thisString, "[weapon]", defenderOptions.weaponArray[defenderInfo.weapon]);						// +++ COMPANION			var compGenderInt:int;			if (defenderInfo.companion == 0) {				compGenderInt = 1;			} else {				compGenderInt = 0;			}			var pronoun1G:String = appData.dictionary.pronoun1[compGenderInt];			if (StringUtil.contains(thisString, "[CompanionPronoun1]")) { 				thisString = StringUtil.replace(thisString, "[CompanionPronoun1]", StringUtil.ucFirst(pronoun1G));			}			thisString = StringUtil.replace(thisString, "[companionPronoun1]", pronoun1G);			//			var pronoun2G:String = appData.dictionary.pronoun2[compGenderInt];			if (StringUtil.contains(thisString, "[CompanionPronoun2]")) {				thisString = StringUtil.replace(thisString, "[CompanionPronoun2]", StringUtil.ucFirst(pronoun2G));			}			thisString = StringUtil.replace(thisString, "[companionPronoun2]", pronoun2G);			//			var pronoun3G:String = appData.dictionary.pronoun3[compGenderInt];			if (StringUtil.contains(thisString, "[CompanionPronoun3]")) {				thisString = StringUtil.replace(thisString, "[CompanionPronoun3]", StringUtil.ucFirst(pronoun3G));			}			thisString = StringUtil.replace(thisString, "[companionPronoun3]", pronoun3G);			//			var pronoun4G:String = appData.dictionary.pronoun4[compGenderInt];			if (StringUtil.contains(thisString, "[CompanionPronoun4]")) {				thisString = StringUtil.replace(thisString, "[CompanionPronoun4]", StringUtil.ucFirst(pronoun4G));			}			thisString = StringUtil.replace(thisString, "[companionPronoun4]", pronoun4G);						// +++ CONTACT			thisString = StringUtil.replace(thisString, "[contact]", defenderInfo.contact);						var contGenderInt:int = defenderInfo.contactGender;						pronoun1G = appData.dictionary.pronoun1[contGenderInt];			if (StringUtil.contains(thisString, "[ContactPronoun1]")) { 				thisString = StringUtil.replace(thisString, "[ContactPronoun1]", StringUtil.ucFirst(pronoun1G));			}			thisString = StringUtil.replace(thisString, "[contactPronoun1]", pronoun1G);						pronoun2G = appData.dictionary.pronoun2[contGenderInt];			if (StringUtil.contains(thisString, "[ContactPronoun2]")) {				thisString = StringUtil.replace(thisString, "[ContactPronoun2]", StringUtil.ucFirst(pronoun2G));			}			thisString = StringUtil.replace(thisString, "[contactPronoun2]", pronoun2G);						pronoun3G = appData.dictionary.pronoun3[contGenderInt];			if (StringUtil.contains(thisString, "[ContactPronoun3]")) {				thisString = StringUtil.replace(thisString, "[ContactPronoun3]", StringUtil.ucFirst(pronoun3G));			}			thisString = StringUtil.replace(thisString, "[contactPronoun3]", pronoun3G);						pronoun4G = appData.dictionary.pronoun4[contGenderInt];			if (StringUtil.contains(thisString, "[ContactPronoun4]")) {				thisString = StringUtil.replace(thisString, "[ContactPronoun4]", StringUtil.ucFirst(pronoun4G));			}			thisString = StringUtil.replace(thisString, "[contactPronoun4]", pronoun4G);						// +++ PREVIOUS DEFENDER			var pdRomInt:int = defenderInfo.romantic;			var pdName:String = defenderOptions.previousDefenderArray[pdRomInt];			if (StringUtil.contains(thisString, "[PreviousDefender]")) {				thisString = StringUtil.replace(thisString, "[PreviousDefender]", StringUtil.ucFirst(pdName));			}			thisString = StringUtil.replace(thisString, "[previousDefender]", pdName);						pronoun1G = appData.dictionary.pronoun1[pdRomInt];			if (StringUtil.contains(thisString, "[PreviousDefenderPronoun1]")) { 				thisString = StringUtil.replace(thisString, "[PreviousDefenderPronoun1]", StringUtil.ucFirst(pronoun1G));			}			thisString = StringUtil.replace(thisString, "[previousDefenderPronoun1]", pronoun1G);						pronoun2G = appData.dictionary.pronoun2[pdRomInt];			if (StringUtil.contains(thisString, "[PreviousDefenderPronoun2]")) {				thisString = StringUtil.replace(thisString, "[PreviousDefenderPronoun2]", StringUtil.ucFirst(pronoun2G));			}			thisString = StringUtil.replace(thisString, "[previousDefenderPronoun2]", pronoun2G);						pronoun3G = appData.dictionary.pronoun3[pdRomInt];			if (StringUtil.contains(thisString, "[PreviousDefenderPronoun3]")) {				thisString = StringUtil.replace(thisString, "[PreviousDefenderPronoun3]", StringUtil.ucFirst(pronoun3G));			}			thisString = StringUtil.replace(thisString, "[previousDefenderPronoun3]", pronoun3G);						pronoun4G = appData.dictionary.pronoun4[pdRomInt];			if (StringUtil.contains(thisString, "[PreviousDefenderPronoun4]")) {				thisString = StringUtil.replace(thisString, "[PreviousDefenderPronoun4]", StringUtil.ucFirst(pronoun4G));			}			thisString = StringUtil.replace(thisString, "[previousDefenderPronoun4]", pronoun4G);						var pdGender:String;			if (defenderInfo.age < "18") {				pdGender = defenderOptions.previousDefenderGenderChildArray[pdRomInt];			} else {				pdGender = defenderOptions.previousDefenderGenderAdultArray[pdRomInt];			}			if (StringUtil.contains(thisString, "[PreviousDefenderGender]")) {				thisString = StringUtil.replace(thisString, "[PreviousDefenderGender]", StringUtil.ucFirst(pdGender));			}			thisString = StringUtil.replace(thisString, "[previousDefenderGender]", pdGender);						return thisString;		}				public function buttonTap():void {			_btnTapSound = new Track("assets/audio/global/Tap.mp3");			_btnTapSound.start();		}				public function endSound():void {			_endSound = new Track("assets/audio/global/TheEnd.mp3");			_endSound.start(true);		}				public function companionSound():void {			_companionSound = new Track(COMPANION_SOUND_ARRAY[defenderInfo.companion]);			_companionSound.start();		}				public function weaponSound():void {			_weaponSound = new Track(WEAPON_SOUND_ARRAY[defenderInfo.weapon]);			_weaponSound.start();		}				public function instrumentSound():void {			_instrumentSound = new Track(INSTRUMENT_SOUND_ARRAY[defenderInfo.instrument]);			_instrumentSound.start();		}				public function oceanSound():void {			_oceanSound = new Track("assets/audio/global/Ocean.mp3");			_oceanSound.loop = true;			_oceanSound.fadeAtEnd = true;			_oceanSound.start(true);		}				public function ShuffleArray(input:Array):void 		{			for (var i:int = input.length-1; i >=0; i--)			{				var randomIndex:int = Math.floor(Math.random()*(i+1));				var itemAtIndex:Object = input[randomIndex];				input[randomIndex] = input[i];				input[i] = itemAtIndex;			}		}					}}