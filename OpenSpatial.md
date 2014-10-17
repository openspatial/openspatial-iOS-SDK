# OpenSpatial Service

Version 2014-10-03

The OpenSpatial service, designed by Nod Labs, is a Bluetooth service that uses the Low Energy transport.  It sends motion, touch and gesture data from a motion sensing device to a host device.

The information contained in this document is preliminary and subject to change.  This version of the document is a best effort intended to describe the behavior of Nod Labs evaluation firmware as of the date cited above, but may contain errors and omissions.  Later versions of an OpenSpatial specification might be in the form of an industry standard encompassing a range of implementation choices; this version describes a single implementation at a given time.

## Service UUID

The OpenSpatial Service UUID is 00000002-0000-1000-8000-a0e5e9000000

## Characteristics

Multi-byte integer data fields within characteristic values are in little-endian byte order.

All characteristics listed below are readable and notifiable.

### Characteristic: Position2D
**UUID:** 00000206-0000-1000-8000-a0e5e9000000  
**Values:** int16 **X**, int16 **Y**

Position2D reports the projection of a sensor's motion onto a virtual 2-dimensional surface.  It is intended for control of a pointer, akin to computer mouse.  X and Y are offsets from the position implied by the last Position2D report.  The mapping function from motion to that surface is nonuniform, including such aspects as "acceleration".

### Characteristic: Pose6D
**UUID:** 00000205-0000-1000-8000-a0e5e9000000  
**Values:** int16 **X**, int16 **Y**, int16 **Z**, int16 **Roll**, int16 **Pitch**, int16 **Yaw**

Pose6D reports the sensor's translation and rotation.

X, Y, and Z are translational offsets from the position implied by the last Pose6D report, in a Cartesian coordinate space with unspecified origin and scaling.  The axial orientation of that coordinate system, while not specified precisely, can generally be assumed to have the following attributes: Positive Z is up (away from the ground), positive X is away from the user, and positive Y is to the user's left.

Roll, Pitch, and Yaw are absolute angles in a (1,2,3) Euler Angle space.  The reference axes are such that Yaw is rotation about a vertical axis as defined by the Earth's gravity.  The direction where yaw=0 is unspecified, but differences in yaw over time can nevertheless be used to determine rotational changes in that plane.

The values for Roll, Pitch, and Yaw range from -pi to pi, scaled so that one radian is represented by the integer value 8192 and 0 radians is represented by 0.

Note: Libraries that provide access to this information might choose to perform an internal conversion to present the angular information in different rotational spaces, such as quaternions.

### Characteristic: ButtonEvents
**UUID:** 00000207-0000-1000-8000-a0e5e9000000  
**Values:** int16 **Buttons**

ButtonEvents reports changes in the activation state of on-off switches - touch-surfaces and tactile switches.

Each switch's state changes are reported by a pair of adjacent bits within the uint16 value.  The least-significant bit within that pair is 1 if that switch was activated since the last report, and the most-significant-bit within that pair is 1 if that switch was deactivated since the last report.  If both bits are 1, it means that the switch was touched then immediately released since the last report.

For the Nod Ring version 1, the mapping is as follows:

| Switch      | OnBit | OffBit |
|-------------|------:|-------:|
| Touch0      |     0 |      1 |
| Touch1      |     2 |      3 |
| SliderTouch |     4 |      5 |
| Tactile0    |     6 |      7 |
| Tactile1    |     8 |      9 |

### Characteristic: Gestures
**UUID:** 00000208-0000-1000-8000-a0e5e9000000  
**Values:** uint16 **Opcode**, [variable] **Data**

Gestures reports the sensor's detection of specific motion patterns that have been assigned certain meanings, as follows:

Scrolling:  **Opcode**=1.  **Data** uint8 1=scroll up, 2=scroll down

Directional gestures:  **Opcode**=2. **Data** uint8  1=right, 2=left, 3=down, 4=up, 5=clockwise, 6=counter-clockwise

### Characteristic: Motion6D
**UUID:** 00000209-0000-1000-8000-a0e5e9000000  
**Values:** int16 **AccelX**, int16 **AccelY**, int16 **AccelZ**, int16 **GyroX**, int16 **GyroY**, int16 **GyroZ**

Motion6D reports raw data from the motion sensor chip.  The XYZ coordinate system is the local coordinate system of the motion sensor chip.  The scale factor for acceleration data is such that the maximum positive 16-bit integer 32767 corresponds to 4G.  The scale factor for gyro data is such that the maximum positive 16-bit integer 32767 corresponds to 2000 degrees/second.
