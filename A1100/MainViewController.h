#import <UIKit/UIKit.h>
#import "MethodsViewController.h"
#import "ObjectsViewController.h"
@interface MainViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, MethodsViewControllerDelegate, ObjectsViewControllerDelegate> {
    NSMutableArray *object_array0;
    IBOutlet UITextView *user_input;
    IBOutlet UITextView *user_output;
    IBOutlet UIButton *get_button;
    IBOutlet UIButton *put_button;
    IBOutlet UIButton *post_button;
    IBOutlet UIButton *save_input_button;
    NSIndexPath *object_array_index_path;
}
@property (retain) NSMutableArray *object_array0;
@property (nonatomic, retain) UITextView *user_input;
@property (nonatomic, retain) UITextView *user_output;
@property (nonatomic, retain) NSIndexPath *object_array_index_path;
@property (nonatomic, strong) IBOutlet UISwipeGestureRecognizer *swipeDownRecognizer;
@property (nonatomic, retain) IBOutlet UIButton *save_input_button;
@end
const char *mirb(const char *p1);
