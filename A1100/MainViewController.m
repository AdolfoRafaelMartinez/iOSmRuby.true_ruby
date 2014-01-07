#import "MainViewController.h"
#import "MethodsViewController.h"
#import "ObjectsViewController.h"
@implementation MainViewController
@synthesize user_input;
@synthesize user_output;
@synthesize object_array0;
@synthesize object_array_index_path;
@synthesize swipeDownRecognizer;
@synthesize save_input_button;
#pragma mark MethodsViewController
- (void)methodsViewControllerReturnsMethod:(NSString*)some_method {
    self.user_input.text = [self.user_input.text stringByAppendingString:some_method];
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark ObjectsViewControllerDelegate methods
-(void)objectsViewControllerReturnsIndex:(NSIndexPath*)some_index {
    self.object_array_index_path = some_index;
    self.user_input.text = [object_array0 objectAtIndex:self.object_array_index_path.row];
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark custom methods
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender { 
    if ([[segue identifier] isEqualToString:@"MethodsViewController"]) {
        self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Ruby" style: UIBarButtonItemStyleBordered target:nil action:nil] autorelease];
        MethodsViewController* methodsViewController = [segue destinationViewController];
        methodsViewController.delegate = self;
        if ([self.user_input.text length] != 0) {
            const char *input_const_char_class = [[self.user_input.text stringByAppendingString:@".class"] UTF8String];
            const char *input_const_char_methods = [[self.user_input.text stringByAppendingString:@".methods"] UTF8String];
            const char *output_const_char_class = mirb(input_const_char_class);
            const char *output_const_char_methods = mirb(input_const_char_methods);
            NSString *output_NSString_class = [NSString stringWithUTF8String:output_const_char_class];
            NSString *output_NSString_methods = [NSString stringWithUTF8String:output_const_char_methods];
            output_NSString_methods = [output_NSString_methods substringToIndex:[output_NSString_methods length] - 1];
            output_NSString_methods = [output_NSString_methods substringFromIndex:1];
            NSArray *output_NSArray = [output_NSString_methods componentsSeparatedByString:@","];
            output_NSArray = [output_NSArray sortedArrayUsingComparator: ^(id obj1, id obj2){return [obj1 compare: obj2];}];
            NSMutableArray *output_NSMutableArray = [NSMutableArray arrayWithCapacity:[output_NSArray count]];
            NSEnumerator* enumerator = [output_NSArray objectEnumerator];
            NSString* element;
            while(element = [enumerator nextObject]) {
                element = [element stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                element = [element substringFromIndex:1];
                [output_NSMutableArray addObject:element];
            }
            methodsViewController.title = [@"Methods for " stringByAppendingString:output_NSString_class];
            methodsViewController.methods_array0 = output_NSMutableArray;
        } else {
            methodsViewController.methods_array0 = NULL;
        }
    }
    if ([[segue identifier] isEqualToString:@"StorageViewController"]) {
        self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"New" style: UIBarButtonItemStyleBordered target:nil action:nil] autorelease];
        [self save_object:sender];
        ObjectsViewController* storageViewController = [segue destinationViewController];
        storageViewController.delegate = self;
        storageViewController.storage_array0 = self.object_array0;
    }
}
-(IBAction)drop_keyboard:(id)sender{
	[user_input resignFirstResponder];
}
-(IBAction)evaluatate:(id)sender {
    [user_input resignFirstResponder];
    if ([user_input.text length] != 0) {
        const char *input = [user_input.text UTF8String];
        const char *output = mirb(input);
        self.user_output.text = [NSString stringWithUTF8String:output];
    }
}
-(IBAction)get_object:(id)sender {
    self.user_input.text = [self.object_array0 objectAtIndex:[self.object_array_index_path row]];
}
-(IBAction)put_object:(id)sender {
	[user_input resignFirstResponder];
    [self.object_array0 replaceObjectAtIndex:self.object_array_index_path.row withObject:self.user_input.text];
    self.object_array_index_path = Nil;
}
-(IBAction)post_object:(id)sender {
	[user_input resignFirstResponder];
    [self.object_array0 addObject:self.user_input.text];
    
}
-(void)save_object:(id)sender {
    if ([self.user_input.text length] != 0) {
        if (self.object_array_index_path == Nil) {
            [self post_object:0];
        } else {
            [self put_object:0];
        }
        self.user_input.text = NULL;
    }
}
-(IBAction)clear_input:(id)sender {
    self.user_input.text = Nil;
    self.user_output.text = Nil;
    self.object_array_index_path = Nil;
}
#pragma mark UIViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.object_array0 = [[NSMutableArray alloc] init];
    [self.view addGestureRecognizer:self.swipeDownRecognizer];
    self.object_array_index_path = NULL;
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
