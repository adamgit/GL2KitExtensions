//
//  GLK2GetError.c
//  GLK2
//
//  Created by adam on 12/10/2013.
//
//

#include <stdio.h>
#include "GLK2GetError.h"
#include <GLKit/GLKit.h>

void gl2CheckAndClearAllErrors()
{
	GLenum glErrorLast;
	while( (glErrorLast = glGetError()) != GL_NO_ERROR ) // GL spec says you must do this in a WHILE loop
	{
		/** OpenGL spec defines only 6 legal errors, that HAVE to be re-used by all gl method calls. OH THE PAIN! */
		NSDictionary* glErrorNames = @{ @(GL_INVALID_ENUM) : @"GL_INVALID_ENUM", @(GL_INVALID_VALUE) : @"GL_INVALID_VALUE", @(GL_INVALID_OPERATION) : @"GL_INVALID_OPERATION", @(GL_STACK_OVERFLOW) : @"GL_STACK_OVERFLOW", @(GL_STACK_UNDERFLOW) : @"GL_STACK_UNDERFLOW", @(GL_OUT_OF_MEMORY) : @"GL_OUT_OF_MEMORY" };
		
		NSLog(@"GL Error: %@ in %s @ %s:%d", [glErrorNames objectForKey:@(glErrorLast)], __PRETTY_FUNCTION__, __FILE__, __LINE__ );
		
		NSCAssert( FALSE, @"OpenGL Error; you need to investigate this!" ); // can't use NSAssert, because we're inside a C function
	}
}
