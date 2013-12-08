package control 
{
import flash.display.Loader;
import flash.display.Sprite;
import flash.filesystem.File;
import flash.geom.Rectangle;
import flash.net.SharedObject;
import flash.net.URLRequest;
import flash.system.ApplicationDomain;
import flash.system.LoaderContext;
import flash.system.SecurityDomain;
import flash.text.TextField;
import com.milkmangames.nativeextensions.ios.*;
import com.milkmangames.nativeextensions.ios.events.*;

/** StoreKit Example App 
 * 
 * 
 * This sample app is built for two in-app-products: LEVELPACK_PRODUCT_ID, a non-consumable product, and
 * SPELL_PRODUCT_ID, a consumable product.  If you're using this code as an example the ids in those constants
 * need to be changed to match the ones you made in iTunes Connect.  See the PDF on how to set up products.
 * 
 * 
 * */
public class StoreKitService extends Sprite
{
	//
	// Definitions
	//
	
		
	/** Sample Product IDs, must match iTunes Connect Items */
	private static const LEVELPACK_PRODUCT_ID:String="your_product_id";
	private static const SPELL_PRODUCT_ID:String="your_product_id";
	
	private static const UNLOCK_ID:String="com.2ndstringproductions.ADefendersTale.UnlockBook";

	//
	// Instance Variables
	//
	
	/** Status */
//	private var txtStatus:TextField;
	
	/** Buttons */
//	private var buttonContainer:Sprite;
	
	/** Shared Object.  Used in this example to remember what we've bought. */
	private var sharedObject:SharedObject;
	
	/** Showing what you own */
//	private var txtInventory:TextField;
	
	//
	// Public Methods
	//
	
	/** Create New StoreKitExample */
	public function StoreKitService() 
	{		
//		createUI();
//		hideUI();
		
		if (!StoreKit.isSupported())
		{
			log("Store Kit iOS purchases is not supported on this platform.");
			return;
		}

		log("initializing StoreKit..");	

		StoreKit.create();

		log("StoreKit Initialized.");
		
		// make sure that purchases will actually work on this device before continuing!
		// (for example, parental controls may be preventing them.)
		if (!StoreKit.storeKit.isStoreKitAvailable())
		{
			log("!!! Store is disabled on this device. !!!");
			return;
		}
		
		// add listeners here
		StoreKit.storeKit.addEventListener(StoreKitEvent.PRODUCT_DETAILS_LOADED,onProductsLoaded);
		StoreKit.storeKit.addEventListener(StoreKitEvent.PURCHASE_SUCCEEDED,onPurchaseSuccess);
		StoreKit.storeKit.addEventListener(StoreKitEvent.PURCHASE_CANCELLED,onPurchaseUserCancelled);
		StoreKit.storeKit.addEventListener(StoreKitEvent.TRANSACTIONS_RESTORED, onTransactionsRestored);
		
		// adding error events. always listen for these to avoid your program failing.
		StoreKit.storeKit.addEventListener(StoreKitErrorEvent.PRODUCT_DETAILS_FAILED,onProductDetailsFailed);
		StoreKit.storeKit.addEventListener(StoreKitErrorEvent.PURCHASE_FAILED,onPurchaseFailed);
		StoreKit.storeKit.addEventListener(StoreKitErrorEvent.TRANSACTION_RESTORE_FAILED, onTransactionRestoreFailed);
		
		// OPTIONAL listeners for apple-hosted, downloadable content.
		StoreKit.storeKit.addEventListener(StoreKitEvent.DOWNLOAD_FINISHED, onDownloadFinished);
		StoreKit.storeKit.addEventListener(StoreKitEvent.DOWNLOAD_UPDATED, onDownloadUpdated);
		StoreKit.storeKit.addEventListener(StoreKitErrorEvent.DOWNLOAD_FAILED, onDownloadFailed);
		
		// OPTIONAL listeners for displayProductView() events.  
		StoreKit.storeKit.addEventListener(StoreKitEvent.PRODUCT_VIEW_DISPLAYED, onProductViewDisplayed);
		StoreKit.storeKit.addEventListener(StoreKitEvent.PRODUCT_VIEW_DISMISSED, onProductViewDismissed);
		StoreKit.storeKit.addEventListener(StoreKitEvent.PRODUCT_VIEW_LOADED, onProductViewLoaded);
		StoreKit.storeKit.addEventListener(StoreKitErrorEvent.PRODUCT_VIEW_FAILED, onProductViewFailed);
		
		// initialize a sharedobject that's holding our inventory.
		initSharedObject();
		
		// the first thing to do is to supply a list of product ids you want to display,
		// and Apple's server will respond with a list of their details (titles, price, etc)
		// assuming the ids you pass in are valid.  Even if you don't need to use this 
		// information, you should make the details request before doing a purchase.
		
		// the list of ids is passed in as an as3 vector (typed Array.)
		var productIdList:Vector.<String>=new Vector.<String>();
//		productIdList.push(LEVELPACK_PRODUCT_ID);
//		productIdList.push(SPELL_PRODUCT_ID);
		productIdList.push(UNLOCK_ID);

		
		// when this is done, we'll get a PRODUCT_DETAILS_LOADED or PRODUCT_DETAILS_FAILED event and go on from there...
		log("Loading product details...");
		StoreKit.storeKit.loadProductDetails(productIdList);		
		
	}
	
	/** Creates a SharedObject that we use in this example for remembering what you've already bought */
	private function initSharedObject():void
	{
		// initialize the saved state.  this is a very simple example implementation
		// and you probably want a more robust one in a real application.  you may
		// also consider obfuscating the data, and/or using an SQL database isntead
		// of a shared object.
		this.sharedObject=SharedObject.getLocal("myPurchases");
		
		// check if the application has been loaded before.  if not, create a store of our purchases in the sharedobject.
		if (sharedObject.data["inventory"]==null)
		{			
			sharedObject.data["inventory"]=new Object();
		}
		
		updateInventoryMessage();
		
	}
	
	/** Example of how to purchase a product */
	public function purchaseSpell():void
	{
		// for this to work, you must have added the value of SPELL_PRODUCT_ID in the iTunes Connect website
		log("start purchase of consumable  '"+SPELL_PRODUCT_ID+"'...");
		// the second parameter is quantity.  its possible to purchase more than 1 if you want.
		StoreKit.storeKit.purchaseProduct(SPELL_PRODUCT_ID,1);
	}
	
	/** Example of how to purchase a product */
	public function purchaseLevelPack():void
	{
		// for this to work, you must have added the value of LEVELPACK_PRODUCT_ID in the iTunes Connect website
		log("start purchase of non-consumable '"+LEVELPACK_PRODUCT_ID+"'...");
		
		// we won't let you purchase it if its already in your inventory!
		var inventory:Object=sharedObject.data["inventory"];
		if (inventory[LEVELPACK_PRODUCT_ID]!=null)
		{
			log("You already have a level pack!");
			return;
		}
		
		StoreKit.storeKit.purchaseProduct(LEVELPACK_PRODUCT_ID);
	}
	
	/** Example of how to restore transactions */
	public function restoreTransactions():void
	{
		// apple reccommends you provide a button in your ui to restore purchases,
		// for users who mightve uninstalled then reinstalled your application, etc.
		log("requesting transaction restore...");
		StoreKit.storeKit.restoreTransactions();
	}
	
	/** Example of how to show an itunes product view */
	public function showProductView():void
	{
		if (!StoreKit.storeKit.isProductViewAvailable())
		{
			log("Product View not supported (iOS6+ required.)");
			return;
		}
		
		log("Request product view for iTunes id '343200656'...");
		StoreKit.storeKit.displayProductView("343200656");
	}
	
	//
	// Events
	//	
	
	/** Called when details about available purchases has loaded */
	private function onProductsLoaded(e:StoreKitEvent):void
	{
		log("products loaded.");
		
		for each(var product:StoreKitProduct in e.validProducts)
		{
			trace("ID: "+product.productId);
			trace("Title: "+product.title);
			trace("Description: "+product.description);
			trace("String Price: "+product.localizedPrice);
			trace("Price: "+product.price);
		}
		log("Loaded "+e.validProducts.length+" Products.");
		
		// if any of the product ids we tried to pass in were not found on the server,
		// we won't be able to by them so something is wrong.
		if (e.invalidProductIds.length>0)
		{
			log("[ERR]: these products not valid:"+e.invalidProductIds.join(","));
			return;
		}

//		showFullUI();
		log("Ready! (hosted content supported?) "+StoreKit.storeKit.isHostedContentAvailable());
	}

	/** Called when product details failed to load */
	private function onProductDetailsFailed(e:StoreKitErrorEvent):void
	{
		log("ERR loading products:"+e.text);
	}
	
	/** Called when an item is successfully purchased */
	private function onPurchaseSuccess(e:StoreKitEvent):void
	{
		log("Successful purchase of '"+e.productId+"'");

		// update our sharedobject with the state of this inventory item.
		// this is just an example to make the process clear.  you will
		// want to make your own inventory manager class to handle these
		// types of things.
		var inventory:Object=sharedObject.data["inventory"];
		switch(e.productId)
		{
			case LEVELPACK_PRODUCT_ID:
				inventory[LEVELPACK_PRODUCT_ID]="purchased";
				break;
			case SPELL_PRODUCT_ID:
				if (inventory[SPELL_PRODUCT_ID]==null)
				{
					inventory[SPELL_PRODUCT_ID]=0;
				}
				inventory[SPELL_PRODUCT_ID]++;
				break;
			default:
				// we don't do anything for unknown items.
		}
		
		// save state!
		sharedObject.flush();
		
		// update the message on screen
		updateInventoryMessage();		
	}
	
	/** A purchase has failed */
	private function onPurchaseFailed(e:StoreKitErrorEvent):void
	{
		log("FAILED purchase="+e.productId+",t="+e.transactionId+",o="+e.originalTransactionId);
	}
		
	/** A purchase was cancelled */
	private function onPurchaseUserCancelled(e:StoreKitEvent):void
	{
		log("CANCELLED purchase="+e.productId+","+e.transactionId);
	}
	
	/** All transactions have been restored */
	private function onTransactionsRestored(e:StoreKitEvent):void
	{
		log("All previous transactions restored!");
		updateInventoryMessage();
	}
	
	/** Transaction restore has failed */
	private function onTransactionRestoreFailed(e:StoreKitErrorEvent):void
	{
		log("an error occurred in restore purchases:"+e.text);		
	}
	
	// Hosted content download events
	
	/** An update to the download's progress */
	private function onDownloadUpdated(e:StoreKitEvent):void
	{
		trace("downloading item: "+e.productId);
		trace("percent complete:"+(e.downloadProgress*100)); // e.downloadProgress is a 0-1.0 scale
		trace("seconds remaining:"+e.downloadTimeRemaining);
		trace("content version:"+e.downloadVersion);
		log("DL UPDATE: "+e.productId+", "+e.transactionId+", "+e.downloadProgress+", "+e.downloadTimeRemaining+", "+e.downloadVersion);
	}
	
	/** A download has finished */
	private function onDownloadFinished(e:StoreKitEvent):void
	{
		log("DL FINISHED: "+e.productId+", "+e.transactionId+", "+e.downloadPath+", "+e.downloadVersion);
		
		trace("finished downloading:"+e.productId);
		
		// for this example, we load any downloaded .png files and put them on screen.
		var downloadDirectory:File=new File(e.downloadPath);
		if (downloadDirectory.exists)
		{
			var contents:Array=downloadDirectory.getDirectoryListing();
			for each(var file:File in contents)
			{
				if (file.extension=="png")
				{
					var context:LoaderContext=new LoaderContext(true, ApplicationDomain.currentDomain);
					var loader:Loader=new Loader();
					loader.load(new URLRequest(file.url),context);
					stage.addChild(loader);
				}
			}
		}
	}
	
	/** A download has failed */
	private function onDownloadFailed(e:StoreKitErrorEvent):void
	{
		log("DL FAILED:"+e.productId+", "+e.transactionId+", "+e.errorId+", "+e.text);
	}
	
	// Product view events
	
	/** Product view was shown to the user */
	private function onProductViewDisplayed(e:StoreKitEvent):void
	{
		log("VIEW DISPLAYED FOR: "+e.productId);
	}
	
	/** Loading of the product view's content has loaded successfully */
	private function onProductViewLoaded(e:StoreKitEvent):void
	{
		log("VIEW CONTENT LOADED FOR: "+e.productId);
	}
	
	/** The product view has been dismissed */
	private function onProductViewDismissed(e:StoreKitEvent):void
	{
		log("VIEW DISMISSED FOR: "+e.productId);
	}
	
	/** The product view's content failed to load */
	private function onProductViewFailed(e:StoreKitErrorEvent):void
	{
		log("VIEW FAILED:"+e.productId+", "+e.errorID+"="+e.text);
	}
	

	//
	// Impelementation
	//
	
	/** Update Inventory Message */
	public function updateInventoryMessage():void
	{
		var inventory:Object=sharedObject.data["inventory"];
		
//		var hasLevelpack:Boolean;
//		var numberOfSpells:int;
//		// if the value is set to something, you have it
//		if (inventory[LEVELPACK_PRODUCT_ID]!=null)
//		{
//			hasLevelpack=true;
//		}
//		else
//		{
//			hasLevelpack=false;
//		}
//		
//		// for the spells, we store an int of how many you own
//		// if there's no value there at all, we just use 0
//		if (inventory[SPELL_PRODUCT_ID]==null)
//		{
//			numberOfSpells=0;
//		}
//		else
//		{
//			numberOfSpells=inventory[SPELL_PRODUCT_ID];
//		}
		var hasUnlocked:Boolean;
		// if the value is set to something, you have it
		if (inventory[LEVELPACK_PRODUCT_ID]!=null)
		{
			hasUnlocked=true;
		}
		else
		{
			hasUnlocked=false;
		}
		
//		txtInventory.text="Has Levelpack? "+hasLevelpack+", Spells Owned: "+numberOfSpells;
//		log("Has Levelpack? "+hasLevelpack+", Spells Owned: "+numberOfSpells);
		log("Has hasUnlocked? "+hasUnlocked);
	}
	
	/** Create UI */
//	public function createUI():void
//	{
//		txtStatus=new TextField();
//		txtStatus.defaultTextFormat=new flash.text.TextFormat("Arial",15);
//		txtStatus.width=stage.stageWidth;
//		//txtStatus.height=1500;
//		txtStatus.multiline=true;
//		txtStatus.wordWrap=true;
//		txtStatus.text="Ready";
//		addChild(txtStatus);
//		
//		txtInventory=new TextField();
//		txtInventory.defaultTextFormat=new flash.text.TextFormat("Arial",25);
//		txtInventory.width=stage.stageWidth;
//		txtInventory.multiline=true;
//		txtInventory.wordWrap=true;
//		txtInventory.text="Inventory:";
//		txtInventory.y=stage.stageHeight-txtInventory.textHeight*1.1;
//		addChild(txtInventory);
//
//	}
		
	/** Hide the UI */
//	public function hideUI():void
//	{
//		if (buttonContainer)
//		{
//			removeChild(buttonContainer);
//			buttonContainer=null;
//		}
//	}
	
	/** Show full UI Options  */
//	public function showFullUI():void
//	{
//		if (buttonContainer)
//		{
//			removeChild(buttonContainer);
//			buttonContainer=null;
//		}
//		
//		buttonContainer=new Sprite();
//		buttonContainer.y=txtStatus.height;
//		addChild(buttonContainer);
//		
//		var uiRect:Rectangle=new Rectangle(0,0,stage.stageWidth,stage.stageHeight);
//		var layout:ButtonLayout=new ButtonLayout(uiRect,14);
//		layout.addButton(new SimpleButton(new Command("Buy Level Pack",purchaseLevelPack)));
//		layout.addButton(new SimpleButton(new Command("Buy spell",purchaseSpell)));
//		layout.addButton(new SimpleButton(new Command("Restore transactions", restoreTransactions)));
//		layout.addButton(new SimpleButton(new Command("Show Product View", showProductView)));
//
//		layout.attach(buttonContainer);
//		layout.layout();	
//	}
	
	
	/** Log */
	private function log(msg:String):void
	{
		trace("[StoreKitExample] "+msg);
//		txtStatus.text=msg;
	}
	
	
}
}

//
// This is generic UI code
//

import flash.display.DisplayObjectContainer;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.geom.Rectangle;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;

/** Simple Button */
class SimpleButton extends Sprite
{
	//
	// Instance Variables
	//
	
	/** Command */
	private var cmd:Command;
	
	/** Width */
	private var _width:Number;
	
	/** Label */
	private var txtLabel:TextField;
	
	//
	// Public Methods
	//
	
	/** Create New SimpleButton */
	public function SimpleButton(cmd:Command)
	{
		super();
		this.cmd=cmd;
		
		mouseChildren=false;
		mouseEnabled=buttonMode=useHandCursor=true;
		
		txtLabel=new TextField();
		txtLabel.defaultTextFormat=new TextFormat("Arial",32,0xFFFFFF);
		txtLabel.mouseEnabled=txtLabel.mouseEnabled=txtLabel.selectable=false;
		txtLabel.text=cmd.getLabel();
		txtLabel.autoSize=TextFieldAutoSize.LEFT;
		
		redraw();
		
		addEventListener(MouseEvent.CLICK,onSelect);
	}
	
	/** Set Width */
	override public function set width(val:Number):void
	{
		this._width=val;
		redraw();
	}

	
	/** Dispose */
	public function dispose():void
	{
		removeEventListener(MouseEvent.CLICK,onSelect);
	}
	
	//
	// Events
	//
	
	/** On Press */
	private function onSelect(e:MouseEvent):void
	{
		this.cmd.execute();
	}
	
	//
	// Implementation
	//
	
	/** Redraw */
	private function redraw():void
	{		
		txtLabel.text=cmd.getLabel();
		_width=_width||txtLabel.width*1.1;
		
		graphics.clear();
		graphics.beginFill(0x444444);
		graphics.lineStyle(2,0);
		graphics.drawRoundRect(0,0,_width,txtLabel.height*1.1,txtLabel.height*.4);
		graphics.endFill();
		
		txtLabel.x=_width/2-(txtLabel.width/2);
		txtLabel.y=txtLabel.height*.05;
		addChild(txtLabel);
	}
}

/** Button Layout */
class ButtonLayout
{
	private var buttons:Array;
	private var rect:Rectangle;
	private var padding:Number;
	private var parent:DisplayObjectContainer;
	
	public function ButtonLayout(rect:Rectangle,padding:Number)
	{
		this.rect=rect;
		this.padding=padding;
		this.buttons=new Array();
	}
	
	public function addButton(btn:SimpleButton):uint
	{
		return buttons.push(btn);
	}
	
	public function attach(parent:DisplayObjectContainer):void
	{
		this.parent=parent;
		for each(var btn:SimpleButton in this.buttons)
		{
			parent.addChild(btn);
		}
	}
	
	public function layout():void
	{
		var btnX:Number=rect.x+padding;
		var btnY:Number=rect.y;
		for each( var btn:SimpleButton in this.buttons)
		{
			btn.width=rect.width-(padding*2);
			btnY+=this.padding;
			btn.x=btnX;
			btn.y=btnY;
			btnY+=btn.height;
		}
	}
}

/** Inline Command */
class Command
{
	/** Callback Method */
	private var fnCallback:Function;
	
	/** Label */
	private var label:String;
	
	//
	// Public Methods
	//
	
	/** Create New Command */
	public function Command(label:String,fnCallback:Function)
	{
		this.fnCallback=fnCallback;
		this.label=label;
	}
	
	//
	// Command Implementation
	//
	
	/** Get Label */
	public function getLabel():String
	{
		return label;
	}
	
	/** Execute */
	public function execute():void
	{
		fnCallback();
	}
}