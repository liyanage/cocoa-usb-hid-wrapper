//
//  TestUSBHidWrapper.h
//  USBHidWrapper
//
//  Created by Marc Liyanage on 25.06.07.
//  Copyright 2007 Marc Liyanage <http://www.entropy.ch>. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "MLUsbHidDevice.h"

@interface TestUSBHidWrapper : SenTestCase {
	MLUsbHidDevice *device;
}

@end
