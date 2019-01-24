//
//  MHTableViewController.m
//  MHWebBrowser_Example
//
//  Created by Minghao Xue on 2019/1/22.
//  Copyright © 2019 薛明浩. All rights reserved.
//

#import "MHTableViewController.h"
#import "MHViewController.h"

@interface MHTestModel : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSURL *url;

@end

@implementation MHTestModel

@end

@interface MHTableViewController ()

@property (nonatomic, strong) NSArray<MHTestModel *> *dataSource;

@end

@implementation MHTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupDataSource];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
}

- (void)setupDataSource {
    NSMutableArray *temp = [NSMutableArray new];
    {
        MHTestModel *model = [MHTestModel new];
        model.title = @"JSBridge";
        model.url = [[NSBundle mainBundle] URLForResource:@"bridge" withExtension:@"html"];
        [temp addObject:model];
    }
    self.dataSource = [temp copy];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text = self.dataSource[indexPath.row].title;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    MHViewController *vc = [[MHViewController alloc] initWithURL:self.dataSource[indexPath.row].url];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
