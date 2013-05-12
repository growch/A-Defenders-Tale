package view
{
	
	import assets.FacebookContactMC;
	
	import com.milkmangames.nativeextensions.GVFacebookFriend;
	
	import control.EventController;
//	import control.GoViralService;
	
	import events.ViewEvent;
	
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	
	import model.DataModel;
	
	import util.fpmobile.controls.DraggableVerticalContainer;
	
	public class EmergencyContactSelectView extends MovieClip
	{
		private var _mc:MovieClip;
		private var _closeBtn:MovieClip;
		private var _facebookBtn:MovieClip;
		private var _submitBtn:MovieClip;
//		private var _confirm:MovieClip;
		private var _fbName:TextField;
//		private var _contactTxt:TextField;
		private var _questionMarkTxt:TextField;
		private var _dragVCont:DraggableVerticalContainer;
		private var _friendsVector:Vector.<GVFacebookFriend>
		
		private static const VERT_SPACER:int = 113;
		private static const HORIZ_SPACER:int = 75;
		private static const COLUMN_COUNT:int = 5;
		private var _holder:Sprite; 
		private var _friendsMCArray:Array;
		
		
		public function EmergencyContactSelectView(mc:MovieClip)
		{
			_mc = mc;
			super();
			init();
		}
		
		private function init() : void {
			_closeBtn = _mc.getChildByName("x_btn") as MovieClip;
			_closeBtn.addEventListener(MouseEvent.CLICK, closeClick);
			
			_submitBtn = _mc.getChildByName("submit_btn") as MovieClip;
			_submitBtn.alpha = .5;
			
			_fbName = _mc.getChildByName("name_txt") as TextField;
			
//			_confirm = _mc.getChildByName("confirm_mc") as MovieClip;
//			_confirm.visible = false;
			
//			_contactTxt = _confirm.getChildByName("contact_txt") as TextField;
//			_contactTxt.autoSize = TextFieldAutoSize.LEFT;
//			_questionMarkTxt = _confirm.getChildByName("questionMark_txt") as TextField;
			
			_dragVCont = new DraggableVerticalContainer(0, 0x000000, 0, true); 
			_dragVCont.width = 380;
			_dragVCont.height = 380;
			_dragVCont.SCROLL_INDICATOR_RIGHT_PADDING = 0;
			_dragVCont.x = 98;
			_dragVCont.y = 163;
//			_dragVCont.addChild(_mc);
//			_dragVCont.refreshView(true);
			
			_holder = new Sprite();
			
			_mc.addChild(_dragVCont);
		}
		
		public function destroy():void
		{
			_closeBtn.removeEventListener(MouseEvent.CLICK, closeClick);
			
			if (_submitBtn.hasEventListener(MouseEvent.CLICK)) {
				_submitBtn.removeEventListener(MouseEvent.CLICK, submitClick);
			}
			
			if (_friendsVector) {
				for (var i:int = 0; i < _friendsVector.length; i++) 
				{
					var thisFriendMC:MovieClip = _friendsMCArray[i] as MovieClip;
					thisFriendMC.removeEventListener(MouseEvent.CLICK, friendClick);
				}
			}
			
			_dragVCont.dispose();
			_mc.removeChild(_dragVCont);
		}
		
		private function closeClick(e:MouseEvent) : void {
			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.CLOSE_EMERGENCY_OVERLAY));
		}
		
		public function populateFacebookName(ns:String) : void {
			_fbName.text = ns.toUpperCase();
		}
		
		public function populateFacebookFriends(friendsVector:Vector.<GVFacebookFriend>):void 
		{
			_friendsVector = friendsVector;
			_friendsMCArray = new Array();
			var nextY:int = 0;
			var nextX:int = 0;
			for (var i:int = 0; i < friendsVector.length; i++) 
			{
				if (i != 0 && (i % COLUMN_COUNT) == 0) {
					nextY += VERT_SPACER;
					nextX = 0;
				}
				var thisContact:FacebookContactMC = new FacebookContactMC();
				thisContact.mouseChildren = false;
				thisContact.ID = i;
				thisContact.FBID = friendsVector[i].id;
				thisContact.name_txt.text = friendsVector[i].name;
				thisContact.x = nextX*HORIZ_SPACER;
				thisContact.y = nextY;
				thisContact.addEventListener(MouseEvent.CLICK, friendClick);
				
				_holder.addChild(thisContact);
				
				_friendsMCArray.push(thisContact);
				
				nextX++;
			}
			_dragVCont.addChild(_holder);
			_dragVCont.refreshView(true);
		}
		
		protected function friendClick(event:MouseEvent):void
		{
			if (_dragVCont.isDragging) return;
			
			var thisFriend:MovieClip = event.target as MovieClip;
			var thisID:int = thisFriend.ID;
			for (var i:int = 0; i < _friendsMCArray.length; i++) 
			{
				var thisFriendMC:MovieClip = _friendsMCArray[i] as MovieClip;
				if (i == thisID) {
					thisFriendMC.alpha = 1;
				} else {
					thisFriendMC.alpha = .4;
				}
			}
//			_contactTxt.text = _friendsVector[thisID].name.toUpperCase();
//			_questionMarkTxt.x = _contactTxt.x + _contactTxt.textWidth+2;
//			_confirm.visible = true;
			_submitBtn.alpha = 1;
			if (!_submitBtn.hasEventListener(MouseEvent.CLICK)) {
				_submitBtn.addEventListener(MouseEvent.CLICK, submitClick);
			}
			var fullName:Array = _friendsVector[thisID].name.split(" ");
			var firstName:String = fullName[0];
			
			DataModel.defenderInfo.contact = firstName;
			DataModel.defenderInfo.contactFBID = thisFriend.FBID;
		}
		
		private function submitClick(e:MouseEvent) : void {
			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.CONTACT_SELECTED));
		}
	
	}
}