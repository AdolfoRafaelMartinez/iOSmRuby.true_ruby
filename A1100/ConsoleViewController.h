#import <UIKit/UIKit.h>
@interface ConsoleViewController : UIViewController <UITextViewDelegate> {
    IBOutlet UITextView* console_view;
    CGRect old_frame;
}
@property(nonatomic, retain) UITextView* console_view;
@property(nonatomic) CGRect old_frame;
@end
const char *mirb(const char *p1);
