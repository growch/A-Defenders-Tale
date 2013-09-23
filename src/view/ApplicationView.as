package view
{
	import com.greensock.TweenMax;
	import com.greensock.easing.Quad;
	import com.neriksworkshop.lib.ASaudio.Track;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	
	import assets.FacebookContactMC;
	import assets.fonts.Caslon224;
	import assets.fonts.Caslon224BookItalic;
	
	import control.EventController;
	
	import events.ApplicationEvent;
	import events.ViewEvent;
	
	import model.DataModel;
	import model.DefenderApplicationInfo;
	
	import util.SWFAssetLoader;
	import util.StringUtil;
	
	public class ApplicationView extends MovieClip implements IPageView
	{
		private var _mc:MovieClip;
		private var _nameTF:TextField;
		private var _ageTF:TextField;
		private var _hairTF:TextField;
		private var _beverageTF:TextField;
		private var _contactTF:TextField;
		private var _gender:OptionsView;
		private var _romantic:OptionsView;
		private var _sidekick:OptionsView;
		private var _weapon:OptionsView;
		private var _instrument:OptionsView;
		private var _wardrobe:OptionsView;
		private var _contactGender:OptionsView;
		private var _submitBtn:MovieClip;
		
		private var _error1:MovieClip;
		private var _error2:MovieClip;
		private var _error3:MovieClip;
		private var _error4:MovieClip;
		private var _error5:MovieClip;
		private var _today:Date;
		private var _months:Array = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
		private var _emergencyOverlay:EmergencyContactView;
		private var _SAL:SWFAssetLoader;
		private var _tfm:TextFormat;
		private var _bgSound:Track;
		
		public function ApplicationView()
		{
			_SAL = new SWFAssetLoader("common.ApplicationMC", this);
			EventController.getInstance().addEventListener(ViewEvent.ASSET_LOADED, init);

			EventController.getInstance().addEventListener(ViewEvent.CLOSE_EMERGENCY_OVERLAY, removeEmergencyOverlay);
			EventController.getInstance().addEventListener(ViewEvent.CONTACT_SELECTED, contactSelected);
			
//			!!!IMPORTANT
			DataModel.getInstance().resetBookData();
			DataModel.defenderInfo = new DefenderApplicationInfo();
		}
		
		public function destroy():void
		{
			_submitBtn.removeEventListener(MouseEvent.CLICK, submitClick);
			_submitBtn = null;
			
			_error1 = null;
			_error2 = null;
			_error3 = null;
			_error4 = null;
			_error5 = null;
			
			_nameTF.removeEventListener(FocusEvent.FOCUS_OUT, nameFocusOut);
			_contactTF.removeEventListener(FocusEvent.FOCUS_IN, showEmergencyContactOverlay);
			
			_nameTF = null;
			_ageTF = null;
			_hairTF = null;
			_beverageTF = null;
			_contactTF = null;
			
			_today = null;
			_months = null;
			_tfm = null;
//			errorCount = null;
			_bgSound = null;
			
			EventController.getInstance().removeEventListener(ViewEvent.CLOSE_EMERGENCY_OVERLAY, removeEmergencyOverlay);
			EventController.getInstance().removeEventListener(ViewEvent.CONTACT_SELECTED, contactSelected);
			
			_gender.destroy();
			_romantic.destroy();
			_sidekick.destroy();
			_weapon.destroy();
			_instrument.destroy();
			_wardrobe.destroy();
			_contactGender.destroy();
//			
			_gender = null;
			_romantic = null;
			_sidekick = null;
			_weapon = null;
			_instrument = null;
			_wardrobe = null;
			_contactGender = null;			
			
			//!IMPORTANT
			DataModel.getInstance().removeAllChildren(_mc);
			_SAL.destroy();
			_SAL = null;
			removeChild(_mc);
			_mc = null;
		}
		
		private function init(e:Event) : void {
			EventController.getInstance().removeEventListener(ViewEvent.ASSET_LOADED, init);
			_mc = _SAL.assetMC;
			
			_error1 = _mc.getChildByName("error1_mc") as MovieClip;
			_error1.visible = false;
			_error2 = _mc.getChildByName("error2_mc") as MovieClip;
			_error2.visible = false;
			_error3 = _mc.getChildByName("error3_mc") as MovieClip;
			_error3.visible = false;
			_error4 = _mc.getChildByName("error4_mc") as MovieClip;
			_error4.visible = false;
			_error5 = _mc.getChildByName("error5_mc") as MovieClip;
			_error5.visible = false;
			
			_tfm = new TextFormat();
			_tfm.size = 16;
			_tfm.color = 0x621414;
			_tfm.font = new Caslon224().fontName;
			
			_nameTF = makeTextRemoveText(_mc.name_txt);
			_nameTF.maxChars = 23;
			_nameTF.addEventListener(FocusEvent.FOCUS_OUT, nameFocusOut);
			
			_ageTF = makeTextRemoveText(_mc.age_txt);
			_ageTF.restrict = "0123456789";
			_ageTF.maxChars = 4;
			
			_hairTF = makeTextRemoveText(_mc.hairColor_txt);
			_hairTF.maxChars = 20;
			
			_beverageTF = makeTextRemoveText(_mc.beverage_txt);
			_beverageTF.maxChars = 25;
			
			_contactTF = makeTextRemoveText(_mc.contact_txt);
			_contactTF.addEventListener(FocusEvent.FOCUS_IN, showEmergencyContactOverlay);
			_contactTF.maxChars = 40;
			
			_gender = new OptionsView(_mc.gender_mc, 3);
			_romantic = new OptionsView(_mc.romantic_mc, 3);
			_sidekick = new OptionsView(_mc.sidekick_mc, 3);
			_weapon = new OptionsView(_mc.weapon_mc, 3);
			_instrument = new OptionsView(_mc.instrument_mc, 3);
			_wardrobe = new OptionsView(_mc.attire_mc, 3);
			_contactGender = new OptionsView(_mc.contactGender_mc, 2);
			
			_submitBtn = _mc.getChildByName("submit_btn") as MovieClip;
			_submitBtn.buttonMode = true;
			_submitBtn.addEventListener(MouseEvent.CLICK, submitClick);
			
			_today = new Date();
			
			addChild(_mc);
			
			TweenMax.from(_mc, 1.6, {y:DataModel.APP_HEIGHT, ease:Quad.easeInOut});
			
			_bgSound = new Track("assets/audio/global/DefenderTheme.mp3");
			_bgSound.start(true);
			_bgSound.loop = true;
			
//			TESTING!!!!
			var thisContact:FacebookContactMC = new FacebookContactMC();
			thisContact.name_txt.text = "XXXX";
			thisContact.x = 200;
			thisContact.y = 100;
			_mc.addChild(thisContact);
			
		}
		
		private function makeTextRemoveText(thisTF:TextField) : TextField {
			var tf:TextField = new TextField();
			tf.type = TextFieldType.INPUT; 
			tf.antiAliasType = AntiAliasType.ADVANCED;
			tf.embedFonts = true;
			tf.x = thisTF.x;
			tf.y = thisTF.y + 4;
			tf.width = thisTF.width;
			tf.height = 45;
			tf.defaultTextFormat = _tfm;
//			tf.background = true;
			
			_mc.removeChild(thisTF);
			_mc.addChild(tf);
			
			return tf;
		}
		
		private function showEmergencyContactOverlay(event:FocusEvent) : void 
		{
			_emergencyOverlay = new EmergencyContactView();
			addChild(_emergencyOverlay);
		}
		
		protected function removeEmergencyOverlay(event:ViewEvent):void
		{
			_emergencyOverlay.destroy();
			removeChild(_emergencyOverlay);
			_emergencyOverlay = null;
		}
		
		protected function contactSelected(event:ViewEvent):void
		{
			_emergencyOverlay.destroy();
			removeChild(_emergencyOverlay);
			_emergencyOverlay = null;
			_contactTF.text = StringUtil.ucFirst(DataModel.defenderInfo.contact); 
		}
		
		protected function capitalizeText(event:Event):void
		{
			var thisTF:TextField = event.target as TextField;
			thisTF.text = thisTF.text.toUpperCase();
		}
		
		private function nameFocusOut(event:FocusEvent) : void {
			_nameTF.text = StringUtil.ucFirst(_nameTF.text);
		}
		
		protected function submitClick(event:MouseEvent):void
		{
			if (errorsFound()) {
//				return;
			}
			
			DataModel.getInstance().buttonTap();
			
			var infoObject:Object = new Object();
			infoObject.defender = _nameTF.text;
			infoObject.age = _ageTF.text;
			infoObject.hair = _hairTF.text;
			infoObject.beverage = _beverageTF.text;
			infoObject.gender = _gender.optionNumSelected;
			infoObject.romantic = _romantic.optionNumSelected;
			infoObject.companion = _sidekick.optionNumSelected;
			infoObject.weapon = _weapon.optionNumSelected;
			infoObject.instrument = _instrument.optionNumSelected;
			infoObject.wardrobe = _wardrobe.optionNumSelected;
			infoObject.contact = _contactTF.text;
			infoObject.contactGender = _contactGender.optionNumSelected;
			
			_bgSound.stop(true);
			_bgSound.destroy();
			
			EventController.getInstance().dispatchEvent(new ApplicationEvent(ApplicationEvent.APPLICATION_SUBMITTED, infoObject));
		}
		
		private function errorsFound() : Boolean {
			var errorCount: int;
			
			if (!_gender.isSelected()) errorCount++;
			if (!_romantic.isSelected()) errorCount++;
			if (!_sidekick.isSelected()) errorCount++;
			if (!_weapon.isSelected()) errorCount++;
			if (!_instrument.isSelected()) errorCount++;
			if (!_wardrobe.isSelected()) errorCount++;
			if (!_contactGender.isSelected()) errorCount++;	
			
			if (_nameTF.text == "") {
				_error1.visible = true;
				errorCount++;
			} else {
				_error1.visible = false;
			}
			
			if (_ageTF.text == "") {
				_error2.visible = true;
				errorCount++;
			} else {
				_error2.visible = false;
			}
			
			if (_hairTF.text == "") {
				_error3.visible = true;
				errorCount++;
			} else {
				_error3.visible = false;
			}
			
			if (_beverageTF.text == "") {
				_error4.visible = true;
				errorCount++;
			} else {
				_error4.visible = false;
			}
			
			if (_contactTF.text == "") {
				_error5.visible = true;
				errorCount++;
			} else {
				_error5.visible = false;
			}
			
			if (errorCount > 0) {
				return true;
			} else {
				return false;
			}
			
		}
		
	}
}