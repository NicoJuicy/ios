//
//  WaypointTVC.h
//  OwnTracks
//
//  Created by Christoph Krey on 01.10.13.
//  Copyright © 2013-2025  Christoph Krey. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Waypoint+CoreDataClass.h"

@interface WaypointTVC : UITableViewController
@property (strong, nonatomic) Waypoint *waypoint;

@end
