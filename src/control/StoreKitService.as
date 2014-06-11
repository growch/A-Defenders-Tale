package control 
{
import com.milkmangames.nativeextensions.ios.StoreKit;
import com.milkmangames.nativeextensions.ios.StoreKitProduct;
import com.milkmangames.nativeextensions.ios.events.StoreKitErrorEvent;
import com.milkmangames.nativeextensions.ios.events.StoreKitEvent;

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

import events.ViewEvent;

import model.DataModel;

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
		
	/** Product IDs, must match iTunes Connect Items */
//	private static const UNLOCK_ID:String="com.2ndstringproductions.ADefendersTale.UnlockCompleteBook";
//	DISCOUNTED PRICE $1.99
	private static const UNLOCK_ID:String="com.2ndstringproductions.ADefendersTale.UnlockCompleteBookLimitedTimeOffer";
	
	public var supported:Boolean = false;

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
		
		log("initializing StoreKit..");	
		
		if (!StoreKit.isSupported())
		{
			log("Store Kit iOS purchases is not supported on this platform.");
			return;
		} else {
			supported = true;
		}

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
	
	public function purchaseUnlock():void
	{
		// for this to work, you must have added the value of LEVELPACK_PRODUCT_ID in the iTunes Connect website
		log("start purchase of non-consumable '"+UNLOCK_ID+"'...");
		
		// we won't let you purchase it if its already in your inventory!
		var inventory:Object=sharedObject.data["inventory"];
		if (inventory[UNLOCK_ID]!=null)
		{
			log("You already have unlocked the app!");
			return;
		}
		
		StoreKit.storeKit.purchaseProduct(UNLOCK_ID);
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
			case UNLOCK_ID:
				inventory[UNLOCK_ID]="purchased";
				break;
			default:
				// we don't do anything for unknown items.
		}
		
		// save state!
		sharedObject.flush();
		
		// update the message on screen
		updateInventoryMessage();		
		
		EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.UNLOCK_PURCHASED));
		
		DataModel.getInstance().trackEvent("application", "unlocked at: "+ DataModel.CURRENT_PAGE_ID);
	}
	
	/** A purchase has failed */
	private function onPurchaseFailed(e:StoreKitErrorEvent):void
	{
		log("FAILED purchase="+e.productId+",t="+e.transactionId+",o="+e.originalTransactionId);
		
		EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.UNLOCK_NOT));
		
		DataModel.getInstance().trackEvent("application", "unlock FAILED! at: "+ DataModel.CURRENT_PAGE_ID);
	}
		
	/** A purchase was cancelled */
	private function onPurchaseUserCancelled(e:StoreKitEvent):void
	{
		log("CANCELLED purchase="+e.productId+","+e.transactionId);
		
//		EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.UNLOCK_NOT));
		
		DataModel.getInstance().trackEvent("application", "unlock CANCELLED! at: "+ DataModel.CURRENT_PAGE_ID);
	}
	
	/** All transactions have been restored */
	private function onTransactionsRestored(e:StoreKitEvent):void
	{
		log("All previous transactions restored!");
		updateInventoryMessage();
		
		EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.UNLOCK_PURCHASED));
		
		DataModel.getInstance().trackEvent("application", "restored at: "+ DataModel.CURRENT_PAGE_ID);
	}
	
	/** Transaction restore has failed */
	private function onTransactionRestoreFailed(e:StoreKitErrorEvent):void
	{
		log("an error occurred in restore purchases:"+e.text);		
		
		EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.UNLOCK_NOT));
		
		DataModel.getInstance().trackEvent("application", "restore FAILED! at: "+ DataModel.CURRENT_PAGE_ID);
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
		
		// if the value is set to something, you have it
		var hasUnlocked:Boolean;
		// if the value is set to something, you have it
		if (inventory[UNLOCK_ID]!=null)
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
	
	/** Log */
	private function log(msg:String):void
	{
		trace("[StoreKitExample] "+msg);
//		txtStatus.text=msg;
	}
	
	
}
}
