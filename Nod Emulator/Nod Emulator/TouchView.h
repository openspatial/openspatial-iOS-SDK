//
//  TouchView.h
//  Nod Emulator
//
//  Copyright (c) 2014 Nod Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TouchViewDelegate <NSObject>

-(void) sendCoordinates:(int) x y:(int) y;

@end

@interface TouchView : UIView

@property id<TouchViewDelegate> delegate;

@end
