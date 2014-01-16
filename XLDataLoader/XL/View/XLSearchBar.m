//
//  XLSearchBar.m
//  Lynkos
//
//  Created by Martin Barreto on 12/15/13.
//  Copyright (c) 2013 Lynkos. All rights reserved.
//

#import "XLSearchBar.h"

@implementation XLSearchBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        UITextField * textField = [self textField:self];
        textField.clearButtonMode = UITextFieldViewModeNever;
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

-(UITextField *)textField:(UIView *)view
{
    if ([view isKindOfClass:[UITextField class]]){
        return (UITextField *)view;
    }
    for (UIView * subview in view.subviews) {
        UITextField * textField = [self textField:subview];
        if (textField) return textField;
    }
    return nil;
}

-(void)stopActivityIndicator
{
    UITextField *searchField = [self textField:self];
    if (searchField) {
        if ([searchField.rightView isKindOfClass:[UIActivityIndicatorView class]]){
            [((UIActivityIndicatorView *)searchField.rightView) stopAnimating];
            // replace old view
            
        }
    }
    
}

-(void)startActivityIndicator
{
    UITextField *searchField = [self textField:self];
    if (searchField) {
        if (![searchField.rightView isKindOfClass:[UIActivityIndicatorView class]]){
            UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            searchField.rightView  = spinner;
            searchField.rightViewMode = UITextFieldViewModeAlways;
        }
        [((UIActivityIndicatorView *)searchField.rightView) startAnimating];
    }
}

@end
