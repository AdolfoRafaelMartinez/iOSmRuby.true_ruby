#import "MIRBViewController.h"
#import "compile.h"
#import "string.h"
struct RString *mrb_str_ptr_result;
char last_char;
char ruby_code[1024] = { 0 };
char a_code_line[1024] = { 0 };
int char_index;
char* mirb_output;
mrbc_context *cxt;
struct mrb_parser_state *parser;
mrb_state *mrb;
mrb_value result;
int n;
int code_block_open = FALSE;

@implementation MIRBViewController
@synthesize console_view;
@synthesize old_frame;
#pragma mark
int is_code_block_open_objc(struct mrb_parser_state *parser)
{
    int code_block_open = FALSE;
    
    /* check for unterminated string */
    if (parser->sterm) return TRUE;
    
    /* check if parser error are available */
    if (0 < parser->nerr) {
        const char *unexpected_end = "syntax error, unexpected $end";
        const char *message = parser->error_buffer[0].message;
        
        /* a parser error occur, we have to check if */
        /* we need to read one more line or if there is */
        /* a different issue which we have to show to */
        /* the user */
        
        if (strncmp(message, unexpected_end, strlen(unexpected_end)) == 0) {
            code_block_open = TRUE;
        }
        else if (strcmp(message, "syntax error, unexpected keyword_end") == 0) {
            code_block_open = FALSE;
        }
        else if (strcmp(message, "syntax error, unexpected tREGEXP_BEG") == 0) {
            code_block_open = FALSE;
        }
        return code_block_open;
    }
    
    switch (parser->lstate) {
            
            /* all states which need more code */
            
        case EXPR_BEG:
            /* an expression was just started, */
            /* we can't end it like this */
            code_block_open = TRUE;
            break;
        case EXPR_DOT:
            /* a message dot was the last token, */
            /* there has to come more */
            code_block_open = TRUE;
            break;
        case EXPR_CLASS:
            /* a class keyword is not enough! */
            /* we need also a name of the class */
            code_block_open = TRUE;
            break;
        case EXPR_FNAME:
            /* a method name is necessary */
            code_block_open = TRUE;
            break;
        case EXPR_VALUE:
            /* if, elsif, etc. without condition */
            code_block_open = TRUE;
            break;
            
            /* now all the states which are closed */
            
        case EXPR_ARG:
            /* an argument is the last token */
            code_block_open = FALSE;
            break;
            
            /* all states which are unsure */
            
        case EXPR_CMDARG:
            break;
        case EXPR_END:
            /* an expression was ended */
            break;
        case EXPR_ENDARG:
            /* closing parenthese */
            break;
        case EXPR_ENDFN:
            /* definition end */
            break;
        case EXPR_MID:
            /* jump keyword like break, return, ... */
            break;
        case EXPR_MAX_STATE:
            /* don't know what to do with this token */
            break;
        default:
            /* this state is unexpected! */
            break;
    }
    
    return code_block_open;
}
-(void)process_one_line {
    NSString* input_line_with_prompt;
    NSString* output_line;
    NSMutableString* console_text_new;
    NSCharacterSet* newlineCharacterSet0 = [NSCharacterSet newlineCharacterSet];
    NSArray* console_view_lines = [self.console_view.text componentsSeparatedByCharactersInSet:newlineCharacterSet0];
    NSUInteger console_view_line_count = [console_view_lines count];
    input_line_with_prompt = [console_view_lines objectAtIndex:console_view_line_count - 2];
    NSString* input_line = [input_line_with_prompt substringFromIndex:2];
    const char* code_from_user = [input_line UTF8String];
    // while (TRUE) {
        /*
        if (code_block_open) {
            printf("* ");
        }
        else {
            printf("> ");
        }
        */
        char_index = 0;
        while ((last_char = *code_from_user) != '\n') {
            if (last_char == NULL) break;
            a_code_line[char_index++] = last_char;
            code_from_user++;
        }
        if (last_char == NULL) {
            if (*a_code_line == NULL) { // first character is also NULL
                printf("\n");
                NSLog(@"big time error");
                return; // break;
            }
        }
        a_code_line[char_index] = '\0';
        
        // check for quit or exit
        if ((strcmp(a_code_line, "quit") == 0) || (strcmp(a_code_line, "exit") == 0)) {
            if (!code_block_open) {
                NSLog(@"big time error");
                return; // break;
            } else {
                // count the quit/exit commands as strings if in a quote block
                strcat(ruby_code, "\n");
                strcat(ruby_code, a_code_line);
            }
        } else {
            if (code_block_open) {
                strcat(ruby_code, "\n");
                strcat(ruby_code, a_code_line);
            } else {
                strcpy(ruby_code, a_code_line);
            }
        } // if ((strcmp(one_code_line, "quit") == 0) || (strcmp(one_code_line, "exit") == 0)) {
        
        // parse code
        parser = mrb_parser_new(mrb);
        parser->s = ruby_code;
        parser->send = ruby_code + strlen(ruby_code);
        parser->lineno = 1;
        mrb_parser_parse(parser, cxt);
        code_block_open = is_code_block_open_objc(parser);
        if (code_block_open) {
            console_text_new = [NSMutableString stringWithCapacity:200];
            [console_text_new setString:self.console_view.text];
            [console_text_new appendString:@"* "];
            self.console_view.text = [self truncate:console_text_new keeping:1024];
        } else {
            if (0 < parser->nerr) {
                /* syntax error */
                printf("line %d: %s\n", parser->error_buffer[0].lineno, parser->error_buffer[0].message);
                int error_message_length = strlen(parser->error_buffer[0].message);
                mirb_output = malloc(error_message_length);
                strncpy(mirb_output, parser->error_buffer[0].message, error_message_length);
                mirb_output[error_message_length] = '\0';
            } else {
                /* generate bytecode */
                n = mrb_generate_code(mrb, parser);
                /* evaluate the bytecode */
                result = mrb_run(mrb,
                                 /* pass a proc for evaulation */
                                 mrb_proc_new(mrb, mrb->irep[n]),
                                 mrb_top_self(mrb));
                if (mrb->exc) {
                    /* yes exception */
                    mrb_value obj = mrb_obj_value(mrb->exc);
                    obj = mrb_funcall(mrb, obj, "inspect", 0);
                    struct RString *exception_str;
                    if (mrb_type(obj) == MRB_TT_STRING) {
                        exception_str = mrb_str_ptr(obj);
                        mirb_output = malloc(exception_str->len);
                        strncpy(mirb_output, exception_str->ptr, exception_str->len);
                        mirb_output[exception_str->len] = '\0';
                    } // if (mrb_type(obj) == MRB_TT_STRING) {
                    mrb->exc = 0;
                } else {
                    /* no exception */
                    result = mrb_funcall(mrb, result, "inspect", 0);
                    if (mrb_type(result) == MRB_TT_STRING) {
                        mrb_str_ptr_result = mrb_str_ptr(result);
                        mirb_output = malloc(mrb_str_ptr_result->len);
                        strncpy(mirb_output, mrb_str_ptr_result->ptr, mrb_str_ptr_result->len);
                        mirb_output[mrb_str_ptr_result->len] = '\0';
                    } // if (mrb_type(result) == MRB_TT_STRING) {
                } // if (mrb->exc) {
            } // if (0 < parser->nerr) {
            ruby_code[0] = '\0';
            output_line = [NSString stringWithUTF8String:mirb_output];
            console_text_new = [NSMutableString stringWithCapacity:200];
            [console_text_new setString:self.console_view.text];
            [console_text_new appendString:@"=> "];
            [console_text_new appendString:output_line];
            [console_text_new appendString:@"\n\n> "];
            self.console_view.text = [self truncate:console_text_new keeping:1024];
        } // if (code_block_open) { 
    // } while (TRUE) {
    /*
    mrb_parser_free(parser);
    mrbc_context_free(mrb, cxt);
    mrb_close(mrb);
    */
}
-(NSString*)truncate:(NSString*)some_string keeping:(NSUInteger)some_amount {
    NSUInteger some_string_length = [some_string length];
    if (some_string_length > some_amount) {
        NSUInteger here_forward = some_string_length - some_amount;
        return [some_string substringFromIndex:here_forward];
    }
    return some_string;
}
-(IBAction)hide_keyboard:(id)sender {
    [console_view resignFirstResponder];
    self.console_view.frame = self.old_frame;
}
- (void)keyboardWasShown:(NSNotification *)notification
{
    self.old_frame = self.console_view.frame;
    CGRect aRect = self.console_view.frame;
    aRect.size.height -= 167;
    self.console_view.frame = aRect;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardDidShowNotification object:nil];
    self.console_view.text = @"> ";
    self.console_view.delegate = self;
    
    /* new interpreter instance */
    mrb = mrb_open();
    if (mrb == NULL) {
        NSLog(@"Invalid mrb interpreter, exiting mirb");
        NSLog(@"EXIT_FAILURE");
    }
    cxt = mrbc_context_new(mrb);
    cxt->capture_errors = 1;
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
    NSUInteger console_text_length = [self.console_view.text length];
    NSMutableString* old_console_text = [NSMutableString stringWithCapacity:console_text_length];
    [old_console_text setString:self.console_view.text];
    [old_console_text appendString:@"\n"];
    self.console_view.text = old_console_text;
    // [self hide_keyboard:0];
    [self process_one_line];
    return NO;
}
@end

