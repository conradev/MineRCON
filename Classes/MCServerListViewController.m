//
//  MCServerListViewController.m
//  MineRCON
//
//  Created by Conrad Kramer on 8/1/12.
//  Copyright (c) 2012 Kramer Software Productions, LLC. All rights reserved.
//

#import "MCServerListViewController.h"
#import "MCServerDetailViewController.h"
#import "MCRCONClient.h"
#import "MCEjectButton.h"

#import "DDLog.h"

extern int ddLogLevel;

NSString * const MCSelectedIndexKey = @"MCSelectedIndex";

NSString * const MCServerCellIdentifier = @"MCServerCell";

@interface MCServerListViewController () {
    NSMutableArray *_servers;
    NSCache *_detailViewsCache;    
}

@end

@implementation MCServerListViewController

#pragma mark - Initialization

- (id)init {
    if ((self = [super init])) {
        _detailViewsCache = [[NSCache alloc] init];

        NSString *documentsDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
        NSString *serversPath = [documentsDirectory stringByAppendingPathComponent:@"Servers.plist"];
        
        _servers = [NSKeyedUnarchiver unarchiveObjectWithFile:serversPath];
        _servers = _servers ? _servers : [NSMutableArray array];
        
        [_servers enumerateObjectsUsingBlock:^(MCServer *server, NSUInteger idx, BOOL *stop) {
            [self beginObservingServer:server];
        }];
        
        __weak MCServerListViewController *weakSelf = self;
        [[NSNotificationCenter defaultCenter] addObserverForName:MCRCONClientStateDidChangeNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
            MCRCONClient *client = (MCRCONClient *)note.object;
            [weakSelf reloadRowForServer:client.server];
        }];
    }
    return self;
}

- (void)dealloc {
    [_servers enumerateObjectsUsingBlock:^(MCServer *server, NSUInteger idx, BOOL *stop) {
        [self stopObservingServer:server];
    }];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MCRCONClientStateDidChangeNotification object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Servers";
    self.clearsSelectionOnViewWillAppear = NO;
    
    self.tableView.delaysContentTouches = NO;
    
    self.tableView.rowHeight = 58.0f;
    
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNewServer)];
    
    [self displayViewControllerForServer:nil];
}

#pragma mark - State restoration

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder {
    [super encodeRestorableStateWithCoder:coder];
    
    NSIndexPath *selectedIndex;
    if ((selectedIndex = [self.tableView indexPathForSelectedRow])) {
        DDLogInfo(@"(%@): Encoding view state as selecting server: %@", self, _servers[selectedIndex.row]);
        [coder encodeInteger:selectedIndex.row forKey:MCSelectedIndexKey];
    }
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder {
    [super decodeRestorableStateWithCoder:coder];
 
    // Get the server at the stored index and display it
    NSUInteger index = (NSUInteger)[coder decodeIntegerForKey:MCSelectedIndexKey];
    index = index < _servers.count ? index : _servers.count - 1;
    MCServer *server = _servers.count ? _servers[index] : nil;
    
    DDLogInfo(@"(%@): Decoded saved state to select server: %@", self, server);
    
    if (server) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[_servers indexOfObject:server] inSection:0];
        [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        [self displayViewControllerForServer:server];
    }
}

#pragma mark - Server operations

- (void)saveServers {
    @synchronized (self) {
        NSString *documentsDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
        NSString *serversPath = [documentsDirectory stringByAppendingPathComponent:@"Servers.plist"];
        
        NSError *error = nil;
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:_servers];
        [data writeToFile:serversPath options:NSDataWritingFileProtectionComplete error:&error]; // Always use protection
        
        if (error) {
            DDLogError(@"(%@): Error occured saving data: %@", self, error);
        } else {
            DDLogInfo(@"(%@): Successfully saved list of servers", self);
        }
    }
}

- (void)beginObservingServer:(MCServer *)server {
    DDLogInfo(@"(%@): Beginning observation on server: %@", self, server);
    [server addObserver:self forKeyPath:MCServerNameKey options:NSKeyValueObservingOptionNew context:nil];
    [server addObserver:self forKeyPath:MCServerHostnameKey options:NSKeyValueObservingOptionNew context:nil];
    [server addObserver:self forKeyPath:MCServerPasswordKey options:NSKeyValueObservingOptionNew context:nil];
    [server addObserver:self forKeyPath:MCServerPortKey options:NSKeyValueObservingOptionNew context:nil];
}

- (void)stopObservingServer:(MCServer *)server {
    DDLogInfo(@"(%@): Stopping observation on server: %@", self, server);
    [server removeObserver:self forKeyPath:MCServerNameKey];
    [server removeObserver:self forKeyPath:MCServerHostnameKey];
    [server removeObserver:self forKeyPath:MCServerPasswordKey];
    [server removeObserver:self forKeyPath:MCServerPortKey];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([_servers containsObject:object]) {
        // Reload row in table
        [self reloadRowForServer:(MCServer *)object];
        
        // Save changes
        [self saveServers];
    }
}

- (void)addNewServer {
    MCServer *server = [[MCServer alloc] init];
        
    DDLogInfo(@"(%@): Creating new server: %@", self, server);
    
    [_servers addObject:server];
    [self beginObservingServer:server];
    
    [self saveServers];
    
    // Reflect the changes in the table view, and select the new server
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[_servers indexOfObject:server] inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    [self displayViewControllerForServer:server];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _servers.count;
}

- (void)reloadRowForServer:(MCServer *)server {
    DDLogInfo(@"(%@): Reloading table view row for server: %@", self, server);
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[_servers indexOfObject:server] inSection:0];
    [self configureCell:[self.tableView cellForRowAtIndexPath:indexPath] withServer:server];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MCServerCellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MCServerCellIdentifier];
        
        MCEjectButton *ejectButton = [[MCEjectButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        [ejectButton addTarget:self action:@selector(ejectButtonPressed:event:) forControlEvents:UIControlEventTouchUpInside];
        ejectButton.accessibilityLabel = @"Disconnect";
        cell.accessoryView = ejectButton;
    }
    
    MCServer *server = _servers[indexPath.row];
    [self configureCell:cell withServer:server];
    
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell withServer:(MCServer *)server {
    cell.textLabel.text = [server displayName];
    
    MCServerDetailViewController *detailViewController = [_detailViewsCache objectForKey:server];
    cell.accessoryView.hidden = (!detailViewController || detailViewController.client.state == MCRCONClientDisconnectedState);
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        MCServer *server = _servers[indexPath.row];
        
        // Change the current view to a dummy view if the server deleted is the one currently displayed
        MCServerDetailViewController *detailViewController = [_detailViewsCache objectForKey:server];
        if ([_detailNavigationController.viewControllers containsObject:detailViewController]) {
            [self displayViewControllerForServer:nil];
        }
        
        DDLogInfo(@"(%@): Deleting server: %@", self, server);
        
        // Purge objects
        [_detailViewsCache removeObjectForKey:server];
        [self stopObservingServer:server];
        [_servers removeObject:server];
        
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
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
    
    DDLogInfo(@"(%@): Moving server from index %i to index %i", self, fromIndexPath.row, toIndexPath.row);
    
    [self saveServers];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    MCServer *server = _servers[indexPath.row];
    DDLogInfo(@"(%@): Did select row for server: %@", self, server);
    [self displayViewControllerForServer:server];
}

- (void)ejectButtonPressed:(MCEjectButton *)sender event:(id)event {
    CGPoint buttonPoint = [self.tableView convertPoint:sender.center fromView:sender.superview];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPoint];
    
    MCServer *server = _servers[indexPath.row];
    
    DDLogInfo(@"(%@): Eject button pressed on cell for server: %@", self, server);
    
    MCServerDetailViewController *detailViewController = [_detailViewsCache objectForKey:server];
    [detailViewController.client disconnect];
}

- (void)displayViewControllerForServer:(MCServer *)server {
    // Do not display a blank view controler on the same navigation stack (on iPhone)
    if (!server && [_detailNavigationController.viewControllers containsObject:self]) {
        return;
    }
    
    MCServerDetailViewController *detailViewController = [_detailViewsCache objectForKey:server];
    if (!detailViewController) {
        detailViewController = [[MCServerDetailViewController alloc] initWithServer:server];
        [_detailViewsCache setObject:detailViewController forKey:server];
    }
    
    if ([_detailNavigationController.viewControllers containsObject:self]) {
        [_detailNavigationController pushViewController:detailViewController animated:YES];
    } else {
        _detailNavigationController.viewControllers = @[detailViewController];
    }
}

@end
