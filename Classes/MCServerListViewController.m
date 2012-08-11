//
//  MCServerListViewController.m
//  MineRCON
//
//  Created by Conrad Kramer on 8/1/12.
//  Copyright (c) 2012 Kramer Software Productions, LLC. All rights reserved.
//

#import "MCServerListViewController.h"
#import "MCServerDetailViewController.h"

NSString * const MCSelectedIndexKey = @"MCSelectedIndex";

@interface MCServerListViewController () {
    NSMutableArray *_servers;
    NSCache *_detailViewsCache;
    
    UIBarButtonItem *_serversButton;
}

@end

@implementation MCServerListViewController

#pragma mark - Initialization

- (id)init {
    if ((self = [super init])) {
        // Initialize variables
        _serversButton = nil;
        _detailViewsCache = [[NSCache alloc] init];

        NSString *documentsDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
        NSString *serversPath = [documentsDirectory stringByAppendingPathComponent:@"Servers.plist"];
        
        // Load the list of servers from disk
        _servers = [NSKeyedUnarchiver unarchiveObjectWithFile:serversPath];
        _servers = _servers ? _servers : [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Servers";
    self.clearsSelectionOnViewWillAppear = ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone);
    
    self.tableView.rowHeight = 58.0f;
    
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNewServer)];
}

#pragma mark - State restoration

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder {
    [super encodeRestorableStateWithCoder:coder];
    
    NSIndexPath *selectedIndex;
    if ((selectedIndex = [self.tableView indexPathForSelectedRow])) {
        [coder encodeInteger:selectedIndex.row forKey:MCSelectedIndexKey];
    }
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder {
    [super decodeRestorableStateWithCoder:coder];
        
    // Get the server at the stored index and display it
    NSUInteger index = (NSUInteger)[coder decodeIntegerForKey:MCSelectedIndexKey];
    index = index < _servers.count ? index : _servers.count - 1;
    MCServer *server = _servers.count ? _servers[index] : nil;
    [self displayViewControllerForServer:server];
    
    // Select the server in the table, if applicable
    if (server) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[_servers indexOfObject:server] inSection:0];
        [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
}

#pragma mark - Server operations

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
    [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
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
        
        // Change the current view to a dummy view if the server deleted is the one currently displayed
        MCServerDetailViewController *detailViewController = [_detailViewsCache objectForKey:server];
        if ([_detailNavigationController.viewControllers containsObject:detailViewController]) {
            [self displayViewControllerForServer:nil];
        }
        
        // Purge objects
        [_detailViewsCache removeObjectForKey:server];
        [_servers removeObject:server];
        
        // Update table view
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        // Save the changes to disk
        [self saveServers];
    }
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    // Pop the object from the array and add it back in at the new index
    MCServer *server = _servers[fromIndexPath.row];
    [_servers removeObject:server];
    [_servers insertObject:server atIndex:toIndexPath.row];
    
    // Save the changed to disk
    [self saveServers];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    MCServer *server = _servers[indexPath.row];
    [self displayViewControllerForServer:server];
}

#pragma mark - Navigation controller delegate

- (void)displayViewControllerForServer:(MCServer *)server {
    // Retrieve or create a view controller for the server
    MCServerDetailViewController *detailViewController = [_detailViewsCache objectForKey:server];
    if (!detailViewController) {
        detailViewController = [[MCServerDetailViewController alloc] initWithServer:server];
        [_detailViewsCache setObject:detailViewController forKey:server];
    }
    
    if ([_detailNavigationController.viewControllers containsObject:self]) {
        // Invalidate any previous view controller's views if they are on the stack
        NSArray *previousViewControllers = [_detailNavigationController popToViewController:self animated:NO];
        [previousViewControllers makeObjectsPerformSelector:@selector(setView:) withObject:nil];
        
        // If the master is where the detail is going, push the detail onto the stack
        [_detailNavigationController pushViewController:detailViewController animated:YES];
    } else {
        // If a different view controller is being pushed, unload the previous one's view
        if (![_detailNavigationController.viewControllers containsObject:detailViewController]) {
            [_detailNavigationController.viewControllers makeObjectsPerformSelector:@selector(setView:) withObject:nil];
        }
        
        _detailNavigationController.viewControllers = @[detailViewController];
    }
}

- (void)setDetailNavigationController:(UINavigationController *)detailNavigationController {
    _detailNavigationController = detailNavigationController;
    _detailNavigationController.delegate = self;
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (![viewController isEqual:self]) {
        viewController.navigationItem.leftBarButtonItem = _serversButton;
    }
}

#pragma mark - Split view controller delegate

- (void)splitViewController:(UISplitViewController *)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem *)button forPopoverController:(UIPopoverController *)popover {
    button.possibleTitles = [NSSet setWithObject:@"Servers"];
    [self splitViewController:svc didChangeBarButtonItem:button];
}

- (void)splitViewController:(UISplitViewController *)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)button {
    [self splitViewController:svc didChangeBarButtonItem:nil];
}

- (void)splitViewController:(UISplitViewController *)svc didChangeBarButtonItem:(UIBarButtonItem *)button {
    _serversButton = button;
    
    // Update the left bar item on the currwently displayed view controller
    if (_detailNavigationController.viewControllers.count) {
        UIViewController *detailViewController = _detailNavigationController.viewControllers[0];
        [detailViewController.navigationItem setLeftBarButtonItem:_serversButton animated:YES];
    }
}

@end
