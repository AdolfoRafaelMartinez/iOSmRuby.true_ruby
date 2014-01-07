#import "ObjectsViewController.h"
#import "IEViewController.h"
@implementation ObjectsViewController
@synthesize storage_array0;
@synthesize storage_table0;
@synthesize delegate;
#pragma mark
- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    [self.storage_table0 setEditing:editing animated:YES];
}
#pragma mark IEViewControllerDelegate methods
-(void)ieViewControllerReturnsObjects:(NSArray*)objects {
    [self.storage_array0 removeAllObjects];
    [self.storage_array0 addObjectsFromArray:objects];
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark UITableView Delegate Methods
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.storage_array0 removeObjectAtIndex:indexPath.row];
		[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
	}
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.delegate objectsViewControllerReturnsIndex:indexPath];
}
- (NSUInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.storage_array0 count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *StackTableIdentifier = @"StackTableIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:StackTableIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:StackTableIdentifier];
    }
    NSUInteger row = [indexPath row];
    cell.textLabel.text = [self.storage_array0 objectAtIndex:row];
    return cell;
}
#pragma mark UIViewController Delegate Methods
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
-(void)viewDidAppear:(BOOL)animated {
    [self.storage_table0 reloadData];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
