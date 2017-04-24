//
//  FirstViewController.m
//  Dealz
//
//  Created by Keir SM on 2017-03-28.
//  Copyright © 2017 Keir SM. All rights reserved.
//

#import "DealsViewController.h"
#import "PopupViewController.h"
#import "DatabaseManager.h"
#import "UserNotifications/UserNotifications.h"
#import "AppDelegate.h"
#define myUUID  @"B5B182C7-EAB1-4988-AA99-B5C1517008D9"
@interface DealsViewController ()

@end

@implementation DealsViewController
{
    NSMutableArray *beaconIds;
    NSMutableArray *names;
    NSMutableArray *urls;
    NSMutableArray *specialDeals;
    
    NSString *name;
    NSString *url;
    BOOL pushN;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    //initializes the beaconIds array that holds a reference to all the beacons visited already
    beaconIds = [[NSMutableArray alloc] init];
    //array that hold the special deals that user has earned
    specialDeals = [[NSMutableArray alloc] init];
    // variable to avoid more than one alert at a given time
    pushN = NO;

    // Custom initialization
    self.locManager = [[CLLocationManager alloc] init];
    self.locManager.delegate = self;
    
    // UUID_ESTIMOTE or UUID_HMSENSOR
    NSUUID *proximityUUID = [[NSUUID alloc] initWithUUIDString:@"B5B182C7-EAB1-4988-AA99-B5C1517008D9"];
    
    //Creates and starts monitoring the region with the given UUID
    self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:proximityUUID identifier:@"HMSensors"];
    [self.locManager startMonitoringForRegion:self.beaconRegion];
    [self.locManager startRangingBeaconsInRegion:(CLBeaconRegion *)self.beaconRegion];

    
    //names array will be populated with the names of the beacons, and urls will be populated with the urls
    names = [[NSMutableArray alloc] init];
    urls = [[NSMutableArray alloc] init];
    
    //part of the popup view set up
    _popV.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.6];
    _popWin.layer.cornerRadius = 10;
    _popWin.layer.shadowOpacity = 0.8;
    _popWin.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)infoButton:(id)sender {
    //Displays the info window if it's closed, otherwise close it
    if (_popV.isHidden){
        _popV.hidden = NO;
        
    }else {
        _popV.hidden = YES;
    }
}

- (IBAction)closeButton:(id)sender {
    _popV.hidden = YES;
}

// table initialization and methods
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [names count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *tableIdentifier = @"TableCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:tableIdentifier];
    
    if (cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:tableIdentifier];
    }
    
    cell.textLabel.text = [names objectAtIndex:indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    name = [names objectAtIndex:indexPath.row];
    url = [urls objectAtIndex:indexPath.row];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self performSegueWithIdentifier:@"popup" sender:self];
}

// set the segue to display the web view
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"popup"]){
        PopupViewController *vc = [segue destinationViewController];
        
        [vc navTitle:name];
        [vc pageUrl:url];
    }
}



#pragma mark <CLLocationManagerDelegate>

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    //sends an alert when entering a beacon region
    pushN = NO;
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:@"New deals"
                                 message:@"There are new deals around you"
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    
    
    UIAlertAction* yesButton = [UIAlertAction
                                actionWithTitle:@"Great"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action) {
                                    //Handle extra functionality if needed
                                }];
    
    [alert addAction:yesButton];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    pushN = NO;
    [self.locManager stopRangingBeaconsInRegion:(CLBeaconRegion *)region];
}

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
    if ([beacons count] > 0)
    {
        //chooses the first beacon within range if there is any
        CLBeacon *aBeacon = [beacons firstObject];
        // resets the table values every time there is a change in the beacon proximity
        [names removeAllObjects];
        [urls removeAllObjects];
        
        //loads the values in the database with the minors of each beacon
        [self loadData:beacons];

        for (aBeacon in beacons)
        {
            int minor = [aBeacon.minor intValue];
            //checks if the beacon has been visited already
            if (!([beaconIds containsObject:[NSString stringWithFormat:@"%d",minor]]) && !(pushN))
            {
                //if so, sends a notification and alert
                UIAlertController * alert = [UIAlertController
                                             alertControllerWithTitle:@"New deals"
                                             message:@"There are new deals around you"
                                             preferredStyle:UIAlertControllerStyleAlert];
                
                
                
                UIAlertAction* yesButton = [UIAlertAction
                                            actionWithTitle:@"Great"
                                            style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * action) {
                                                //Handle extra functionality if needed
                                            }];
                
                [alert addAction:yesButton];
                
                //creates and sends the notification
                UNMutableNotificationContent* objNotificationContent = [[UNMutableNotificationContent alloc] init];
                objNotificationContent.title = [NSString localizedUserNotificationStringForKey:@"There are new deals around you!" arguments:nil];
                objNotificationContent.body = [NSString localizedUserNotificationStringForKey:[NSString stringWithFormat:@"Open the app to find the new deals around you"] arguments:nil];
                objNotificationContent.sound = [UNNotificationSound defaultSound];
                
                /// update application icon badge number
                objNotificationContent.badge = @([[UIApplication sharedApplication] applicationIconBadgeNumber] + 1);
                
                // Deliver the notification in five seconds.
                UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger
                                                              triggerWithTimeInterval:5.f repeats:NO];
                
                UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"ten"
                                                                                      content:objNotificationContent trigger:trigger];
                /// schedule localNotification
                UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
                [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
                    if (!error) {
                        NSLog(@"Local Notification succeeded");
                    }
                    else {
                        NSLog(@"Local Notification failed");
                    }
                }];
                
                pushN = YES;
                
                [self presentViewController:alert animated:YES completion:nil];
                [beaconIds addObject:[NSString stringWithFormat:@"%d",minor]];
                
            }
            //sends a notification if the user is extremely close to a beacon
        
            if (aBeacon.accuracy < 4){
                if (!(pushN)){
                    pushN = YES;
                    [specialDeals addObject:[NSString stringWithFormat:@"%d",minor]];
                    UIAlertController * alert = [UIAlertController
                                             alertControllerWithTitle:@"Great deal"
                                             message:@"Thank you for your partipation, you earned 10% off your next purchase"
                                             preferredStyle:UIAlertControllerStyleAlert];
                
                
                
                    UIAlertAction* yesButton = [UIAlertAction
                                            actionWithTitle:@"Great"
                                            style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * action) {
                                                //Handle extra functionality if needed
                                            }];
                
                [alert addAction:yesButton];
                [self presentViewController:alert animated:YES completion:nil];
    
                //creates and sends the notification
                UNMutableNotificationContent* objNotificationContent = [[UNMutableNotificationContent alloc] init];
                objNotificationContent.title = [NSString localizedUserNotificationStringForKey:@"You are extremely close to an amazing deal" arguments:nil];
                objNotificationContent.body = [NSString localizedUserNotificationStringForKey:[NSString stringWithFormat:@"Open the app to find the great deal closer to you"] arguments:nil];
                objNotificationContent.sound = [UNNotificationSound defaultSound];
                
                /// update application icon badge number
                objNotificationContent.badge = @([[UIApplication sharedApplication] applicationIconBadgeNumber] + 1);
                
                // Deliver the notification in five seconds.
                UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger
                                                              triggerWithTimeInterval:5.f repeats:NO];
                
                UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"ten"
                                                                                      content:objNotificationContent trigger:trigger];
                /// schedule localNotification
                UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
                [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
                    if (!error) {
                        NSLog(@"Local Notification succeeded");
                    }
                    else {
                        NSLog(@"Local Notification failed");
                    }
                }];

                }
            }
            //if the user goes away from the beacon range, it will be able to receive push notifications and alerts again
            // the number is 80 because there was another beacon somewhere in the engineering building at 60~ m that was interfeering with the testing
            else if(aBeacon.accuracy > 80){
                pushN = NO;
            }
            int rssi = (int)aBeacon.rssi;
            
        }
        // reloads the table with new data available
        [self.tableView reloadData];

     
        
        
    }
    
  
}


- (void)loadData:(NSArray*)sender
{
    
    //open database
    //NSLog(@"HERE");
    const char *dbpath = [[DatabaseManager getPath] UTF8String];
    sqlite3_stmt    *statement;
    sqlite3* beaconDatabase = [DatabaseManager getDatabase];
    //start query
    if (sqlite3_open(dbpath, &beaconDatabase) == SQLITE_OK)
    {
        
        CLBeacon *aBeacon = [sender firstObject];
        for (aBeacon in sender){
            //NSLog(@"%d",[aBeacon.minor intValue]);
            NSString *querySQL = [NSString stringWithFormat:
                                  @"SELECT name, URL FROM beacons WHERE minor=\"%d\"",
                                  [aBeacon.minor intValue]];
            
            //if query is successful load data into memory
            const char *query_stmt = [querySQL UTF8String];
            
            if (sqlite3_prepare_v2(beaconDatabase,
                                   query_stmt, -1, &statement, NULL) == SQLITE_OK)
            {
                //NSLog(@"YEYEYE");
                if (sqlite3_step(statement) == SQLITE_ROW)
                {
                    NSString* currentUrl = [[NSString alloc]
                                      initWithUTF8String:
                                      (const char *) sqlite3_column_text(statement, 1)];

                    [urls addObject:currentUrl];
                    
                    
                    NSString* currentName = [[NSString alloc]
                                       initWithUTF8String:
                                       (const char *) sqlite3_column_text(statement, 0)];
                    [names addObject:currentName];
                    
                    //NSLog(@"Beacon found");
                } else {
                    //NSLog(@"Beacon not found");
                }
                sqlite3_finalize(statement);
            }
        }
        
        
        
        sqlite3_close(_beaconDB);
    }
}


@end
