/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "SDWebImageCompat.h"

@interface SDImageWithMetadata : NSObject

@property (nonatomic, readonly) UIImage *image;
@property (nonatomic, readonly) NSDictionary *metadata;

- (instancetype)initWithImage:(UIImage *)image
                     metadata:(NSDictionary *)metadata;

/**
 *  Serialize image using NSKeyedArchiver
 */
- (NSData *)serializeWithImageData:(NSData *)data
                 shouldRecalculate:(BOOL)recalculate;
/**
 *  Deserialize data using NSKeyedUnarchiver
*  @a
 */
+ (instancetype)deserializeFromData:(NSData *)data
                   shouldDecompress:(BOOL)decompress
                                key:(NSString *)key;
@end
