//
//  ViewController.m
//  额温枪
//
//  Created by hu on 2018/4/10.
//  Copyright © 2018年 huweihong. All rights reserved.
//

#import "ViewController.h"
#import "TempViewController.h"
#import "CHCentralManager.h"

@interface ViewController ()<CHCentralManagerDelegate>
@property (nonatomic, strong)CHCentralManager * manager;
@end

@implementation ViewController

- (void)viewDidLoad {

    [super viewDidLoad];

    UIButton * button = [[UIButton alloc]initWithFrame:CGRectMake(100, 100, 100, 100)];
    [button setTitle:@"扫描" forState:0];
    button.backgroundColor =[UIColor redColor];
    [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];

    if (!self.manager) {
        self.manager = [CHCentralManager shareManager];
    }
    self.manager.delegate = self;

    
}
- (void)buttonClick:(UIButton *)sender{
    [self.manager Scan];
}

- (void)discoverPeripheral:(CBPeripheral *)peripheral{

    if ([peripheral.name hasPrefix:@"CosbeautySS"]) {
        [self.manager connect:peripheral];
    }
}
- (void)connectPeripheral:(CBPeripheral *)peripheral{

    TempViewController * temp = [[TempViewController alloc]init];
    [self.navigationController pushViewController:temp animated:YES];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
