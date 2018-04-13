//
//  CHCentralManager.m
//  额温枪
//
//  Created by hu on 2018/4/10.
//  Copyright © 2018年 huweihong. All rights reserved.
//

#import "CHCentralManager.h"


static CHCentralManager *manager = nil;
static int i = 0;


@implementation CHCentralManager

+ (instancetype)shareManager{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[CHCentralManager alloc] init];
    });
    return manager;
}
- (instancetype)init{
    if (self = [super init]) {

        self.centralManager = [[CBCentralManager alloc]initWithDelegate:self queue:nil];
        self.nDevices = [[NSMutableArray alloc]init];
        self.histroryArray = [[NSMutableArray alloc]init];

    }
    return self;
}
-(void)sendMessage:(NSData *)data
{
    if (self.discovedPeripheral) {
        if (_writeCharacter) {
            [self.discovedPeripheral writeValue:data forCharacteristic:_writeCharacter type:CBCharacteristicWriteWithResponse];
        }
    }
}
-(void)Scan
{
    [self clearDevices];
    [self.centralManager scanForPeripheralsWithServices:nil options:@{CBCentralManagerScanOptionAllowDuplicatesKey : @YES }];
    double delayInSeconds = 4.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self stopScan];
    });
}
-(CBUUID*)createUUID:(int)uuid{
    UInt16 temp = uuid << 8;
    temp |= (uuid >> 8);
    NSData *sd = [[NSData alloc] initWithBytes:(char *)&temp length:2];
    CBUUID *su = [CBUUID UUIDWithData:sd];
    return su ;
}
-(void)clearDevices
{
    i = 0;
    if (self.nDevices.count) {
        [self.nDevices removeAllObjects];
    }
}
-(void)stopScan
{
    [self.centralManager stopScan];
    if (self.delegate && [self.delegate respondsToSelector:@selector(stopScanPeripheral)]) {
        [self.delegate stopScanPeripheral];
    }
}
//链接设备
-(void)connect:(CBPeripheral *)peripheral{
    if (peripheral) {
        [self.centralManager connectPeripheral:peripheral options:nil];
    }
}
//断开设备
-(void)cancel:(CBPeripheral *)peripheral
{
    if (peripheral) {

        if (peripheral.services!=nil) {
            for (CBService*server in peripheral.services) {

                if (server.characteristics!=nil) {
                    for (CBCharacteristic*chatacter in server.characteristics) {
                        //查看是否订阅了
                        [peripheral setNotifyValue:NO forCharacteristic:chatacter];

                    }
                }
            }
        }
        //如果我们连接了，但是没有订阅，就断开连接即可
        [self.centralManager cancelPeripheralConnection:peripheral];
    }

}

//检查蓝牙的状态
-(void)centralManagerDidUpdateState:(CBCentralManager *)central
{

    switch (central.state) {
        case CBCentralManagerStatePoweredOn:
            [self Scan];
            break;
        case CBCentralManagerStatePoweredOff:
            break;
        default:
            break;
    }
}
//扫描设备
-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI
{

    if ([peripheral.name hasPrefix:HeaderName]) {
        NSLog(@"=======%@",peripheral);
        NSLog(@"&&&&&&&%@",advertisementData);
    }
    BOOL replace = NO;
    // Match if we have this device from before
    for (int i=0; i < _nDevices.count; i++) {
        CBPeripheral *p = [_nDevices objectAtIndex:i];
        if ([p isEqual:peripheral]) {
            [_nDevices replaceObjectAtIndex:i withObject:peripheral];
            replace = YES;
        }
    }

    if (!replace) {
            [_nDevices addObject:peripheral];
            if (self.delegate &&[self.delegate respondsToSelector:@selector(discoverPeripheral:)]) {
                [self.delegate discoverPeripheral:peripheral];
            }
        }
}

//连接成功
-(void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"1111111连接成功");
    //这里可以进行名字的筛选

    if ([peripheral.name hasPrefix:@"CosbeautySS"]) {
    }

    self.discovedPeripheral = peripheral;
    if (self.delegate && [self.delegate respondsToSelector:@selector(connectPeripheral:)]) {
        [self.delegate connectPeripheral:peripheral];
    }

    [peripheral setDelegate:self];
    [peripheral discoverServices:nil];

}
//连接失败
-(void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"1111111连接失败");

    //为了打印连接失败信息
    if (self.delegate &&[self.delegate respondsToSelector:@selector(failToConnectPeripheral:)]) {
        [self.delegate failToConnectPeripheral:peripheral];
    }
}

-(void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error{

    for (CBService *s in peripheral.services) {
        [peripheral discoverCharacteristics:nil forService:s];
    }

    //此代理方法就是为了打印东西
    if (self.delegate &&[self.delegate respondsToSelector:@selector(discoverServices:)]) {
        [self.delegate discoverServices:peripheral];
    }

}
//断开设备
-(void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{

    NSLog(@"1111111蓝牙断开");
    if (self.delegate &&[self.delegate respondsToSelector:@selector(disconnectPeripheral:)]) {
        [self.delegate disconnectPeripheral:peripheral];
    }
}

//已搜索到Characteristics
-(void) peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error{

    NSLog(@"%@",service.characteristics);
    for (CBCharacteristic * c in service.characteristics) {
        NSLog(@"UUID-----%@",[c.UUID.UUIDString uppercaseString]);
        if ([[c.UUID.UUIDString uppercaseString] isEqualToString: Observe_UUID]) {
            //非常重要没有这句话无法调用下面的代理方法
            [peripheral setNotifyValue:YES forCharacteristic:c];
        }

        if ([[c.UUID.UUIDString uppercaseString] isEqualToString: Write_UUID]) {

            _writeCharacter = c;

            //设置单位
            NSString * timeStr = [NSString stringWithFormat:@"FEFD%@1A0D0A",[CHInstruction getNowDateString]];
            NSLog(@"上传时间字符串=====%@",timeStr);


            [peripheral writeValue:[Tool dataForHexString:timeStr] forCharacteristic:c type:CBCharacteristicWriteWithResponse];
        }


    }
    //此代理方法就是为了打印东西
    if (self.delegate && [self.delegate respondsToSelector:@selector(peripheral:discoverCharacteristicsForService:)]) {
        [self.delegate peripheral:peripheral discoverCharacteristicsForService:service];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{

//    NSLog(@"11************ %@",characteristic);
//    NSLog(@"11------------ %@",characteristic.value);

    NSLog(@"************ %@",characteristic);
    NSLog(@"------------ %@",characteristic.value);

    if (characteristic.value != nil&& characteristic.value.length > 12) {

        NSData *data = [NSData dataWithData:characteristic.value];
        NSData *instructData = [data subdataWithRange:NSMakeRange(10, 1)];
        Byte * instructByte =(Byte *) [instructData bytes];

        if (*instructByte == HistoryNum) {

            NSLog(@"历史数据包数");
            self.histroryNum = [CHInstruction getHistroyNum:[data subdataWithRange:NSMakeRange(8, 2)]];

        }else if (*instructByte == NormalElectric ||*instructByte == LowerElectric) {

            if (*instructByte == NormalElectric) {
                NSLog(@"电压正常");

            }else{

                NSLog(@"电压过低");

            }
            NSData * timeData = [data subdataWithRange:NSMakeRange(2, 7)];
            NSData * tempData = [data subdataWithRange:NSMakeRange(8, 2)];

            NSLog(@"time:%@--temp:%@",[CHInstruction timeAnalyse:timeData],[CHInstruction tempAnalyse:tempData]);

            if (self.histroryNum) {

                NSString * dataStr =[NSString stringWithFormat:@"%@-%@",[CHInstruction timeAnalyse:timeData],[CHInstruction tempAnalyse:tempData]];
                NSLog(@"历史数据 time:%@--temp:%@",[CHInstruction timeAnalyse:timeData],[CHInstruction tempAnalyse:tempData]);
                [self.histroryArray addObject:dataStr];

                if (self.histroryArray.count == self.histroryNum) {

                    NSLog(@"应答指令--%@",[Tool dataForHexString:[NSString stringWithFormat:@"FEFD%@5A0D0A",[CHInstruction getNowDateString]]]);
                    [self sendMessage:[Tool dataForHexString:[NSString stringWithFormat:@"FEFD%@5A0D0A",[CHInstruction getNowDateString]]]];
                    self.histroryNum = 0;
                }

            }else{


                NSLog(@"测量数据 time:%@--temp:%@",[CHInstruction timeAnalyse:timeData],[CHInstruction tempAnalyse:tempData]);
            }

        }else if(*instructByte == NOElectric){

            NSLog(@"没电");

        }else if(*instructByte == LowerTemp){

             NSLog(@"温度过低");

        }else if (*instructByte == NormalTemp){


            NSLog(@"温度正常");



        }else if (*instructByte == NaturalHigher){
            NSLog(@"环境温度过高");

        }else if(*instructByte == NaturalLower){

            NSLog(@"环境温度过低");
        }else if (*instructByte ==errorMsg){
            NSLog(@"硬件错误");

        }else if (*instructByte == UnitRight){

            NSLog(@"单位设置成功");

        }else if(*instructByte == UnitCorrect){

            NSLog(@"单位设置失败");
        }else if (*instructByte == DataError){

            NSLog(@"指令错误");

        }
        //        NSLog(@"\\\\\\\\\\\\\\\\\\\%@",characteristic.value);
        //有用传出去特征值
        if (self.delegate &&[self.delegate respondsToSelector:@selector(peripheral:updateValueForCharacteristic:)]) {
            [self.delegate peripheral:peripheral updateValueForCharacteristic:characteristic];
        }
    }

}
//中心读取外设实时数据
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{

    [peripheral readValueForCharacteristic:characteristic];

}
@end
