//
//  TempViewController.m
//  额温枪
//
//  Created by hu on 2018/4/10.
//  Copyright © 2018年 huweihong. All rights reserved.
//

#import "TempViewController.h"
#import "CHCentralManager.h"
@interface TempViewController ()<CHCentralManagerDelegate>
@property (nonatomic, strong)CHCentralManager * manager;
@end

@implementation TempViewController


- (void)viewDidLoad {
    [super viewDidLoad];

    UIButton * button1 =  [[UIButton alloc]initWithFrame:CGRectMake(30, 100, 100, 60)];
    [button1 setTitle:@"℃" forState:0];
    button1.tag = 1;
    button1.backgroundColor = [UIColor greenColor];
    [button1 addTarget:self action:@selector(butttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button1];


    UIButton * button2 =  [[UIButton alloc]initWithFrame:CGRectMake(MainScreenWidth - 130, 100, 100, 60)];
    [button2 setTitle:@"℉" forState:0];
    button2.tag = 2;
    button2.backgroundColor = [UIColor blueColor];
    [button2 addTarget:self action:@selector(butttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button2];

    if (!self.manager) {
        self.manager = [CHCentralManager shareManager];
    }
    self.manager.delegate = self;

}
- (void)butttonClick:(UIButton *)sender{

    if (sender.tag == 1) {
        //摄氏度
        NSString * Cstring = [NSString stringWithFormat:@"FEFD%@1A0D0A",[CHInstruction getNowDateString]];
        [[CHCentralManager shareManager]sendMessage:[Tool dataForHexString:Cstring]];
    }else if(sender.tag == 2){

        //华氏度
        NSString * Fstring = [NSString stringWithFormat:@"FEFD%@150D0A",[CHInstruction getNowDateString]];
        [[CHCentralManager shareManager]sendMessage:[Tool dataForHexString:Fstring]];
        
    }
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
