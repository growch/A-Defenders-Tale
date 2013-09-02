﻿package model {	import flash.system.System;
	/**	 * @author Mark Grochowski	 */	public class ApplicationInfo 	{		public var dictionary : DictionaryInfo;		private var _xmlInfo:XML;		public function ApplicationInfo() : void		{		}				public function getPageInfo(thisPage:String):PageInfo {			var res :PageInfo = parseXMLForPage(_xmlInfo[thisPage]);			return res;		}				public static function parseInfo( xml : XML ) : ApplicationInfo		{//			trace("parseInfo" + xml);			if( !xml ) return null;						var res : ApplicationInfo = new ApplicationInfo( );			res.dictionary = parseXmlForDictionary( xml["dictionary"] );			res._xmlInfo = xml;						return res;			//			IMPORTANT!!??!!			System.disposeXML(xml);		}		private static function parseXmlForDictionary( xml : XMLList ) : DictionaryInfo		{			var dictionary:DictionaryInfo = new DictionaryInfo();						dictionary.pronoun1 = new Array();			dictionary.pronoun1[0] = xml["pronoun1"].@male;			dictionary.pronoun1[1] = xml["pronoun1"].@female;			dictionary.pronoun1[2] = xml["pronoun1"].@undecided;						dictionary.pronoun2 = new Array();			dictionary.pronoun2[0] = xml["pronoun2"].@male;			dictionary.pronoun2[1] = xml["pronoun2"].@female;			dictionary.pronoun2[2] = xml["pronoun2"].@undecided;						dictionary.pronoun3 = new Array();			dictionary.pronoun3[0] = xml["pronoun3"].@male;			dictionary.pronoun3[1] = xml["pronoun3"].@female;			dictionary.pronoun3[2] = xml["pronoun3"].@undecided;						dictionary.pronoun4 = new Array();			dictionary.pronoun4[0] = xml["pronoun4"].@male;			dictionary.pronoun4[1] = xml["pronoun4"].@female;			dictionary.pronoun4[2] = xml["pronoun4"].@undecided;						return dictionary;		}						private static function parseXMLForPage( xml : XMLList ) : PageInfo		{			var page : PageInfo = new PageInfo();						page.id = xml.@id;						page.contentPanelInfo = new ContentPanelInfo();			page.contentPanelInfo.image = xml["contents"].@image;			page.contentPanelInfo.title = xml["contents"]["title"];						page.body = new Vector.<StoryPart>();			parseBody(xml, page);						page.decisions = new Vector.<DecisionInfo>();			parseDecisions(xml, page);						var node:XML;			var tempArray:Array;						if (xml["alms"].length() > 0) {				page.alms = new Array();				for each (node in xml["alms"].children()) {					page.alms.push(node); 				}			}						if (xml["instrument1"].length() > 0) {				page.instrument1 = new Array();				for each (node in xml["instrument1"].children()) {					page.instrument1.push(node); 				}			}						if (xml["instrument2"].length() > 0) {				page.instrument2 = new Array();				for each (node in xml["instrument2"].children()) {					page.instrument2.push(node); 				}			}						if (xml["wardrobe1"].length() > 0) {				page.wardrobe1 = new Array();				for each (node in xml["wardrobe1"].children()) {//					page.wardrobe1.push(node); 					// if there is a sub array of options					if (node.children().length() > 0) {						tempArray = new Array();						for each (node in node.children()) {							tempArray.push(node); 						}						page.wardrobe1.push(tempArray);					} else { //default						page.wardrobe1.push(node); 					}				}			}						if (xml["wardrobe2"].length() > 0) {				page.wardrobe2 = new Array();				for each (node in xml["wardrobe2"].children()) {					page.wardrobe2.push(node); 				}			}						if (xml["weapon1"].length() > 0) {				page.weapon1 = new Array();				for each (node in xml["weapon1"].children()) {//					page.weapon1.push(node); 					// if there is a sub array of companion options					if (node["stones"].length() > 0) {						tempArray = new Array();						for each (node in node["stones"].children()) {							tempArray.push(node);						}						page.weapon1.push(tempArray);					} else { //default						page.weapon1.push(node); 					}				}			}						if (xml["weapon2"].length() > 0) {				page.weapon2 = new Array();				for each (node in xml["weapon2"].children()) {					page.weapon2.push(node); 				}			}						if (xml["weapon3"].length() > 0) {				page.weapon3 = new Array();				for each (node in xml["weapon3"].children()) {					page.weapon3.push(node); 				}			}						if (xml["weapon4"].length() > 0) {				page.weapon4 = new Array();				for each (node in xml["weapon4"].children()) {					page.weapon4.push(node); 				}			}						if (xml["supplies"].length() > 0) {				page.supplies = new Array();				for each (node in xml["supplies"].children()) {//					page.supplies.push(node); 					// if there is a sub array of options					if (node["weapons"].length() > 0) {						tempArray  = new Array();						for each (node in node["weapons"].children()) {							tempArray.push(node); 						}						page.supplies.push(tempArray);//						trace("supplies has weapons tempArray:"+tempArray);					} else { //default						page.supplies.push(node); 					}				}			}						if (xml["companion1"].length() > 0) {				page.companion1 = new Array();				for each (node in xml["companion1"].children()) {//					page.companion1.push(node); 					// if there is a sub array of companion options					if (node["stones"].length() > 0) {						tempArray = new Array();						for each (node in node["stones"].children()) {							tempArray.push(node);						}						page.companion1.push(tempArray);					} else { //default						page.companion1.push(node); 					}				}			}						if (xml["companion2"].length() > 0) {				page.companion2 = new Array();				for each (node in xml["companion2"].children()) {					page.companion2.push(node); 				}			}						if (xml["companion3"].length() > 0) {				page.companion3 = new Array();				for each (node in xml["companion3"].children()) {					page.companion3.push(node); 				}			}						if (xml["companion4"].length() > 0) {				page.companion4 = new Array();				for each (node in xml["companion4"].children()) {					page.companion4.push(node); 				}			}						if (xml["islands1"].length() > 0) {				page.islands1 = new Array();				for each (node in xml["islands1"].children()) {					page.islands1.push(node); 				}			}						if (xml["islands2"].length() > 0) {				page.islands2 = new Array();				for each (node in xml["islands2"].children()) {					page.islands2.push(node); 				}			}						if (xml["coins"].length() > 0) {				page.coins = new Array();				for each (node in xml["coins"].children()) {					page.coins.push(node); 				}			}						if (xml["captainBattled"].length() > 0) {				page.captainBattled = new Array();				for each (node in xml["captainBattled"].children()) {					page.captainBattled.push(node); 				}			}						if (xml["companionComing1"].length() > 0) {				page.companionComing1 = new Array();				for each (node in xml["companionComing1"].children()) {					// if there is a sub array of companion options					if (node["companion"].length() > 0) {						tempArray = new Array();						for each (node in node["companion"].children()) {							tempArray.push(node); 						}						page.companionComing1.push(tempArray);					} else { //default						page.companionComing1.push(node); 					}				}			}						if (xml["companionComing2"].length() > 0) {				page.companionComing2 = new Array();				for each (node in xml["companionComing2"].children()) {					page.companionComing2.push(node); 				}			}						if (xml["companionComing3"].length() > 0) {				page.companionComing3 = new Array();				for each (node in xml["companionComing3"].children()) {					page.companionComing3.push(node); 				}			}						if (xml["companionComing4"].length() > 0) {				page.companionComing4 = new Array();				for each (node in xml["companionComing4"].children()) {					page.companionComing4.push(node); 				}			}						if (xml["companionComing5"].length() > 0) {				page.companionComing5 = new Array();				for each (node in xml["companionComing5"].children()) {					page.companionComing5.push(node); 				}			}						if (xml["gender1"].length() > 0) {				page.gender1 = new Array();				for each (node in xml["gender1"].children()) {					page.gender1.push(node); 				}			}						if (xml["hair1"].length() > 0) {				page.hair1 = new Array();				for each (node in xml["hair1"].children()) {					page.hair1.push(node); 				}			}						if (xml["intro1"].length() > 0) {				page.intro1 = new Array();				for each (node in xml["intro1"].children()) {					page.intro1.push(node); 				}			}						if (xml["intro2"].length() > 0) {				page.intro2 = new Array();				for each (node in xml["intro2"].children()) {					page.intro2.push(node); 				}			}						if (xml["stones1"].length() > 0) {				page.stones1 = new Array();				for each (node in xml["stones1"].children()) {					// if there is a sub array of options					if (node.children().length() > 0) {						tempArray = new Array();						for each (node in node.children()) {							tempArray.push(node); 						}						page.stones1.push(tempArray);					} else { //default						page.stones1.push(node); 					}				}			}						if (xml["pearlObtained"].length() > 0) {				page.pearlObtained = new Array();				for each (node in xml["pearlObtained"].children()) {					page.pearlObtained.push(node); 				}			}						return page;		}				private static function parseBody(thisXMLList:XMLList, thisInfo:*) : void {			for each (var item:XML in thisXMLList["body"].children()) {				var part:StoryPart = new StoryPart();				part.type = item.@type;				part.id = item.@id;				part.width = item.@width;				part.height = item.@height;				part.size = item.@size;				part.alignment = item.@align;				part.top = item.@top;				part.left = item.@left;				part.leading = item.@leading;				part.file = item.@file;				part.copyText = item;				thisInfo.body.push(part);			}		}				private static function parseDecisions(thisXMLList:XMLList, thisInfo:*) : void {			for each (var decision:XML in thisXMLList["decisions"].children()) {				var decInfo:DecisionInfo = new DecisionInfo();				decInfo.id = decision.@id;				decInfo.description = decision;				thisInfo.decisions.push(decInfo);			}			thisInfo.decisionsMarginTop = Number(thisXMLList["decisions"].@top);		}			}}