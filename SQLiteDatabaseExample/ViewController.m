//
//  ViewController.m
//  SQLiteDatabaseExample
//
//  Created by PAUL CHRISTIAN on 11/22/17.
//  Copyright © 2017 PAUL CHRISTIAN. All rights reserved.
//

#import "ViewController.h"
#import <sqlite3.h>
#import "studentInfo.h"

@interface ViewController ()
@property(nonatomic,strong) NSString* databaseName;
@property(nonatomic,strong) NSString* databasePath;
@property(nonatomic,strong) NSMutableArray* people;
@property (weak, nonatomic) IBOutlet UITextField *txtName;
@property (weak, nonatomic) IBOutlet UITextField *txtAddress;
@property (weak, nonatomic) IBOutlet UITextField *txtPhone;
@property (weak, nonatomic) IBOutlet UILabel *txtStatusOutput;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _people = [[NSMutableArray alloc] init];
    _databaseName = @"myStudents.db";
    
    // Find path to document folder
    
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [documentPaths objectAtIndex:0];
    _databasePath =[documentsDir stringByAppendingPathComponent:_databaseName];
    
    // copy database to doc dir
    [self copyDatabaseToDocumentsDirectory];
    
    // Retrieve data from Database and store in Array
    
    [self readFromDatabase];
    
    
    
}
-(void)readFromDatabase
{
    // clear out array
    [self.people removeAllObjects];
    sqlite3 *database;
    
    // 1) Open the database
    if (sqlite3_open([_databasePath UTF8String], &database) == SQLITE_OK)
    {
        // 2) Create a query
        char *sqlStatement = "select * from students";
        sqlite3_stmt *compiledStatment;
        
            //if (sqlite3_prepare_v2(database, sqlStatement, -1, & compiledStatment,NULL) == SQLITE_OK)
        if (sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatment, NULL) == SQLITE_OK)
            
        {
            while (sqlite3_step(compiledStatment) == SQLITE_ROW)
                   {
                     char *n = (char *)sqlite3_column_text(compiledStatment, 1);
                     char *a = (char *)sqlite3_column_text(compiledStatment, 2);
                     char *p = (char *)sqlite3_column_text(compiledStatment, 3);
                     NSString* name = [NSString stringWithUTF8String:n];
                     NSString* address = [NSString stringWithUTF8String:a];
                     NSString* phone = [NSString stringWithUTF8String:p];
                     studentInfo *aStudent = [[studentInfo alloc]initWithData:name andAddress:address andPhone:phone];
                     [self.people addObject:aStudent];
                   }
       }
        // free the allocated memory
        sqlite3_finalize(compiledStatment);
        
            
    }
    // cloase db connection
    sqlite3_close(database);
}


- (void)copyDatabaseToDocumentsDirectory
{
    BOOL success;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    success = [fileManager fileExistsAtPath:_databasePath];
    if (success)
        return;
    
    // if this is our first time using the app
    // copy the DB from app's Bundle to Docs Dir
    NSString *databasePathFromApp = [[[NSBundle mainBundle]resourcePath]stringByAppendingPathComponent:_databaseName];
    [fileManager copyItemAtPath:databasePathFromApp toPath:_databasePath error:nil];
    
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}
- (BOOL)insertIntoDatabase:(studentInfo *)aStudent
{
    sqlite3 *database;
    BOOL returnCode = YES;
    if (sqlite3_open([_databasePath UTF8String], &database) == SQLITE_OK)
    {
        char *sqlStatement = "insert into students values (NULL, ?, ?, ?)";
        sqlite3_stmt *compiledStatement;
        if (sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK)
        {
            sqlite3_bind_text(compiledStatement, 1, [aStudent.name UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(compiledStatement, 2, [aStudent.address UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(compiledStatement, 3, [aStudent.phone UTF8String], -1, SQLITE_TRANSIENT);
        }
        
        // run the query
        if (sqlite3_step(compiledStatement) != SQLITE_DONE)
        {
            NSLog(@"Error %s", sqlite3_errmsg(database));
            returnCode = NO;
        }
        else
        {
            NSLog(@"Inserted into row id: %lld",sqlite3_last_insert_rowid(database));
        }
        // cleanup
        sqlite3_finalize(compiledStatement);
        
    }
    sqlite3_close(database);
    return returnCode;

}

- (IBAction)doAddRecord:(id)sender {
    //studentInfo *person = [[studentInfo alloc]initWithData:_txtName.text andAddress:_txtAddress.text andPhone:_txtPhone.text];
    studentInfo *person = [[studentInfo alloc] initWithData:self.txtName.text andAddress:self.txtAddress.text andPhone:self.txtPhone.text];
    NSLog(@"Person = %@,%@,%@",person.name, person.address, person.phone);
    BOOL retCode = [self insertIntoDatabase:person];
    if (retCode == NO)
    {
        NSLog(@"Failed to add a record");
        self.txtStatusOutput.text = @"Failed to add a record";
    }
    else
    {
        NSLog(@"Added a record successfully");
        _txtStatusOutput.text = @"Added a record successfully";
        
    }
    
 }
-(void)findRecordInDatabase
{

    sqlite3 *database;
    
    // 1) Open the database
    if (sqlite3_open([_databasePath UTF8String], &database) == SQLITE_OK)
    {
        // 2) Create a query
        
        // Note to Professor: I originally did this the way you did it in the tutorial but I wanted to search
        // partial names and return the whole name so I changed accordingly.
        
        NSString *selectSQL = [NSString stringWithFormat:@"select * from students where name like '%%%@%%'",_txtName.text];
        char *sqlStatement = (char *)[selectSQL UTF8String];
        sqlite3_stmt *compiledStatment;
        
        //if (sqlite3_prepare_v2(database, sqlStatement, -1, & compiledStatment,NULL) == SQLITE_OK)
        if (sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatment, NULL) == SQLITE_OK)
            
        {
            if (sqlite3_step(compiledStatment) == SQLITE_ROW)
            {
                char *n = (char *)sqlite3_column_text(compiledStatment, 1);
                char *a = (char *)sqlite3_column_text(compiledStatment, 2);
                char *p = (char *)sqlite3_column_text(compiledStatment, 3);
                NSString* name = [NSString stringWithUTF8String:n];
                NSString* address = [NSString stringWithUTF8String:a];
                NSString* phone = [NSString stringWithUTF8String:p];
                //studentInfo *aStudent = [[studentInfo alloc]initWithData:name andAddress:address andPhone:phone];
                //[self.people addObject:aStudent];
                
                //update the lable and text fields
                _txtName.text = name;
                _txtAddress.text = address;
                _txtPhone.text = phone;
                _txtStatusOutput.text = @"Match Found";
            }
            else
            {
                _txtStatusOutput.text = @"Match NOT found";
            }
        }
        // free the allocated memory
        sqlite3_finalize(compiledStatment);
        
        
    }
    // cloase db connection
    sqlite3_close(database);}

- (IBAction)doFindRecord:(id)sender
{
    [self findRecordInDatabase];
}
-(void)deleteRecordFromDatabase
{
    
    sqlite3 *database;
    
    // 1) Open the database
    if (sqlite3_open([_databasePath UTF8String], &database) == SQLITE_OK)
    {
        // 2) Create a query
        NSString *selectSQL = [NSString stringWithFormat:@"delete from students where name = '%@'",_txtName.text];
        char *sqlStatement = (char *)[selectSQL UTF8String];
        sqlite3_stmt *compiledStatment;
        
        //if (sqlite3_prepare_v2(database, sqlStatement, -1, & compiledStatment,NULL) == SQLITE_OK)
        if (sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatment, NULL) == SQLITE_OK)
            
        {
            if (sqlite3_step(compiledStatment) == SQLITE_DONE)
            {
                //char *n = (char *)sqlite3_column_text(compiledStatment, 1);
                //char *a = (char *)sqlite3_column_text(compiledStatment, 0);
                //char *p = (char *)sqlite3_column_text(compiledStatment, 1);
                //NSString* name = [NSString stringWithUTF8String:n];
                //NSString* address = [NSString stringWithUTF8String:a];
                //NSString* phone = [NSString stringWithUTF8String:p];
                //studentInfo *aStudent = [[studentInfo alloc]initWithData:name andAddress:address andPhone:phone];
                //[self.people addObject:aStudent];
                
                //update the lable and text fields
                //_txtName.text = @"Record Deleted";
                //_txtAddress.text = @"Record Deleted";
                //_txtPhone.text = @"Record Deleted";
                _txtStatusOutput.text = @"Record Deleted";
            }
            else
            {
                _txtStatusOutput.text = @"Match NOT found";
            }
//            _txtStatusOutput.text = @"Record Deleted";
            
            
        }
        // free the allocated memory
        sqlite3_finalize(compiledStatment);
        
        
    }
    // cloase db connection
    sqlite3_close(database);}
- (IBAction)doDeleteRecord:(id)sender
{
    [self deleteRecordFromDatabase];
}


@end
