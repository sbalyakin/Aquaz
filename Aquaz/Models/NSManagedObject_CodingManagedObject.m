//
//  NSManagedObject_CodingManagedObject.m
//  Aquaz
//
//  Created by Admin on 10.04.15.
//  Copyright (c) 2015 Sergey Balyakin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <Aquaz-Swift.h>

@implementation NSManagedObject (NSCoding)

- (id)initWithCoder:(NSCoder *)decoder {
  NSManagedObjectContext *context = CoreDataProvider.sharedInstance.managedObjectContext;
  NSPersistentStoreCoordinator *coordinator = CoreDataProvider.sharedInstance.persistentStoreCoordinator;
  NSURL *url = (NSURL *)[decoder decodeObjectForKey:@"URIRepresentation"];
  NSManagedObjectID *managedObjectID = [coordinator managedObjectIDForURIRepresentation:url];
  self = [context existingObjectWithID:managedObjectID error:nil];
  return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
  [encoder encodeObject:[[self objectID] URIRepresentation] forKey:@"URIRepresentation"];
}

@end
