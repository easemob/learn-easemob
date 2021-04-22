//
//  StreamInfo.h
//  emlearn-ios
//
//  Created by ictc on 2020/12/24.
//  Copyright © 2020 ictc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Hyphenate/Hyphenate.h>
@interface StreamInfo : NSObject
    @property (nonatomic,strong) NSString *streamId;
    @property (nonatomic,strong) NSString *userName;
    @property (nonatomic) EMStreamType type;
    
- (instancetype)init;
@end

