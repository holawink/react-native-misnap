
# react-native-misnap

react-native native library as a wrappper aroud private / paid MiSnap & Misnap Liveness Android/iOS libraries.

Libraries offer automatic capture of **Front ID, Back ID & Face selfie**.

## Getting started, installing package automatically


`$ react-native link react-native-misnap`

Due the issue with pod & asset catalogs https://github.com/CocoaPods/CocoaPods/issues/8122, you need to add graphical resources into iOS project. Simply drag: `=Include-resources_in_mainproject=/ios_drag_to_xcode/react-native-misnap` folder into your xcode project root folder. All resources are graphical resources that will be bundled directy in app bundle.



### Manual Installation steps


#### iOS

1. Open ios/Podfile and insert :  `pod 'RNMisnap', :path => '../node_modules/react-native-misnap'`
2. Due the issue with pod & asset catalogs https://github.com/CocoaPods/CocoaPods/issues/8122, you need to add graphical resources into iOS project. Simply drag: `=Include-resources_in_mainproject=/ios_drag_to_xcode/react-native-misnap` folder into your xcode project root folder. All resources are graphical resources that will be bundled directy in app bundle.

#### Android

1. Open up `android/app/src/main/java/[...]/MainActivity.java`
  - Add `import com.wink.misnap.RNMisnapPackage;` to the imports at the top of the file
  - Add `new RNMisnapPackage()` to the list returned by the `getPackages()` method
2. Append the following lines to `android/settings.gradle`:
  	```
  	include ':react-native-misnap'
  	project(':react-native-misnap').projectDir = new File(rootProject.projectDir, 	'../node_modules/react-native-misnap/android')
  	```
3. Insert the following lines inside the dependencies block in `android/app/build.gradle`:
  	```
      implementation project(':react-native-misnap')
  	```


## Usage
```javascript
import MiSnapManager, { MiSnapConfig, MiSnapResult } from 'react-native-misnap';

const config: MiSnapConfig = {
    captureType: 'idFront',
    autocapture: true,
    livenessLicenseKey: 'MISNAP_LIVENESS_LICENSE_KEY',
};
	  
MiSnapManager.capture(config)
	.then((result: MiSnapResult) => {
		const capturedImage = result.base64encodedImage;
		const { metadata = {} } = result;
		// Do something with base64 encoded image string and optional metaData
    })
    .catch((error: Error) => {
        // Do something with error
    });
```
  