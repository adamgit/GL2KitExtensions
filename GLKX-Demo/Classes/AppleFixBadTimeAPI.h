/**
 It is tragic that this class is needed, but Apple refuses to provide a sane, working
 way of measuring time - even inaccurately!
 
 (The "easy" measure is to use NSDate, but NSDate has an ENORMOUS overhead in requiring
 you to keep creating and destroying objects - NSDate is slow even by the standards of OOP
 creation/destruction. It came up as a major performance bottleneck in several projects
 that don't even use graphics - NSDate slowed down basic UIKit rendering!)
 */
#import <Foundation/Foundation.h>
#include <mach/mach_time.h>
#include <stdint.h>

#define MILLISECONDS_PER_NANOSECOND ( 1.0 / 1000000 )

@interface AppleFixBadTimeAPI : NSObject

uint64_t timeAbsoluteNanoseconds(void);
uint64_t timeAbsoluteMilliseconds();
uint64_t millisecondsFromNanoseconds( uint64_t nanos );

@end
