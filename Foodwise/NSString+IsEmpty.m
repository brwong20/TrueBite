//
//  NSString+IsEmpty.m
//  Joyspace
//
//  Created by Amir Hizkiya on 3/31/16.
//  Copyright © 2016 Joyspace Inc. All rights reserved.
//

#import "NSString+IsEmpty.h"

@implementation NSString (IsEmpty)

+ (BOOL)isEmpty:(NSString*)str
{
    BOOL isEmptyString = FALSE;
    
    if((str == nil) || ([[str stringByReplacingOccurrencesOfString:@" " withString:@""] length] == 0))
    {
        isEmptyString = TRUE;
    }
    
    return isEmptyString;
}

@end
