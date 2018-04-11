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

    }
    return self;
}
-(void)sendMessage:(NSData *)data
{
    if (self.discovedPeripheral) {
        if (_writeCharacter) {
            [self.discovedPeripheral writeValue:data forCharacteristic:_writeCharacter type:CBCharacteristicWriteWithoutResponse];
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
//链接失败
-(void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
//    if ([peripheral.name hasPrefix:@"CosbeautySS"]) {
//        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"Connected1"];
//    }
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


    if ([peripheral.name hasPrefix:@"CosbeautySS"]) {
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"Connected3"];
    }
    if (self.delegate &&[self.delegate respondsToSelector:@selector(disconnectPeripheral:)]) {
        [self.delegate disconnectPeripheral:peripheral];
    }
}

//已搜索到Characteristics
-(void) peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error{

    for (CBCharacteristic * c in service.characteristics) {
        //非常重要没有这句话无法调用下面的代理方法
        [peripheral setNotifyValue:YES forCharacteristic:c];
        _writeCharacter = c;
        self.discovedPeripheral = peripheral;

        //发送时间
        NSString * timeStr = [NSString stringWithFormat:@"FEFD%@1A0D0A",[Instruction getNowDateString]];
        [peripheral writeValue:[Tool dataForHexString:timeStr] forCharacteristic:c type:CBCharacteristicWriteWithResponse];

        
    }

    //此代理方法就是为了打印东西
    if (self.delegate && [self.delegate respondsToSelector:@selector(peripheral:discoverCharacteristicsForService:)]) {
        [self.delegate peripheral:peripheral discoverCharacteristicsForService:service];
    }
}
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{

    NSLog(@"************ %@",characteristic);
    NSLog(@"------------ %@",characteristic.value);
    //电量和历史数据的刷新
    if (characteristic.value != nil) {

        NSData *data = [NSData dataWithData:characteristic.value];
        NSData *instructData = [data subdataWithRange:NSMakeRange(10, 1)];
        Byte * instructByte =(Byte *) [instructData bytes];

        if (*instructByte == NormalElectric) {

        }else if (*instructByte == LowerElectric){

        }else if(*instructByte == NOElectric){

        }else if (*instructByte == NormalTemp){

        }else if (*instructByte == LowerTemp){

        }else if (*instructByte == NaturalHigher){

        }else if(*instructByte == NaturalLower){

        }else if (*instructByte ==errorMsg){

        }else if (*instructByte == UnitRight){

        }else if(*instructByte == UnitCorrect){

        }else if (*instructByte == DataError){

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

}
@end
