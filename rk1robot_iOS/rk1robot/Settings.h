//
//  Settings.h
//  rk1robot
//
//  Created by Evangelos Georgiou on 15/03/2014.
//  Copyright (c) 2014 Evangelos Georgiou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Settings : NSManagedObject

@property (nonatomic, retain) NSString * ipaddress;
@property (nonatomic, retain) NSNumber * port;
@property (nonatomic, retain) NSNumber * leftmotorstate;
@property (nonatomic, retain) NSNumber * rightmotorstate;
@property (nonatomic, retain) NSNumber * direction;

@end
