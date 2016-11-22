//
//  ViewController.m
//  DWDAppFluencyMonitor
//
//  Created by dianwoda on 16/11/22.
//  Copyright © 2016年 dianwoda. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UITableView *table = [[UITableView alloc] initWithFrame:[UIScreen mainScreen].bounds style:(UITableViewStylePlain)];
    [self.view addSubview:table];
    [table setDelegate:self];
    [table setDataSource:self];
    
    
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1000;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    NSString *cellText = nil;
    if (indexPath.row%10 == 0) {
        usleep(3000*1000);
        cellText = @"我要睡一会，等等";
    }else{
        cellText = [NSString stringWithFormat:@"cell%ld",indexPath.row];
    }
    
    cell.textLabel.text = cellText;
    return cell;
}



@end
