//
//  MHTableViewController.m
//  MHWebBrowser_Example
//
//  Created by Minghao Xue on 2019/1/22.
//  Copyright © 2019 薛明浩. All rights reserved.
//

#import "MHTableViewController.h"
#import "MHViewController.h"

@interface MHTableViewController ()

@end

@implementation MHTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text = @"Baidu";
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    MHViewController *vc = [[MHViewController alloc] initWithURLString:@"https://www.baidu.com"];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
