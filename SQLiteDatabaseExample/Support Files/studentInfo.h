//
//  studentInfo.h
//  SQLiteDatabaseExample
//
//  Created by PAUL CHRISTIAN on 11/22/17.
//  Copyright © 2017 PAUL CHRISTIAN. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface studentInfo : NSObject
@property (nonatomic, strong)NSString *name;
@property (nonatomic, strong)NSString *address;
@property (nonatomic, strong)NSString *phone;
-(id)initWithData:(NSString *)n andAddress: (NSString* )a andPhone:(NSString *)p;
@end
