//
//  Settings.h
//  rk1digital
//
//  Created by Evangelos Georgiou on 12/03/2014.
//  Copyright (c) 2014 Evangelos Georgiou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Settings : NSManagedObject

@property (nonatomic, retain) NSString * ipaddress;
@property (nonatomic, retain) NSNumber * port;

@end
