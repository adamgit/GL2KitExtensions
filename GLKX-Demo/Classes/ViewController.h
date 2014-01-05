/**
 Contains the sample code for rendering the current blog post at http://t-machine.org
 
 Any code that we wrote in early posts, and frequently re-use without changes, gets
 moved into the superclass for convenience
 */
#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>

#import "GLK2DrawCallViewController.h"

#import <AVFoundation/AVFoundation.h>

@interface ViewController : GLK2DrawCallViewController <AVCaptureVideoDataOutputSampleBufferDelegate>

@end
