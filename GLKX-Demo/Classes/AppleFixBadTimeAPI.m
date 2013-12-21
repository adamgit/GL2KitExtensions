#import "AppleFixBadTimeAPI.h"


@implementation AppleFixBadTimeAPI

/** From Apple docs: https://developer.apple.com/library/mac/qa/qa1398/_index.html
 This is INSANELY complicated
 */
uint64_t timeAbsoluteNanoseconds(void)
{
    uint64_t        time;
    uint64_t        timeNano;
    static mach_timebase_info_data_t    sTimebaseInfo;
	
    time = mach_absolute_time();
	
    // Convert to nanoseconds.
	
    // If this is the first time we've run, get the timebase.
    // We can use denom == 0 to indicate that sTimebaseInfo is 
    // uninitialised because it makes no sense to have a zero 
    // denominator is a fraction.
	
    if ( sTimebaseInfo.denom == 0 ) {
        (void) mach_timebase_info(&sTimebaseInfo);
    }
	
    // Do the maths. We hope that the multiplication doesn't 
    // overflow; the price you pay for working in fixed point.
	
    timeNano = time * sTimebaseInfo.numer / sTimebaseInfo.denom;
	
    return timeNano;
}

uint64_t timeAbsoluteMilliseconds()
{
	uint64_t timeNanoseconds = timeAbsoluteNanoseconds();
	
	return millisecondsFromNanoseconds( timeNanoseconds );
}

uint64_t millisecondsFromNanoseconds( uint64_t nanos )
{
	return nanos * MILLISECONDS_PER_NANOSECOND;
}

@end
