//
//  PopupViewController.h
//  Dealz
//
//  Created by Keir SM on 2017-04-01.
//  Copyright © 2017 Keir SM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Social/Social.h>

@interface PopupViewController : UIViewController

-(void)navTitle:(NSString*)ti;
-(void)pageUrl:(NSString*)url;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIView *oView;
@property (weak, nonatomic) IBOutlet UIView *socView;
@property (weak, nonatomic) IBOutlet UIButton *fbBtn;
@property (weak, nonatomic) IBOutlet UIButton *twtBtn;

@end
