//
//  MLUsbHidDevice.h
//  USBHidWrapper
//
//  Created by Marc Liyanage on 19.06.07.
//  Copyright 2007 Marc Liyanage <http://www.entropy.ch>. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#include <IOKit/IOKitLib.h>
#include <IOKit/IOCFPlugIn.h>
#include <IOKit/usb/IOUSBLib.h>
#include <IOKit/hid/IOHIDLib.h>
#include <IOKit/hid/IOHIDKeys.h>

@interface MLUsbHidDevice : NSObject {
	io_object_t hidObject;
	IOCFPlugInInterface **plugInInterface;
	IOHIDDeviceInterface122 **hidDeviceInterface;
}

- (id)initWithHidObject:(io_object_t)hidObject;
- (void)cleanup;
- (BOOL)setElementValue:(SInt32)value forUsagePage:(UInt32)usbUsagePage usage:(UInt32)usbUsage;

+ (NSString *)version;
+ (NSMutableDictionary *)hidMatchDict;
+ (NSMutableDictionary *)matchDictForUsagePage:(UInt32)usbUsagePage usage:(UInt32)usbUsage;
+ (unsigned)countDevicesForMatchDict:(NSDictionary *)matchDict;
+ (unsigned)ioIteratorCount:(io_iterator_t)ioIterator;
+ (NSArray *)findDevicesForMatchDict:(NSDictionary *)matchDict;
+ (NSArray *)findDevicesForForUsagePage:(UInt32)usbUsagePage usage:(UInt32)usbUsage;

@end
