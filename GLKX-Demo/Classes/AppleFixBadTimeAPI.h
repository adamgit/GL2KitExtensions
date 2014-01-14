/**
 Apple's own timing class that is literally hundreds of times faster than NSDate.
 
 Why Apple doesn't provide an ObjectiveC time-measuring class that's fast? ... I have no idea.
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
