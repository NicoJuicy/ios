//
//  PhotoAnnotationV.h
//  OwnTracks
//
//  Created by Christoph Krey on 04.12.24.
//  Copyright © 2024-2026 OwnTracks. All rights reserved.
//

#import <MapKit/MapKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PhotoAnnotationV : MKAnnotationView
@property (strong, nonatomic) UIImage *poiImage;
@end

NS_ASSUME_NONNULL_END
