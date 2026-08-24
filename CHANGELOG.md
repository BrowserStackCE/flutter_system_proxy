## 0.2.1

* fix(android): replace removed jcenter() with mavenCentral() 

## 0.2.0

* Add Swift Package Manager (SPM) support for iOS.
* Prepare package for pub.dev publication (SDK constraint, CHANGELOG, .pubignore).

## 0.1.5

* Fix unmanaged runLoopSource memory issue on iOS (backward compatibility with Xcode 15).
* Upgrade Android compileSdkVersion, add namespace, update Gradle plugin version.
* Use built-in constants for ProxyDict on iOS.

## 0.1.4

* Add Xcode 16 support and fix compiler warnings.

## 0.1.3

* Add namespace in Android build.gradle.

## 0.1.2

* Fix iOS 17 proxy resolution issue.
* Fix crash when PAC file URL is invalid.

## 0.1.1

* Minor fixes and stability improvements.

## 0.1.0

* Use Android ProxySelector instead of environment variables for more reliable proxy detection.
* Use Foundation library for executing PAC scripts on iOS.
* Remove print statements; clean up code.

## 0.0.2

* Disable proxy when fetching PAC file to avoid circular dependency.
* Update example app.

## 0.0.1

* Initial release: detect system HTTP proxy on Android and iOS.