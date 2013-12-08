package games.sandlands.objects
{
	import com.greensock.TweenMax;
	import com.greensock.easing.Quad;
	
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	
	import control.EventController;
	
	import events.ViewEvent;
	
	import model.DataModel;
	
	public class Enemy extends flash.display.MovieClip 
	{
		private var enemy:MovieClip;
//		public var hit:Boolean;
		private var _enemMC:MovieClip;
		private var _hitMC:MovieClip;
		private var _ogX:Number;
		private var _ogY:Number;
		private var _ogR:Number;
		private var _object:MovieClip;
		private var _stone:MovieClip;
		
		public function Enemy(enemMC:MovieClip)
		{
			_enemMC = enemMC;
			
			_stone = _enemMC.getChildByName("stone_mc") as MovieClip;
			_stone.visible = false;
			
			_object = _enemMC.getChildByName("object_mc") as MovieClip;
			
			//GRAPHICS
			DataModel.getInstance().setGraphicResolution(_stone);
			DataModel.getInstance().setGraphicResolution(_object);
			if (_enemMC.name == "portrait_mc"){
				DataModel.getInstance().setGraphicResolution(_enemMC.nail_mc);
			}
			if (_enemMC.name == "spoon_mc"){
				DataModel.getInstance().setGraphicResolution(_enemMC.hook_mc);
			}
			if (_enemMC.name == "globe_mc"){
				DataModel.getInstance().setGraphicResolution(_enemMC.bottom_mc);
			}
			
			_ogX = _object.x;
			_ogY = _object.y;
			_ogR = _object.rotation;
			
			_hitMC = _enemMC.getChildByName("hit_mc") as MovieClip;
			
			_hitMC.addEventListener(MouseEvent.CLICK, moveObject);
			
		}
		
		public function destroy():void
		{
			_hitMC.removeEventListener(MouseEvent.CLICK, moveObject);
			_hitMC = null;
			_enemMC = null;
			_stone = null;
			_object = null;
			_hitMC = null;
		}
		
		protected function moveObject(event:MouseEvent):void
		{
			
			switch(_enemMC.name)
			{
				case "owl_mc":
				{
					TweenMax.to(_object, .3, {x:_ogX+75, ease:Quad.easeOut, onComplete:function():void
					{
						if (_stone.visible) {
							EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.SAND_GAME_STONE_FOUND));
							return;
						}
						TweenMax.to(_object, .2, {x:_ogX, ease:Quad.easeInOut, delay:.5});
					}
					});
					EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.SAND_GAME_OWL_SOUND));
					break;
				}
				
				case "portrait_mc":
				{
					TweenMax.to(_object, .4, {rotation:_ogR+45, ease:Quad.easeOut, onComplete:function():void
					{
						if (_stone.visible) {
							EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.SAND_GAME_STONE_FOUND));
							return;
						}
						TweenMax.to(_object, .3, {rotation:_ogR, ease:Quad.easeInOut, delay:.5});
					}
					});
					EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.SAND_GAME_CLICK_SOUND));
					break;
				}
					
				case "hat_mc":
				{
					TweenMax.to(_object, .3, {y:_ogY-50, ease:Quad.easeOut, onComplete:function():void
					{
						if (_stone.visible) {
							EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.SAND_GAME_STONE_FOUND));
							return;
						}
						TweenMax.to(_object, .2, {y:_ogY, ease:Quad.easeInOut, delay:.5});
					}
					});
					EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.SAND_GAME_CLICK_SOUND));
					break;
				}	
					
				case "spoon_mc":
				{
					TweenMax.to(_object, .3, {rotation:_ogR-20, ease:Quad.easeOut, onComplete:function():void
					{
						if (_stone.visible) {
							EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.SAND_GAME_STONE_FOUND));
							return;
						}
						TweenMax.to(_object, .2, {rotation:_ogR, ease:Quad.easeInOut, delay:.5});
					}
					});
					EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.SAND_GAME_CLICK_SOUND));
					break;
				}	
					
				case "skull_mc":
				{
					TweenMax.to(_object, .3, {y:_ogY-30, ease:Quad.easeOut, onComplete:function():void
					{
						if (_stone.visible) {
							EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.SAND_GAME_STONE_FOUND));
							return;
						}
						TweenMax.to(_object, .2, {y:_ogY, ease:Quad.easeInOut, delay:.5});
					}
					});
					EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.SAND_GAME_CLICK_SOUND));
					break;
				}
					
				case "globe_mc":
				{
					TweenMax.to(_object, .35, {y:_ogY-50, ease:Quad.easeOut, onComplete:function():void
					{
						if (_stone.visible) {
							EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.SAND_GAME_STONE_FOUND));
							return;
						}
						TweenMax.to(_object, .25, {y:_ogY, ease:Quad.easeInOut, delay:.5});
					}
					});
					EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.SAND_GAME_CLICK_SOUND));
					break;
				}	
					
				default:
				{
					break;
				}
			}
		}
		private function setToIdle():void
		{
			_object.x = _ogX;
			_object.y = _ogY;
			_object.rotation = _ogR;
		}
		
		
		public function reset():void {
			setToIdle();
			_stone.visible = false;
		}
		
		public function update():void {
		}
		
		
		public function activateStone():void
		{
			_stone.visible = true;
		}
	}
}