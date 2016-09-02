//
//  FoodwiseDefines.h
//  Foodwise
//
//  Created by Brian Wong on 8/19/16.
//  Copyright © 2016 Brian Wong. All rights reserved.
//

#ifndef FoodwiseDefines_h
#define FoodwiseDefines_h

//API Keys
#define GOOGLE_MAPS_API_KEY @"AIzaSyB1DP9fXSZCelHSstNYQ7oh8ret5H-6Yes"
#define GOOGLE_PLACES_API_KEY @"AIzaSyCfFumzDItnrLplAuPCaobEWtzS8W2mUvg"
#define GOOGLE_PLACES_WEB_API_KEY @"AIzaSyAjGG-5E-NAxpNP6n2MdhwvV1vCuivKLgY"

#define FOURSQUARE_SEARCH_BASE_URL @"https://api.foursquare.com/v2/venues/search"
#define FOURSQUARE_EXPLORE_BASE_URL @"https://api.foursquare.com/v2/venues/explore"
#define FOURSQUARE_VENUE_DETAILS_BASE_URL @"https://api.foursquare.com/v2/venues"
#define FOURSQUARE_AUTOCOMPLETE_API @"https://api.foursquare.com/v2/venues/suggestcompletion"
#define FOURSQUARE_API_KEY @"V2K0BSBPNB2VLLTG33NSYRJGJ3ANDGBJQSH2ZNRVEJZ1AW5S"
#define FOURSQUARE_API_SECRET @"N321F5ZABWPKKUSCZ00K1ZXHXD1UMVJX3BZQ4EDYKORQ2O5Y"

//Restaurant Dictionary Keys
#define RESTAURANT_NAME_KEY         @"[@"venue"][@"name"]"
#define RESTAURANT_LATITUDE_KEY     @"[@"venue"][@"location"][@"lat"]"
#define RESTAURANT_LONGITUDE_KEY    @"[@"venue"][@"location"][@"lng"]"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define APPLICATION_FRAME   [UIScreen mainScreen].bounds

#define APPLICATION_FONT_COLOR   UIColorFromRGB(0x274B64)
#define APPLICATION_BLUE_COLOR   UIColorFromRGB(0x17A1FF)
#define APPLICATION_GREEN_COLOR  UIColorFromRGB(0x7AD313)

#endif /* FoodwiseDefines_h */
