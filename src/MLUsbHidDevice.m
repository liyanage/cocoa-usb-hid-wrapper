//
//  MLUsbHidDevice.m
//  USBHidWrapper
//
//  Created by Marc Liyanage on 19.06.07.
//  Copyright 2007 Marc Liyanage <http://www.entropy.ch>. All rights reserved.
//

#import "MLUsbHidDevice.h"


@implementation MLUsbHidDevice


- (id)initWithHidObject:(io_object_t)myHidObject {
		if (!(self = [super init])) return nil;

		if (!myHidObject) {
			NSLog(@"No HID object reference passed");
			[self release];
			return nil;
		}

		hidObject = myHidObject;
		IOObjectRetain(hidObject);

		SInt32 score = 0;
		IOReturn ioReturnValue = IOCreatePlugInInterfaceForService(hidObject, kIOHIDDeviceUserClientTypeID, kIOCFPlugInInterfaceID, &plugInInterface, &score);
		if (ioReturnValue != kIOReturnSuccess) {
			NSLog(@"Unable to IOCreatePlugInInterfaceForService(): %d", ioReturnValue);
			[self release];
			return nil;
		}

		CFUUIDBytes uuid = CFUUIDGetUUIDBytes(kIOHIDDeviceInterfaceID);
		HRESULT plugInResult = (*plugInInterface)->QueryInterface(plugInInterface, uuid, (LPVOID)&hidDeviceInterface);
		if (plugInResult != S_OK) {
			NSLog(@"Unable to create device interface: %d", plugInResult);
			[self release];
			return nil;
		}

		ioReturnValue = (*hidDeviceInterface)->open(hidDeviceInterface, 0);
		if (ioReturnValue != kIOReturnSuccess) {
			NSLog(@"Unable to open device interface: %d", ioReturnValue);
			[self release];
			return nil;
		}

		return self;
}



- (BOOL)setElementValue:(SInt32)value forUsagePage:(UInt32)usbUsagePage usage:(UInt32)usbUsage {
	NSArray *elements;
	NSMutableDictionary *matchDict = [NSMutableDictionary dictionary];
	[matchDict setObject:[NSNumber numberWithUnsignedInt:usbUsage] forKey:[NSString stringWithUTF8String:kIOHIDDeviceUsageKey]];
	[matchDict setObject:[NSNumber numberWithUnsignedInt:usbUsagePage] forKey:[NSString stringWithUTF8String:kIOHIDDeviceUsagePageKey]];
	IOReturn ioReturnValue = (*hidDeviceInterface)->copyMatchingElements(
		hidDeviceInterface,
		(CFDictionaryRef)matchDict,
		(CFArrayRef *)&elements
	);

	unsigned int i, count = [elements count];
	if (!count) {
		NSLog(@"no matching elements found");
		[elements release];
		return NO;
	}
//	NSLog(@"found %d matching elements", count);

	IOHIDElementCookie cookie = NULL;
	for (i = 0; i < count; i++) {
		NSObject *obj = [elements objectAtIndex:i];
		if ([[obj valueForKey:@"UsagePage"] isEqualTo:[NSNumber numberWithInt:usbUsagePage]] && [[obj valueForKey:@"Usage"] isEqualTo:[NSNumber numberWithInt:usbUsage]]) {
//			NSLog(@"obj %@", obj);
			cookie = (IOHIDElementCookie)[[obj valueForKey:@"ElementCookie"] intValue];
			break;
		}
//		NSLog(@"usage page %@/%@", [obj valueForKey:@"UsagePage"], [obj valueForKey:@"Usage"]);
	}
//	NSLog(@"cookie %d", cookie);

	IOHIDEventStruct valueEvent;
	bzero(&valueEvent, sizeof(valueEvent));
	valueEvent.value = value;

	ioReturnValue = (*hidDeviceInterface)->setElementValue(
		hidDeviceInterface,
		cookie,
		&valueEvent,
		0, NULL, NULL, NULL	
	);
	if (ioReturnValue != kIOReturnSuccess) {
		NSLog(@"setElementValue '%d' failed", value);
		return NO;
	}

	[elements release];
	return YES;
}



- (void)dealloc {
	[self cleanup];
	[super dealloc];
}


- (void)cleanup {
	if (hidDeviceInterface) {
		(*hidDeviceInterface)->Release(hidDeviceInterface);
		hidDeviceInterface = NULL;
	}

	if (plugInInterface) {
		(*plugInInterface)->Release(plugInInterface);
		plugInInterface = NULL;
	}

	if (hidObject) {
		IOObjectRelease(hidObject);
		hidObject = 0;
	}
}









+ (NSString *)version {
	Class myClass = [self class];
	return [[[NSBundle bundleForClass:myClass] infoDictionary] valueForKey:@"CFBundleVersion"];
}


+ (NSMutableDictionary *)hidMatchDict {
	NSMutableDictionary *matchDict = (NSMutableDictionary *)IOServiceMatching(kIOHIDDeviceKey);
	return [matchDict autorelease];
}


+ (NSMutableDictionary *)matchDictForUsagePage:(UInt32)usbUsagePage usage:(UInt32)usbUsage {
	NSMutableDictionary *matchDict = [self hidMatchDict];
	[matchDict setObject:[NSNumber numberWithUnsignedInt:usbUsagePage] forKey:[NSString stringWithUTF8String:kIOHIDDeviceUsagePageKey]];
	[matchDict setObject:[NSNumber numberWithUnsignedInt:usbUsage] forKey:[NSString stringWithUTF8String:kIOHIDDeviceUsageKey]];
	return matchDict;
}


+ (unsigned)countDevicesForMatchDict:(NSDictionary *)matchDict {
	io_iterator_t hidObjectIterator = 0;
	[matchDict retain];
    IOReturn ioReturnValue = IOServiceGetMatchingServices(kIOMasterPortDefault, (CFMutableDictionaryRef)matchDict, &hidObjectIterator);
    BOOL noMatchingDevices = (ioReturnValue != kIOReturnSuccess) || (!hidObjectIterator);
    if (noMatchingDevices) {
		NSLog(@"No matching devices found, IO Return Value = %d", ioReturnValue);
		return 0;
	}

	int hidDeviceCount = [self ioIteratorCount:hidObjectIterator];
	IOObjectRelease(hidObjectIterator);
	return hidDeviceCount;
}


+ (NSArray *)findDevicesForMatchDict:(NSDictionary *)matchDict {
	io_iterator_t hidObjectIterator = 0;
	[matchDict retain];
    IOReturn ioReturnValue = IOServiceGetMatchingServices(kIOMasterPortDefault, (CFMutableDictionaryRef)matchDict, &hidObjectIterator);
    BOOL noMatchingDevices = (ioReturnValue != kIOReturnSuccess) || (!hidObjectIterator);
    if (noMatchingDevices) {
		NSLog(@"No matching devices found, IO Return Value = %d", ioReturnValue);
		return nil;
	}

	int hidDeviceCount = [self ioIteratorCount:hidObjectIterator];
	if (!hidDeviceCount) {
		NSLog(@"Unable to find any matching HID devices");
		return nil;
	}

	NSMutableArray *devices = [NSMutableArray array];

	io_object_t hidDevice;
	while (hidDevice = IOIteratorNext(hidObjectIterator)) {
		id usbDevice = [[[MLUsbHidDevice alloc] initWithHidObject:hidDevice] autorelease];
		IOObjectRelease(hidDevice);
		[devices addObject:usbDevice];
	}
	
	return devices;

}


+ (NSArray *)findDevicesForForUsagePage:(UInt32)usbUsagePage usage:(UInt32)usbUsage {
	return [MLUsbHidDevice findDevicesForMatchDict:[MLUsbHidDevice matchDictForUsagePage:usbUsagePage usage:usbUsage]];
}



+ (unsigned)ioIteratorCount:(io_iterator_t)ioIterator {
	if (!ioIterator) return 0;
	int hidDeviceCount = 0;
	IOIteratorReset(ioIterator);
	
	io_object_t hidDevice;
	do {
		hidDevice = IOIteratorNext(ioIterator);
		if (hidDevice) {
			IOObjectRelease(hidDevice);
			hidDeviceCount++;
		}
	} while (hidDevice);
		
	IOIteratorReset(ioIterator);
	return hidDeviceCount;
}







@end
