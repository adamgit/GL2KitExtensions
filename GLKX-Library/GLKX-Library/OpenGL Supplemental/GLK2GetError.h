/**
 Part 4: 
 */

#import <Foundation/Foundation.h>
#include <stdio.h>

#ifndef GLK2_GLK2GetError_h
#define GLK2_GLK2GetError_h

void _gl2CheckAndClearAllErrorsImpl(const char *source_function, const char *source_file, int source_line);

#define gl2CheckAndClearAllErrors() _gl2CheckAndClearAllErrorsImpl(__PRETTY_FUNCTION__,__FILE__,__LINE__)

#endif
