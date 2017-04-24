//
//  DatabaseManager.m
//  Dealz
//
//  Created by Keir SM on 2017-04-02.
//  Copyright © 2017 Keir SM. All rights reserved.
//

#import "DatabaseManager.h"
NSString *databasePath;
sqlite3 *beaconDB;

@implementation DatabaseManager{
    
}

-(id)init{
    self.names = [[NSMutableArray alloc] init];
    self.urls = [[NSMutableArray alloc] init];
    return self;
}

-(void)initDatabase
{
    
    NSString *documentsDirectory;
    
    // set the document directory path
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    documentsDirectory = paths[0];
    
    // Build the path to the database file
    
    // FOR NOW: Change the database name if you want to play with different table types - the tables are permenant, so you cannot just change them, reload the db and insert again.
    databasePath = [[NSString alloc]
                    initWithString: [documentsDirectory stringByAppendingPathComponent:
                                     @"Dealsss.db"]];
    
    NSFileManager *filemgr = [NSFileManager defaultManager];
    //instead of copying from the mainbundle, we will create the database here if it does not already exist
    if ([filemgr fileExistsAtPath: databasePath ] == NO)
    {
        const char *dbpath = [databasePath UTF8String];
        // open the database
        if (sqlite3_open(dbpath, &beaconDB) == SQLITE_OK)
        {
            //create the table if one does not exist
            char *errMsg;
            const char *sql_stmt =
            "CREATE TABLE IF NOT EXISTS BEACONS (MINOR INTEGER PRIMARY KEY, MAJOR INTEGER, NAME TEXT, UUID TEXT, URL TEXT, LAT REAL, LONG REAL)";
            if (sqlite3_exec(beaconDB, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK)
            {
                //NSLog(@"Failed to create table");
            }
            sqlite3_close(beaconDB);
            //check for those errors
        } else {
            //NSLog(@"Failed to open/create database");
        }
    }
    [self saveData:nil];
}



- (void) saveData:(id)sender
{
    sqlite3_stmt    *statement;
    const char *dbpath = [databasePath UTF8String];
    //open the database
    if (sqlite3_open(dbpath, &beaconDB) == SQLITE_OK)
    {
        
        // Insert given values into the database
        
        NSString *insertSQL = [NSString stringWithFormat:
                               @"INSERT INTO BEACONS (minor, major, name, UUID, URL, lat, long) VALUES (\"%d\", \"%d\", \"%s\", \"%s\", \"%s\", \"%f\", \"%f\")",
                               21112, 1, "Sobeys", "B5B182C7-EAB1-4988-AA99-B5C1517008D9", "https://flipp.com/flyer/1095750-sobeys-weekly-flyer-atlantic", 47.574221 , -52.735337];
        
        const char *insert_stmt = [insertSQL UTF8String];
        
        sqlite3_prepare_v2(beaconDB, insert_stmt,
                           -1, &statement, NULL);
        
        if (sqlite3_step(statement) == SQLITE_DONE)
        {
            NSLog(@"beacon added");
        } else {
            NSLog(@"Failed to add beacon");
        }
        
        NSString *insertAgainSQL = [NSString stringWithFormat:
                                    @"INSERT INTO BEACONS (minor, major, name, UUID, URL, lat, long) VALUES (\"%d\", \"%d\", \"%s\", \"%s\", \"%s\", \"%f\", \"%f\")",
                                    4729, 1, "Home Depot", "B5B182C7-EAB1-4988-AA99-B5C1517008D9", "https://flipp.com/flyer/1093010-home-depot-weekly-flyer", 47.572825, -52.731609];
        
        
        const char *insertAgain_stmt = [insertAgainSQL UTF8String];
        
        sqlite3_prepare_v2(beaconDB, insertAgain_stmt,
                           -1, &statement, NULL);
        
        if (sqlite3_step(statement) == SQLITE_DONE)
        {
            NSLog(@"beacon added");
        } else {
            NSLog(@"Failed to add beacon");
        }
        
        sqlite3_finalize(statement);
        
        sqlite3_close(beaconDB);
    }
}

+(NSString*)getPath{
    return databasePath;
}

+(sqlite3*)getDatabase{
    return beaconDB;
}

- (void)loadData:(NSArray*)sender
{
    
    //open database
    const char *dbpath = [databasePath UTF8String];
    sqlite3_stmt    *statement;
    //start query
    if (sqlite3_open(dbpath, &beaconDB) == SQLITE_OK)
    {
        
        CLBeacon *aBeacon = [sender firstObject];
        for (aBeacon in sender){
          
            NSString *querySQL = [NSString stringWithFormat:
                                  @"SELECT minor, URL FROM beacons WHERE minor=\"%d\"",
                                  [aBeacon.minor intValue]];
            
            //if query is successful load data into memory
            const char *query_stmt = [querySQL UTF8String];
            
            if (sqlite3_prepare_v2(beaconDB,
                                   query_stmt, -1, &statement, NULL) == SQLITE_OK)
            {
       
                if (sqlite3_step(statement) == SQLITE_ROW)
                {
                    
                    self.currentUrl = [[NSString alloc]
                                       initWithUTF8String:
                                       (const char *) sqlite3_column_text(statement, 1)];

                    [self.urls addObject:self.currentUrl];
                    
                    
                    self.currentName = [[NSString alloc]
                                        initWithUTF8String:
                                        (const char *) sqlite3_column_text(statement, 0)];
                    [self.names addObject:self.currentName];
                    
                    self.lat = [[NSString alloc]
                                initWithUTF8String:
                                (const char *) sqlite3_column_text(statement, 2)];
                    
                    
                    
                    self.lng = [[NSString alloc]
                                initWithUTF8String:
                                (const char *) sqlite3_column_text(statement, 3)];
                    
                    // NSLog(@"Beacon found");
                } else {
                    //NSLog(@"Beacon not found");
                }
                sqlite3_finalize(statement);
            }
        }
        
        
        
        sqlite3_close(beaconDB);
    }
}

@end
