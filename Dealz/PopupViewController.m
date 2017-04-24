//
//  PopupViewController.m
//  Dealz
//
//  Created by Keir SM on 2017-04-01.
//  Copyright © 2017 Keir SM. All rights reserved.
//

#import "PopupViewController.h"

@interface PopupViewController (){
    NSString *pageUrl;
}

@end

@implementation PopupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSURL *url = [NSURL URLWithString:pageUrl];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    
    [_webView loadRequest:urlRequest];
    UIBarButtonItem *shareButton = [[UIBarButtonItem alloc]
                                    initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                    target:self
                                    action:@selector(shareAction:)];
    self.navigationItem.rightBarButtonItem = shareButton;
    _oView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.6];
    _socView.backgroundColor  = [UIColor whiteColor];
    _socView.layer.cornerRadius = 10;
    _socView.layer.shadowOpacity = 0.8;
    _socView.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    
}
- (IBAction)fbShare:(id)sender {
     }
- (IBAction)twShare:(id)sender {
    [self targetedShare:SLServiceTypeTwitter];
}

- (IBAction)shareAction:(id)sender
{
    [self targetedShare:SLServiceTypeFacebook];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)navTitle:(NSString*)ti{
    self.title = ti;
}

-(void)pageUrl:(NSString *)url{
    pageUrl = url;
}


-(void)shareContent{
    NSString * message =[NSString stringWithFormat:@"Incredible deals here: %@",pageUrl];
    NSArray * shareItems = @[message];
    
    UIActivityViewController * avc = [[UIActivityViewController alloc] initWithActivityItems:shareItems applicationActivities:nil];
    [self presentViewController:avc animated:YES completion:nil];
}

-(void)targetedShare:(NSString *)serviceType {
    if([SLComposeViewController isAvailableForServiceType:serviceType]){
        SLComposeViewController *shareView = [SLComposeViewController composeViewControllerForServiceType:serviceType];
        
        [shareView setInitialText:[NSString stringWithFormat:@"Incredible deals here: %@",pageUrl]];
        [self presentViewController:shareView animated:YES completion:nil];
        
    } else {
        
        UIAlertView *alert;
        alert = [[UIAlertView alloc]
                 initWithTitle:@"You do not have this service"
                 message:nil
                 delegate:self
                 cancelButtonTitle:@"OK"
                 otherButtonTitles:nil];
        
        [alert show];
    }
    
   
}

   

@end
