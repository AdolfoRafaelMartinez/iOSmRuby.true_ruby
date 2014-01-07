#import <Foundation/Foundation.h>

@protocol MethodsViewControllerDelegate <NSObject>
@required
- (void)methodsViewControllerReturnsMethod:(NSString*)some_method;
@end

@interface MethodsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>{
	id<MethodsViewControllerDelegate> delegate;
    NSMutableArray *methods_array0;
    IBOutlet UITableView *methods_table0;
}
@property (retain) id<MethodsViewControllerDelegate> delegate;
@property (retain) NSMutableArray *methods_array0;
@property (nonatomic, retain) UITableView *methods_table0;
@end
