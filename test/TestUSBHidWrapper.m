//
//  TestUSBHidWrapper.m
//  USBHidWrapper
//
//  Created by Marc Liyanage on 25.06.07.
//  Copyright 2007 Marc Liyanage <http://www.entropy.ch>. All rights reserved.
//

#import "TestUSBHidWrapper.h"

@implementation TestUSBHidWrapper


- (void)setUp {
//	device = [[MLUsbHidDevice alloc] init];
//	STAssertNotNil(device, @"get instance");
}


- (void)tearDown {
//	[device release];
//	device = nil;
}


- (void)testVersion {
	NSString *version = [MLUsbHidDevice version];
	NSLog(@"version %@", version);
	STAssertNotNil(version, @"get version string not nil");
	STAssertEqualObjects(@"1.1", version, @"version string content");
}


- (void)testHidMatchDict {
	NSMutableDictionary *matchDict = [MLUsbHidDevice hidMatchDict];
	STAssertNotNil(matchDict, @"HID match dict");
	STAssertEquals([matchDict count], (unsigned)1, nil);
}


- (void)testUsagePageMatchDict {
	NSMutableDictionary *matchDict = [MLUsbHidDevice matchDictForUsagePage:0x01 usage:0x06];
	STAssertNotNil(matchDict, @"empty match dict");
	STAssertEquals([matchDict count], (unsigned)3, nil);
	STAssertEquals([matchDict retainCount], (unsigned)1, nil);
}


- (void)testCountDevices {
	NSMutableDictionary *matchDict = [MLUsbHidDevice matchDictForUsagePage:0x01 usage:0x06];
	STAssertTrue([MLUsbHidDevice countDevicesForMatchDict:matchDict] > 0, @"count devices");
}


- (void)testFindDevices {
	NSMutableDictionary *matchDict = [MLUsbHidDevice matchDictForUsagePage:0x01 usage:0x06];
	NSArray *devices = [MLUsbHidDevice findDevicesForMatchDict:matchDict];
	STAssertNotNil(devices, nil);
	STAssertTrue([devices count] > 0, @"count devices");
}


- (void)testInitNoObjectId {
	id test = [[MLUsbHidDevice alloc] initWithHidObject:(io_object_t)0];
	STAssertNil(test, nil);
}


- (void)testInitBogusObjectId {
	id test = [[MLUsbHidDevice alloc] initWithHidObject:(io_object_t)999];
	STAssertNil(test, nil);
}


- (void)testSetElementValue1 {
	NSMutableDictionary *matchDict = [MLUsbHidDevice matchDictForUsagePage:0x01 usage:0x06];
	NSArray *devices = [MLUsbHidDevice findDevicesForMatchDict:matchDict];
	STAssertNotNil(devices, nil);
	STAssertTrue([devices count] > 0, @"count devices");
	id myDevice = [devices objectAtIndex:[devices count] - 1];
	BOOL result = [myDevice setElementValue:1 forUsagePage:8 usage:2];
	STAssertTrue(result, nil);
}

- (void)testSetElementValue2 {
	NSMutableDictionary *matchDict = [MLUsbHidDevice matchDictForUsagePage:0x01 usage:0x06];
	NSArray *devices = [MLUsbHidDevice findDevicesForMatchDict:matchDict];
	STAssertNotNil(devices, nil);
	STAssertTrue([devices count] > 0, @"count devices");
	id myDevice = [devices objectAtIndex:[devices count] - 1];
	BOOL result = [myDevice setElementValue:0 forUsagePage:8 usage:2];
	STAssertTrue(result, nil);
}


- (void)testSetElementValue3 {
	NSArray *devices = [MLUsbHidDevice findDevicesForForUsagePage:0x01 usage:0x06];
	STAssertNotNil(devices, nil);
	STAssertTrue([devices count] > 0, @"count devices");
	id myDevice = [devices objectAtIndex:[devices count] - 1];
	BOOL result = [myDevice setElementValue:1 forUsagePage:8 usage:2];
	STAssertTrue(result, nil);
}




@end

