#import "MethodsViewController.h"
@implementation MethodsViewController
@synthesize delegate;
@synthesize methods_array0;
@synthesize methods_table0;
#pragma mark UITableView delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString* some_method = [methods_array0 objectAtIndex:indexPath.row];
    some_method = [@"." stringByAppendingString:some_method];
    [self.delegate methodsViewControllerReturnsMethod:some_method];
}
- (NSUInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSUInteger n;
    if (tableView == methods_table0) {
        n = [self.methods_array0 count];
    }
    return n;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == methods_table0) {
        static NSString *MethodsTableIdentifier = @"MethodsTableIdentifier";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MethodsTableIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MethodsTableIdentifier];
        }
        NSUInteger row = [indexPath row];
        cell.textLabel.text = [self.methods_array0 objectAtIndex:row];
        return cell;
    }
    return 0;
}
#pragma mark UIViewController delegates
- (void)viewDidLoad
{
    [super viewDidLoad];
}
- (void)viewDidUnload
{
    [super viewDidUnload];
}
- (void)dealloc
{
	[super dealloc];
}
@end
