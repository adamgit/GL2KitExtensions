#import "GLK2Texture+CoreGraphics.h"

@implementation GLK2Texture (CoreGraphics)

+(CGContextRef) createCGContextForOpenGLTextureRGBAWidth:(int) width h:(int) height bitsPerPixel:(int) bpp shouldFlipY:(BOOL) flipY fillColorOrNil:(UIColor*) fillColor
{
	NSAssert( (width & (width - 1)) == 0, @"PowerVR will render your texture as ALL BLACK because you provided a width that's not power-of-two");
	NSAssert( (height & (height - 1)) == 0, @"PowerVR will render your texture as ALL BLACK because you provided a height that's not power-of-two");
	
	/** Create a texture to render from */
	/*************** 1. Convert to NSData */
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGContextRef context = CGBitmapContextCreate( NULL/*malloc( self.size.width * self.size.height * 4 )*/, width, height, 8, 4 * width, colorSpace, /** NB: very bad API coding from Apple - incompatible types EXPECTED here accoriding to API docs! */ (CGBitmapInfo) kCGImageAlphaPremultipliedLast  );
	CGColorSpaceRelease( colorSpace );
	//DEBUG:
	//CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
	
	if( fillColor != nil )
	{
		CGContextSetFillColorWithColor(context, fillColor.CGColor);
		CGContextFillRect(context, CGRectMake(0,0,width,height));
	}
	
	if( flipY )
	{
		CGAffineTransform flipVertical = CGAffineTransformMake(
															   1, 0, 0, -1, 0, height
															   );
		CGContextConcatCTM(context, flipVertical);
	}
	
	return context;
}

+(GLK2Texture*) uploadTextureRGBAToOpenGLFromCGContext:(CGContextRef) context width:(int)w height:(int)h
{
	void* resultAsVoidStar = CGBitmapContextGetData(context);
	
	size_t dataSize = 4 * w * h; // RGBA = 4 * 8-bit components == 4 * 1 bytes
	NSData* result = [NSData dataWithBytes:resultAsVoidStar length:dataSize];
	
	//DEBUG: NSLog(@"texture raw data = %@", result );
	
	CGContextRelease(context);
	
	/*************** 2. Upload NSData to OpenGL */
	GLK2Texture* newTextureReference = [[[GLK2Texture alloc] init] autorelease];
	
	glBindTexture( GL_TEXTURE_2D, newTextureReference.glName);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, (int)w, (int)h, 0, GL_RGBA, GL_UNSIGNED_BYTE, [result bytes]);
	
	return newTextureReference;
}

@end
