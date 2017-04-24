//
//  FirstViewController.h
//  Dealz
//
//  Created by Keir SM on 2017-03-28.
//  Copyright © 2017 Keir SM. All rights reserved.
//

#import <sqlite3.h>
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface DealsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *infoButton;

@property (strong, nonatomic) CLLocationManager *locManager;
@property (strong, nonatomic) CLBeaconRegion *beaconRegion;
@property (strong, nonatomic) NSString *databasePath;
@property (nonatomic) sqlite3 *beaconDB;
@property (weak, nonatomic) IBOutlet UITextField *results;
@property (weak, nonatomic) IBOutlet UIView *popV;
@property (weak, nonatomic) IBOutlet UIView *popWin;

@end

