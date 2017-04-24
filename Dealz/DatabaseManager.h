//
//  DatabaseManager.h
//  Dealz
//
//  Created by Keir SM on 2017-04-02.
//  Copyright © 2017 Keir SM. All rights reserved.
//

#import <sqlite3.h>
#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>


@interface DatabaseManager : NSObject {
    int currentMinor;
}

//@property (strong, nonatomic) NSString *databasePath;
//@property (nonatomic) sqlite3 *beaconDB;
@property (weak, nonatomic) IBOutlet UITextField *results;
@property (strong, nonatomic) NSString *lat;
@property (strong, nonatomic) NSString *lng;
@property (strong, nonatomic)NSMutableArray *names;
@property (strong, nonatomic)NSString *name;
@property (strong, nonatomic)NSMutableArray *urls;
@property (strong, nonatomic)NSString *url;
@property (strong, nonatomic)NSString *currentUrl;
@property (strong, nonatomic)NSString *currentName;

- (void)initDatabase;
- (void)loadData:(NSArray*)sender;
- (void)saveData:(id)sender;

+(NSString*)getPath;
+(sqlite3*)getDatabase;

@end
