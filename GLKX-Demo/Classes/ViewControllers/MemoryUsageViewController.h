/**
 
 A ViewController
 
 */
#import <UIKit/UIKit.h>

@interface MemoryUsageViewController : UIViewController

@property(nonatomic,retain) IBOutlet UILabel* lFreeMem, *lUsedMem;

-(IBAction) tappedLoadTexture1:(id)sender;
-(IBAction) tappedUnloadTexture1:(id)sender;

-(IBAction) tappedLoadTexture2:(id)sender;
-(IBAction) tappedUnloadTexture2:(id)sender;

@end
