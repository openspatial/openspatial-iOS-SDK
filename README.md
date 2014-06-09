## Open Spatial SDK for iOS

[Open Spatial](http://openspatial.net) SDK for iOS contains:

| Components            | Notes
| :---------            | :----
| SDK Sources           | Sources for Open Spatial SDK APIs
| OpenSpatial.framework | Used to build applications against the APIs, added for convenience
| An emulator           | Generates events, e.g., button, rotation events etc., to aid in application development
| An example app        | Demostrates how to use the APIs to register and log events

The source files needed to build the OpenSpatial.framework are in the Open Spatial iOS SDK folder

#### License
The SDK is distributed under Apache2.0 license (see LICENSE.md).

#### How to run

In order to run the emulator and the example app, you will need two iOS devices. One device will run the example app, the other will run the emulator. Let's call the device running the example app the target device and the device running the emulator the source. To run the setup, follow the steps below:

1. Open the example app on the target device and open the Nod Emulator on the source device
2. Press the "Connect to Ring" button in the Example App
2. Select the Nod Emulator in the list of devices in the example app
3. Press the "Subscribe to Events' in the Example App
4. Play with buttons, tactiles, slider, etc. on the emulator app and watch for logs for events

## Open Spatial SDK for Android

For information on Open Spatial SDK for Android see (https://github.com/openspatial/android-sdk)
