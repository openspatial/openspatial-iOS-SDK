# Open Spatial SDK for iOS

[Open Spatial](http://openspatial.net) SDK for iOS contains:

| Components            | Notes
| :---------            | :----
| SDK Sources           | Sources for Open Spatial SDK APIs
| OpenSpatial.framework | Used to build applications against the APIs, added for convenience
| Example App           | Demostrates how to use the APIs to register and log events

The source files needed to build the OpenSpatial.framework are in the Open Spatial iOS Framework folder

#### License
The SDK is distributed under Apache2.0 license (see LICENSE.md).

#### How to Use?
1. Open the xCode project for which you would like to add the OpenSpatial framework
2. Navigate to the project navigator
3. Select the specific target in the project editor menu
4. Go to Embedded Binaries and add the OpenSpatial.framework file that is found in the root of the OpenSpatial iOS Framework directory
5. Be sure that when adding the OpenSpatial.framework file, that you select the option to copy it into your project directory
5. In the header of the file for which you would like to use the Nod device, type #import <OpenSpatial/OpenSpatialBluetooth.h>

Please vist out [Developer Portal](http://developer.nod.com) for more detailed instructions and tutorials.

#### Examples
Importing OpenSpatial into header file
- At the top of the header file, type the below.
```objective-c
#import <OpenSpatial/OpenSpatialBluetooth.h>
```
Subscribes the specified peripheral device to RelativeXY events
```objective-c
[self.HIDServ subscribeToEvents:name forEventTypes:[[NSMutableArray alloc] initWithObjects:@(OS_RELATIVE_XY_TAG), nil]];
```
Subscribes the specific peripheral device to RelativeXY and Euler Angle events
```objective-c
[self.HIDServ subscribeToEvents:name forEventTypes:[[NSMutableArray alloc] initWithObjects:@(OS_RELATIVE_XY_TAG), @(OS_EULER_ANGLES_TAG), nil]];
```
Unsubscribes the specified peripheral device to RelativeXY events
```objective-c
[self.HIDServ unsubscribeFromEvents:(NSString *)peripheralName forEventTypes:[[NSMutableArray alloc] initWithObjects:@(OS_RELATIVE_XY_TAG), nil]];
```

#### List of OpenSpatial Data Types
Accelerometer
```objective-c
OS_RAW_ACCELEROMETER_TAG
```
Gyro
```objective-c
OS_RAW_GYRO_TAG
```
Compass
```objective-c
OS_RAW_COMPASS_TAG
```
Euler Angles
```objective-c
OS_EULER_ANGLES_TAG
```
Translations
```objective-c
OS_TRANSLATIONS_TAG
```
Analog
```objective-c
OS_ANALOG_DATA_TAG
```
RelativeXY
```objective-c
OS_RELATIVE_XY_TAG
```
Gesture Direction
```objective-c
OS_DIRECTION_GESTURE_TAG
```
Slider Gesture
```objective-c
OS_SLIDER_GESTURE_TAG
```
Button
```objective-c
OS_BUTTON_EVENT_TAG
```

## Open Spatial SDK for Android

For information on Open Spatial SDK for Android see (https://github.com/openspatial/android-sdk)
