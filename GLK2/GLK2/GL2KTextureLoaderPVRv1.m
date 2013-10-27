/**
 Cleaned up compared to Apple's version, with much better error-handling,
 including preventing some hard-crashes in Apple's sample code
 */
#import "GL2KTextureLoaderPVRv1.h"

#define PVR_TEXTURE_FLAG_TYPE_MASK  0xff

static char gPVRTexIdentifier[4] = "PVR!";

enum
{
	kPVRTextureFlagTypePVRTC_2 = 24,
	kPVRTextureFlagTypePVRTC_4
	
};

typedef struct _PVRTexHeader
{
	uint32_t headerLength;
	uint32_t height;
	uint32_t width;
	uint32_t numMipmaps;
	uint32_t flags;
	uint32_t dataLength;
	uint32_t bpp;
	uint32_t bitmaskRed;
	uint32_t bitmaskGreen;
	uint32_t bitmaskBlue;
	uint32_t bitmaskAlpha;
	uint32_t pvrTag;
	uint32_t numSurfs;
	
} PVRTexHeader;

@interface PVRTextureV1 ()
#pragma mark - redeclare everything readwrite
@property(nonatomic,retain,readwrite) NSMutableArray *imageData;

@property(nonatomic,readwrite) uint32_t width, height;

@property(nonatomic,readwrite) GLenum internalFormat;
@property(nonatomic,readwrite) BOOL hasAlpha;

/** filename/path if it was from disk, or URL string if from URL */
@property(nonatomic,retain,readwrite) NSString* textureSourceFileInfo;
@end

@implementation PVRTextureV1


- (id)init
{
	if (self = [super init])
	{
		self.imageData = [[[NSMutableArray alloc] initWithCapacity:10] autorelease];
		
		self.width = self.height = 0;
		self.internalFormat = GL_COMPRESSED_RGBA_PVRTC_4BPPV1_IMG;
		self.hasAlpha = FALSE;
	}
	
	return self;	
}

- (void)dealloc
{
	self.imageData = nil;
	
	[super dealloc];
}

@end

@implementation GL2KTextureLoaderPVRv1

+ (BOOL)unpackPVRData:(NSData *)data intoPVRTexture:(PVRTextureV1*) pvrTexture
{
	BOOL success = FALSE;
	PVRTexHeader *header = NULL;
	uint32_t flags, pvrTag;
	uint32_t dataLength = 0, dataOffset = 0, dataSize = 0;
	uint32_t blockSize = 0, widthBlocks = 0, heightBlocks = 0;
	uint32_t width = 0, height = 0, bpp = 4;
	uint8_t *bytes = NULL;
	uint32_t formatFlags;
	
	header = (PVRTexHeader *)[data bytes];
	
	pvrTag = CFSwapInt32LittleToHost(header->pvrTag);
	
	
	if (gPVRTexIdentifier[0] != ((pvrTag >>  0) & 0xff) ||
		gPVRTexIdentifier[1] != ((pvrTag >>  8) & 0xff) ||
		gPVRTexIdentifier[2] != ((pvrTag >> 16) & 0xff) ||
		gPVRTexIdentifier[3] != ((pvrTag >> 24) & 0xff))
	{
		return FALSE;
	}
	
	flags = CFSwapInt32LittleToHost(header->flags);
	formatFlags = flags & PVR_TEXTURE_FLAG_TYPE_MASK;
	
	if (formatFlags == kPVRTextureFlagTypePVRTC_4 || formatFlags == kPVRTextureFlagTypePVRTC_2)
	{
		[pvrTexture.imageData removeAllObjects];
		
		/**
		 Fix for Apple's bug:
		 
		 - PVR MipMaps usually contain hi-res images that will crash the loader because they are too large for the chipset you're running
		 - we are REQUIRED (by the chip manufacturer) to manually "ignore" those hi-res images when loading a mipmap, and NOT upload them to the chip
		 */
		GLint maximumTextureSize;
		glGetIntegerv( GL_MAX_TEXTURE_SIZE, &maximumTextureSize );
		
		if (formatFlags == kPVRTextureFlagTypePVRTC_4)
			pvrTexture.internalFormat = GL_COMPRESSED_RGBA_PVRTC_4BPPV1_IMG;
		else if (formatFlags == kPVRTextureFlagTypePVRTC_2)
			pvrTexture.internalFormat = GL_COMPRESSED_RGBA_PVRTC_2BPPV1_IMG;
		
		
		pvrTexture.width = width = CFSwapInt32LittleToHost(header->width);
		pvrTexture.height = height = CFSwapInt32LittleToHost(header->height);
		
		if (CFSwapInt32LittleToHost(header->bitmaskAlpha))
			pvrTexture.hasAlpha = TRUE;
		else
			pvrTexture.hasAlpha = FALSE;
		
		dataLength = CFSwapInt32LittleToHost(header->dataLength);
		
		bytes = ((uint8_t *)[data bytes]) + sizeof(PVRTexHeader);
		
		// Calculate the data size for each texture level and respect the minimum number of blocks
		while (dataOffset < dataLength)
		{
			if (formatFlags == kPVRTextureFlagTypePVRTC_4)
			{
				blockSize = 4 * 4; // Pixel by pixel block size for 4bpp
				widthBlocks = width / 4;
				heightBlocks = height / 4;
				bpp = 4;
			}
			else
			{
				blockSize = 8 * 4; // Pixel by pixel block size for 2bpp
				widthBlocks = width / 8;
				heightBlocks = height / 4;
				bpp = 2;
			}
			
			// Clamp to minimum number of blocks
			if (widthBlocks < 2)
				widthBlocks = 2;
			if (heightBlocks < 2)
				heightBlocks = 2;
			
			
			dataSize = widthBlocks * heightBlocks * ((blockSize  * bpp) / 8);
			
			BOOL didRejectThisWidthHeight = FALSE;
			if( width <= maximumTextureSize )
			{
				[pvrTexture.imageData addObject:[NSData dataWithBytes:bytes+dataOffset length:dataSize]];
			}
			else
			{
				didRejectThisWidthHeight = TRUE;
				
				NSLog(@"[%@] WARNING: skipped mipmap level that was too large for this hardware (%i x %i pixels). Texture: %@", [self class], width, height, pvrTexture.textureSourceFileInfo );
			}

			
			dataOffset += dataSize;
			
			width = MAX(width >> 1, 1);
			height = MAX(height >> 1, 1);
			
			if( didRejectThisWidthHeight )
			{
				/** REQUIRED: scale down the class-wide width + height so that they start at this point */
				pvrTexture.width = width;
				pvrTexture.height = height;
			}
		}
		
		
		success = TRUE;
	}
	
	return success;
	
}


+ (BOOL) uploadTextureToGPU:(PVRTextureV1*) cpuTexture
{
	int widthOfCurrentMipLevel = cpuTexture.width;
	int heightOfCurrentMipLevel = cpuTexture.height;
	NSData *data;
	GLenum err;
	
	err = glGetError();
	if (err != GL_NO_ERROR)
	{
		NSLog(@"Error before starting texture upload: glError: 0x%04X", err);
	}
	
	if ([cpuTexture.imageData count] > 1)
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
	else
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	
	/**
	 Fix for Apple's broken code:
	 
	 - PVR MipMaps usually contain hi-res images that will crash the loader because they are too large for the chipset you're running
	 - we are REQUIRED (by the chip manufacturer) to manually "ignore" those hi-res images when loading a mipmap, and NOT upload them to the chip
	 */
	GLint maximumTextureSize;
	glGetIntegerv( GL_MAX_TEXTURE_SIZE, &maximumTextureSize );
	if( maximumMipMapSize > 0 ) // 0 is "ignore", any other value is "artificial max value of maximumTextureSize"
		maximumTextureSize = MIN( maximumTextureSize, maximumMipMapSize );
	
	int indexOfUploadedTextureSkippingIllegalSizes = 0;
	
	for (int i=0; i < [cpuTexture.imageData count]; i++)
	{
		if( widthOfCurrentMipLevel <= maximumTextureSize )
		{
			data = [cpuTexture.imageData objectAtIndex:i];
			glCompressedTexImage2D(GL_TEXTURE_2D, indexOfUploadedTextureSkippingIllegalSizes, cpuTexture.internalFormat, widthOfCurrentMipLevel, heightOfCurrentMipLevel, 0, [data length], [data bytes]);
			
			err = glGetError();
			if (err != GL_NO_ERROR)
			{
				NSLog(@"Error uploading compressed texture level: %d (index of actually uploaded textures: %d). glError: 0x%04X", i, indexOfUploadedTextureSkippingIllegalSizes, err);
				return FALSE;
			}
			
			indexOfUploadedTextureSkippingIllegalSizes ++;
		}
		else
		{
			NSLog(@"[%@] WARNING: skipped mipmap level that was too large for this hardware (%i x %i pixels). Texture: %@", [self class], widthOfCurrentMipLevel, heightOfCurrentMipLevel, cpuTexture.textureSourceFileInfo );
		}
		
		widthOfCurrentMipLevel = MAX(widthOfCurrentMipLevel >> 1, 1);
		heightOfCurrentMipLevel = MAX(heightOfCurrentMipLevel >> 1, 1);
	}
	
	[cpuTexture.imageData removeAllObjects];
	
	return TRUE;
	
}

+ (PVRTextureV1*)pvrTextureWithContentsOfFile:(NSString *)path
{
	NSData *data = [NSData dataWithContentsOfFile:path];
	if (!data )
	{
		NSLog(@"Failed to load PVR, no data at path = %@", path);
		return nil;
	}
	
	PVRTextureV1* newTexture = [[PVRTextureV1 alloc] init];
	newTexture.textureSourceFileInfo = path;
	
	BOOL parsedPVRFileOK = [GL2KTextureLoaderPVRv1 unpackPVRData:data intoPVRTexture:newTexture];
	if ( ! parsedPVRFileOK )
	{
		NSLog(@"Failed to load PVR, file at path wasn't a VERSION1 .pvr file = %@", path);
		[newTexture release]; // don't wait for the autorelease
		return nil;
	}
	
	BOOL uploadedToGPUOK = [GL2KTextureLoaderPVRv1 uploadTextureToGPU:newTexture];
	if( !uploadedToGPUOK )
	{
		[newTexture release]; // don't wait for the autorelease
		return nil;
	}
		
	[newTexture autorelease]; // now we know it's keepable
	return newTexture;
}


+ (PVRTextureV1*)pvrTextureWithContentsOfURL:(NSURL *)url
{
	if (![url isFileURL])
		return nil;
	
	return [GL2KTextureLoaderPVRv1 pvrTextureWithContentsOfFile:[url path]];
	
}

static GLint maximumMipMapSize = 0;
+(void)setMaximumTextureSizeToLoadInMipMaps:(GLint) newMax
{
	maximumMipMapSize = newMax;
}

@end