package view
{
	import com.greensock.TweenMax;
	import com.greensock.easing.Quad;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	import assets.ApplicationMC;
	
	import control.EventController;
	
	import events.ApplicationEvent;
	import events.ViewEvent;
	
	import model.DataModel;
	
	import util.StringUtil;
	
	public class ApplicationView extends MovieClip implements IPageView
	{
		private var _mc:ApplicationMC;
		private var _nameTF:TextField;
		private var _ageTF:TextField;
		private var _hairTF:TextField;
		private var _beverageTF:TextField;
		private var _contactTF:TextField;
//		private var _swearTF:TextField;
		private var _romantic:OptionsView;
		private var _sidekick:OptionsView;
		private var _weapon:OptionsView;
		private var _instrument:OptionsView;
		private var _wardrobe:OptionsView;
		private var _gender:OptionsView;
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
		
		
		public function ApplicationView()
		{
			super();
			
			addEventListener(Event.ADDED_TO_STAGE, init);
			EventController.getInstance().addEventListener(ViewEvent.CLOSE_EMERGENCY_OVERLAY, removeEmergencyOverlay);
			EventController.getInstance().addEventListener(ViewEvent.CONTACT_SELECTED, contactSelected);
		}
		
		private function init(e:Event) : void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			_mc = new ApplicationMC();
			
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
			
			_nameTF = _mc.getChildByName("name_txt") as TextField;
			_nameTF.maxChars = 23;
			_nameTF.addEventListener(FocusEvent.FOCUS_OUT, nameFocusOut);
			
			_ageTF = _mc.getChildByName("age_txt") as TextField;
			_ageTF.restrict = "0123456789";
			_ageTF.maxChars = 4;
			
			_hairTF = _mc.getChildByName("hairColor_txt") as TextField;
//			_hairTF.addEventListener(Event.CHANGE, capitalizeText);
			_hairTF.maxChars = 100;
			
			_beverageTF = _mc.getChildByName("beverage_txt") as TextField;
//			_beverageTF.addEventListener(Event.CHANGE, capitalizeText);
			_beverageTF.maxChars = 100;
			
			_contactTF = _mc.getChildByName("contact_txt") as TextField;
			_contactTF.addEventListener(FocusEvent.FOCUS_IN, showEmergencyContactOverlay);
			_contactTF.maxChars = 100;
			
//			_swearTF = _mc.getChildByName("swear_txt") as TextField;
			
			var gender:MovieClip = _mc.getChildByName("gender_mc") as MovieClip;
			_gender = new OptionsView(gender, 3);
			
			_contactGender = new OptionsView(_mc.contactGender_mc, 2);
			
			var romantic:MovieClip = _mc.getChildByName("romantic_mc") as MovieClip;
			_romantic = new OptionsView(romantic, 3);
			
			var sidekick:MovieClip = _mc.getChildByName("sidekick_mc") as MovieClip;
			_sidekick = new OptionsView(sidekick, 3);
			
			var weapon:MovieClip = _mc.getChildByName("weapon_mc") as MovieClip;
			_weapon = new OptionsView(weapon, 3);
			
			var instrument:MovieClip = _mc.getChildByName("instrument_mc") as MovieClip;
			_instrument = new OptionsView(instrument, 3);
			
			var attire:MovieClip = _mc.getChildByName("attire_mc") as MovieClip;
			_wardrobe = new OptionsView(attire, 3);
			
			_submitBtn = _mc.getChildByName("submit_btn") as MovieClip;
			_submitBtn.buttonMode = true;
			_submitBtn.addEventListener(MouseEvent.CLICK, submitClick);
			
			_today = new Date();
			
			addChild(_mc);
			
			TweenMax.from(_mc, 1.6, {y:DataModel.APP_HEIGHT, ease:Quad.easeInOut});
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
			
//			_swearTF.alpha = 0;
//			
//			var thisTF:TextField = event.target as TextField;
//			var str:String = thisTF.text;
//			var firstChar:String = str.substr(0, 1);
//			var restOfString:String = str.substr(1, str.length);
//			thisTF.text = firstChar.toUpperCase()+restOfString.toLowerCase();
//			
//			if (_nameTF.text != "") {
//				_swearTF.text = "I, "+_nameTF.text+", on this day of "+_months[_today.month]+" " + _today.date+", " + _today.fullYear + ", being of sound mind and sounder constitution, do solemnly swear that I will protect the realm from such nefarious foes as orcs, ghouls, giant squid, things that go bump in the night, and the evil Prince Nero." 
//					
//			}
//			TweenMax.to(_swearTF, 1, {alpha:1});
		}
		
		protected function submitClick(event:MouseEvent):void
		{
			if (errorsFound()) {
//				return;
			}
			
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
			
			EventController.getInstance().dispatchEvent(new ApplicationEvent(ApplicationEvent.APPLICATION_SUBMITTED, infoObject));
		}
		
		private function errorsFound() : Boolean {
			var errorCount: int;
			
			if (!_romantic.isSelected()) errorCount++;
			if (!_sidekick.isSelected()) errorCount++;
			if (!_weapon.isSelected()) errorCount++;
			if (!_instrument.isSelected()) errorCount++;
			if (!_wardrobe.isSelected()) errorCount++;
			if (!_gender.isSelected()) errorCount++;
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
		
		public function destroy():void
		{
			_submitBtn.removeEventListener(MouseEvent.CLICK, submitClick);
			
			EventController.getInstance().removeEventListener(ViewEvent.CLOSE_EMERGENCY_OVERLAY, removeEmergencyOverlay);
			EventController.getInstance().removeEventListener(ViewEvent.CONTACT_SELECTED, contactSelected);
			
			_nameTF.removeEventListener(FocusEvent.FOCUS_OUT, nameFocusOut);
			
			_gender.destroy();
			_romantic.destroy();
			_sidekick.destroy();
			_weapon.destroy();
			_instrument.destroy();
			_wardrobe.destroy();
		}
	}
}