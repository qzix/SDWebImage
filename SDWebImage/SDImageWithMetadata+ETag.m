/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "SDImageWithMetadata+ETag.h"

static NSString *const kETagKey = @"ETag";
static NSString *const kIfNoneMatch = @"If-None-Match";

@implementation SDImageWithMetadata (ETag)

- (NSString *)etag {
    NSString *etag = self.metadata[kETagKey];
    if (!etag) {
        for (NSString *key in self.metadata.keyEnumerator) {
            if ([key caseInsensitiveCompare:kETagKey] == NSOrderedSame) {
                etag = self.metadata[key];
                break;
            }
        }
    }
    
    return etag;
}

- (NSDictionary *)ETagData
{
    NSString *etag = [self etag];
    if (etag) {
        return @{kIfNoneMatch : etag};
    } else {
        return nil;
    }
}

@end
