#import <Foundation/Foundation.h>
#import "IEViewController.h"
@protocol ObjectsViewControllerDelegate <NSObject>
@required
-(void)objectsViewControllerReturnsIndex:(NSIndexPath*)some_index;
@end

@interface ObjectsViewController : UIViewController  <UITableViewDelegate, UITableViewDataSource, IEViewControllerDelegate>{
	id<ObjectsViewControllerDelegate> delegate;
    NSMutableArray *storage_array0;
    IBOutlet UITableView *storage_table0;
}
@property (retain) id<ObjectsViewControllerDelegate> delegate;
@property (nonatomic, retain) NSMutableArray *storage_array0;
@property (nonatomic, retain) UITableView *storage_table0;
@end