//
//  studentInfo.m
//  SQLiteDatabaseExample
//
//  Created by PAUL CHRISTIAN on 11/22/17.
//  Copyright © 2017 PAUL CHRISTIAN. All rights reserved.
//

#import "studentInfo.h"

@implementation studentInfo
-(id)initWithData:(NSString *)n andAddress: (NSString* )a andPhone:(NSString *)p
{
    if (self == [super init])
    {
        [self setName:n];
        [self setAddress:a];
        [self setPhone:p];
    }
    return self;
}
@end
