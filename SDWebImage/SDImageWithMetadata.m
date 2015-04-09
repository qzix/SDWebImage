/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "SDImageWithMetadata.h"
#import "UIImage+MultiFormat.h"
#import "SDWebImageDecoder.h"

// PNG signature bytes and data (below)
static unsigned char kPNGSignatureBytes[8] = {0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A};
static NSData *kPNGSignatureData = nil;

BOOL ImageDataHasPNGPreffix(NSData *data);

BOOL ImageDataHasPNGPreffix(NSData *data) {
    NSUInteger pngSignatureLength = [kPNGSignatureData length];
    if ([data length] >= pngSignatureLength) {
        if ([[data subdataWithRange:NSMakeRange(0, pngSignatureLength)] isEqualToData:kPNGSignatureData]) {
            return YES;
        }
    }
    
    return NO;
}


static NSString *const kImageDataKey = @"ImageData";
static NSString *const kHeadersKey = @"Headers";

@implementation SDImageWithMetadata

+ (void)initialize
{
    // initialise PNG signature data
    kPNGSignatureData = [NSData dataWithBytes:kPNGSignatureBytes length:8];

}

- (instancetype)initWithImage:(UIImage *)image metadata:(NSDictionary *)metadata
{
    self = [super init];
    if (self)
    {
        _image = image;
        _metadata = [metadata copy];
    }
    
    return self;
}

- (NSData *)serializeWithImageData:(NSData *)imageData shouldRecalculate:(BOOL)recalculate
{
    if (_image && (recalculate || !imageData)) {
#if TARGET_OS_IPHONE
        // We need to determine if the image is a PNG or a JPEG
        // PNGs are easier to detect because they have a unique signature (http://www.w3.org/TR/PNG-Structure.html)
        // The first eight bytes of a PNG file always contain the following (decimal) values:
        // 137 80 78 71 13 10 26 10
        
        // We assume the image is PNG, in case the imageData is nil (i.e. if trying to save a UIImage directly),
        // we will consider it PNG to avoid loosing the transparency
        BOOL imageIsPng = YES;
        
        // But if we have an image data, we will look at the preffix
        if ([imageData length] >= [kPNGSignatureData length]) {
            imageIsPng = ImageDataHasPNGPreffix(imageData);
        }
        
        if (imageIsPng) {
            imageData = UIImagePNGRepresentation(_image);
        }
        else {
            imageData = UIImageJPEGRepresentation(_image, (CGFloat)1.0);
        }
#else
        imageData = [NSBitmapImageRep representationOfImageRepsInArray:image.representations usingType: NSJPEGFileType properties:nil];
#endif
    }

    if (!imageData)
    {
        return nil;
    }
    
    NSMutableData *result = [NSMutableData data];
    
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:result];
    [archiver encodeObject:imageData forKey:kImageDataKey];
    [archiver encodeObject:_metadata forKey:kHeadersKey];
    [archiver finishEncoding];
    
    return result;
}

+ (instancetype)deserializeFromData:(NSData *)data shouldDecompress:(BOOL)decompress key:(NSString *)key
{
    if (data.length == 0)
    {
        return nil;
    }
    
    NSDictionary *headers = nil;
    UIImage *image = nil;
    
    @try {
        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
        
        NSData *imageData = [unarchiver decodeObjectForKey:kImageDataKey];
        image = [UIImage sd_imageWithData:imageData];
        headers = [unarchiver decodeObjectForKey:kHeadersKey];
    }
    @catch (NSException *exception) {
        image = [UIImage sd_imageWithData:data];
    }
    
    image = SDScaledImageForKey(key, image);
    if (decompress) {
        image = [UIImage decodedImageWithImage:image];
    }
    
    return [[self alloc] initWithImage:image metadata:headers];
}

@end
