#import "FastMvvmPlugin.h"
#if __has_include(<fast_mvvm/fast_mvvm-Swift.h>)
#import <fast_mvvm/fast_mvvm-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "fast_mvvm-Swift.h"
#endif

@implementation FastMvvmPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFastMvvmPlugin registerWithRegistrar:registrar];
}
@end
