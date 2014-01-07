#import "ConsoleViewController.h"
@implementation ConsoleViewController
@synthesize console_view;
@synthesize old_frame;
#pragma mark
-(void)process_one_line {
    NSString* input_line;
    NSString* output_line;
    NSMutableString* console_text_new;
    NSArray* console_view_lines = [self.console_view.text componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    NSUInteger console_view_line_count = [console_view_lines count];
    input_line = [console_view_lines objectAtIndex:console_view_line_count - 2];
    const char* input = [input_line UTF8String]; 
    const char* output = mirb(input); 
    output_line = [NSString stringWithUTF8String:output];
    console_text_new = [NSMutableString stringWithCapacity:200];
    [console_text_new setString:self.console_view.text];
    [console_text_new appendString:@"\n=> "];
    [console_text_new appendString:output_line];
    [console_text_new appendString:@"\n\n"];
    self.console_view.text = [self truncate_string:console_text_new before:100];    
}
-(NSString*)truncate_string:(NSMutableString*)some_string before:(NSUInteger)some_amount {
    NSUInteger some_string_length = [some_string length];
    if (some_amount < some_string_length) {
        NSUInteger location = some_string_length - some_amount;
        NSRange some_range = NSMakeRange(location, some_amount);
        [some_string deleteCharactersInRange:some_range];
    }
    return [NSString stringWithString:some_string];
}
-(IBAction)hide_keyboard:(id)sender {
    [console_view resignFirstResponder];
    self.console_view.frame = self.old_frame;
}
- (void)keyboardWasShown:(NSNotification *)notification
{
    self.old_frame = self.console_view.frame;
    CGRect aRect = self.console_view.frame;
    aRect.size.height -= 168;
    self.console_view.frame = aRect;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardDidShowNotification object:nil];
    self.console_view.delegate = self;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
#pragma mark UITextViewDelegate methods
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if( [text rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet]].location == NSNotFound ) {
        return YES;
    }
    [self hide_keyboard:0];
    [self process_one_line];
    return NO;
}
@end
