//
//  NSManagedObject_CodingManagedObject.h
//  Aquaz
//
//  Created by Admin on 10.04.15.
//  Copyright (c) 2015 Sergey Balyakin. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObject (NSCoding)

- (id)initWithCoder:(NSCoder *)decoder;

- (void)encodeWithCoder:(NSCoder *)encoder;

@end
