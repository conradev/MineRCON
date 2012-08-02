//
//  MCServerListViewController.m
//  MineRCON
//
//  Created by Conrad Kramer on 8/1/12.
//  Copyright (c) 2012 Kramer Software Productions, LLC. All rights reserved.
//

#import <objc/runtime.h>

#import "MCServerListViewController.h"

#import "MCServerDetailViewController.h"

@interface MCServerListViewController () {
    NSMutableArray *_servers;
    NSMutableDictionary *_detailViewControllers;
}

@end

@implementation MCServerListViewController

- (id)init {
    if ((self = [super init])) {
        NSString *documentsDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
        NSString *serversPath = [documentsDirectory stringByAppendingPathComponent:@"Servers.plist"];
        
        // Load the list of servers from disk
        _servers = [NSKeyedUnarchiver unarchiveObjectWithFile:serversPath];
        _servers = _servers ? _servers : [NSMutableArray array];
        
        // Initialize the server detail view controller cache
        _detailViewControllers = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    // Clear the view controller cache
    [_detailViewControllers removeAllObjects];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Servers";
    
    self.tableView.rowHeight = 58.0f;
    
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNewServer)];
    
    self.navigationController.navigationBar.tintColor = [UIColor darkGrayColor];
    self.detailNavigationController.navigationBar.tintColor = [UIColor darkGrayColor];
}

- (void)saveServers {
    @synchronized (self) {
        NSString *documentsDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
        NSString *serversPath = [documentsDirectory stringByAppendingPathComponent:@"Servers.plist"];
        
        // Write list of servers to disk, with protection
        NSError *error = nil;
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:_servers];
        [data writeToFile:serversPath options:NSDataWritingFileProtectionComplete error:&error];
        
        if (error) {
            NSLog(@"Error occured saving data: %@", [error localizedDescription]);
        }
    }
}

- (void)addNewServer {
    // Create new server instance
    MCServer *server = [[MCServer alloc] init];
    
    server.name = [[NSDate date] description];
    server.hostname = @"mc.kramerapps.com";
    server.password = @"C8K$01996okp";
    
    [_servers addObject:server];
    
    // Save the changes to disk
    [self saveServers];
    
    // Reflect the changes in the table view, and select the new server
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[_servers indexOfObject:server] inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
    [self tableView:self.tableView didSelectRowAtIndexPath:indexPath];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _servers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Create cell
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ServerCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ServerCell"];
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }
    
    // Configure cell
    MCServer *server = _servers[indexPath.row];
    cell.textLabel.text = server.name;
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Remove the server from the array, its view controller from the cache, and its row from the table view
        MCServer *server = _servers[indexPath.row];
        [_detailViewControllers removeObjectForKey:server.uuid];
        [_servers removeObject:server];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        // Save the changes to disk
        [self saveServers];
    }
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    MCServer *server = _servers[fromIndexPath.row];
    [_servers removeObject:server];
    [_servers insertObject:server atIndex:toIndexPath.row];
    
    [self saveServers];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    MCServer *server = _servers[indexPath.row];
    
    // Retrieve or create a view controller for the server
    MCServerDetailViewController *detailViewController = [_detailViewControllers objectForKey:server.uuid];
    if (!detailViewController) {
        detailViewController = [[MCServerDetailViewController alloc] initWithServer:server];
        [_detailViewControllers setObject:detailViewController forKey:server.uuid];
    }
    
    if ([_detailNavigationController.viewControllers containsObject:self]) {
        // If the master is where the detail is going, push the detail onto the stack
        NSArray *viewControllers = [_detailNavigationController popToViewController:self animated:NO];
        [viewControllers makeObjectsPerformSelector:@selector(setView:) withObject:nil];
        [_detailNavigationController pushViewController:detailViewController animated:YES];
    } else {
        // If the master is separate from where the detail is going, make the detail the root view controller
        [_detailNavigationController.viewControllers makeObjectsPerformSelector:@selector(setView:) withObject:nil];
        _detailNavigationController.viewControllers = @[detailViewController];
    }
}

@end
