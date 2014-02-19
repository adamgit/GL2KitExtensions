#import "GLK2UniformMap.h"

#import "GLK2Uniform.h"

@interface GLK2UniformMap ()
@property(nonatomic,retain) NSMutableArray* namesOfMatrix4s;
@property(nonatomic,retain) NSMutableArray* namesOfVector4s;
@end

@implementation GLK2UniformMap
{
	GLKMatrix4* rawMatrix4s;
	BOOL* existsRawMatrix4;
	int countOfMatrix4s;
	
	GLKVector4* rawVector4s;
	BOOL* existsRawVector4;
	int countOfVector4s;
}

+(GLK2UniformMap *)uniformMapForLinkedShaderProgram:(GLK2ShaderProgram *)shaderProgram
{
	NSAssert(shaderProgram.status == GLK2ShaderProgramStatusLinked, @"Expected a linked shaderProgram. Could be OK without, if you pre-filled the Uniforms array - but that's very unlikely");
	
	GLK2UniformMap* newValue = [[[GLK2UniformMap alloc] initWithUniforms:shaderProgram.allUniforms] autorelease];
	
	return newValue;
}

- (id)initWithUniforms:(NSArray*) allUniforms
{
    self = [super init];
    if (self) {
        for( GLK2Uniform* uniform in allUniforms )
		{			
			if( uniform.isMatrix )
			{
				switch( uniform.matrixWidth )
				{
					case 2:
						break;
					case 3:
						break;
					case 4:
						countOfMatrix4s++;
						break;
				}
			}
			
			if( uniform.isVector )
			{
				switch( uniform.vectorWidth )
				{
					case 2:
						break;
					case 3:
						break;
					case 4:
						countOfVector4s++;
						break;
				}
			}
		}
		
		/** Now allocate + fill */
		rawMatrix4s = calloc( countOfMatrix4s, sizeof(GLKMatrix4));
		existsRawMatrix4 = calloc( countOfMatrix4s, sizeof(BOOL));
		self.namesOfMatrix4s = [NSMutableArray array];
		int currentIndexMat4 = 0;
		
		rawVector4s = calloc( countOfVector4s, sizeof(GLKMatrix4));
		existsRawVector4 = calloc( countOfVector4s, sizeof(BOOL));
		self.namesOfVector4s = [NSMutableArray array];
		int currentIndexVec4 = 0;
		
		
		for( GLK2Uniform* uniform in allUniforms )
		{
			if( uniform.isMatrix )
			{
				switch( uniform.matrixWidth )
				{
					case 2:
						break;
					case 3:
						break;
					case 4:
						[self.namesOfMatrix4s addObject:uniform.nameInSourceFile];
						currentIndexMat4++;
						break;
				}
			}
			
			if( uniform.isVector )
			{
				switch( uniform.vectorWidth )
				{
					case 2:
						break;
					case 3:
						break;
					case 4:
						[self.namesOfVector4s addObject:uniform.nameInSourceFile];
						currentIndexVec4++;
						break;
				}
			}
		}
    }
    return self;
}

#pragma mark - Matrices

-(GLKMatrix4*) pointerToMatrix4Named:(NSString*) name
{
	NSUInteger rowIndex = [self.namesOfMatrix4s indexOfObject:name];
	if( rowIndex == NSNotFound )
		return NULL;
	
	if( ! existsRawMatrix4[rowIndex] )
		return NULL;
	
	return &rawMatrix4s[rowIndex];
}

-(void) setMatrix4:(GLKMatrix4) value named:(NSString*) name
{
	NSUInteger rowIndex = [self.namesOfMatrix4s indexOfObject:name];
	if( rowIndex == NSNotFound )
		return;
	
	existsRawMatrix4[rowIndex] = TRUE;
	rawMatrix4s[rowIndex] = value;
}

#pragma mark - Vectors

-(GLKVector4*) pointerToVector4Named:(NSString*) name
{
	NSUInteger rowIndex = [self.namesOfVector4s indexOfObject:name];
	if( rowIndex == NSNotFound )
		return NULL;
	
	if( ! existsRawVector4[rowIndex] )
		return NULL;
	
	return &rawVector4s[rowIndex];
}

-(void) setVector4:(GLKVector4) value named:(NSString*) name
{
	NSUInteger rowIndex = [self.namesOfVector4s indexOfObject:name];
	if( rowIndex == NSNotFound )
		return;
	
	existsRawVector4[rowIndex] = TRUE;
	rawVector4s[rowIndex] = value;
}

@end
