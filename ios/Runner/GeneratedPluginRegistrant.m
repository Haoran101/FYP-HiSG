//
//  Generated file. Do not edit.
//

// clang-format off

#import "GeneratedPluginRegistrant.h"

#if __has_include(<augmented_reality_plugin_wikitude/WikitudePlugin.h>)
#import <augmented_reality_plugin_wikitude/WikitudePlugin.h>
#else
@import augmented_reality_plugin_wikitude;
#endif

#if __has_include(<cloud_firestore/FLTFirebaseFirestorePlugin.h>)
#import <cloud_firestore/FLTFirebaseFirestorePlugin.h>
#else
@import cloud_firestore;
#endif

#if __has_include(<firebase_auth/FLTFirebaseAuthPlugin.h>)
#import <firebase_auth/FLTFirebaseAuthPlugin.h>
#else
@import firebase_auth;
#endif

#if __has_include(<firebase_core/FLTFirebaseCorePlugin.h>)
#import <firebase_core/FLTFirebaseCorePlugin.h>
#else
@import firebase_core;
#endif

#if __has_include(<firebase_dynamic_links/FLTFirebaseDynamicLinksPlugin.h>)
#import <firebase_dynamic_links/FLTFirebaseDynamicLinksPlugin.h>
#else
@import firebase_dynamic_links;
#endif

#if __has_include(<flutter_login_facebook/FlutterLoginFacebookPlugin.h>)
#import <flutter_login_facebook/FlutterLoginFacebookPlugin.h>
#else
@import flutter_login_facebook;
#endif

#if __has_include(<google_sign_in/FLTGoogleSignInPlugin.h>)
#import <google_sign_in/FLTGoogleSignInPlugin.h>
#else
@import google_sign_in;
#endif

#if __has_include(<location/LocationPlugin.h>)
#import <location/LocationPlugin.h>
#else
@import location;
#endif

#if __has_include(<money_converter/MoneyConverterPlugin.h>)
#import <money_converter/MoneyConverterPlugin.h>
#else
@import money_converter;
#endif

#if __has_include(<path_provider_ios/FLTPathProviderPlugin.h>)
#import <path_provider_ios/FLTPathProviderPlugin.h>
#else
@import path_provider_ios;
#endif

#if __has_include(<video_player/FLTVideoPlayerPlugin.h>)
#import <video_player/FLTVideoPlayerPlugin.h>
#else
@import video_player;
#endif

#if __has_include(<wakelock/WakelockPlugin.h>)
#import <wakelock/WakelockPlugin.h>
#else
@import wakelock;
#endif

#if __has_include(<webview_flutter_wkwebview/FLTWebViewFlutterPlugin.h>)
#import <webview_flutter_wkwebview/FLTWebViewFlutterPlugin.h>
#else
@import webview_flutter_wkwebview;
#endif

@implementation GeneratedPluginRegistrant

+ (void)registerWithRegistry:(NSObject<FlutterPluginRegistry>*)registry {
  [WikitudePlugin registerWithRegistrar:[registry registrarForPlugin:@"WikitudePlugin"]];
  [FLTFirebaseFirestorePlugin registerWithRegistrar:[registry registrarForPlugin:@"FLTFirebaseFirestorePlugin"]];
  [FLTFirebaseAuthPlugin registerWithRegistrar:[registry registrarForPlugin:@"FLTFirebaseAuthPlugin"]];
  [FLTFirebaseCorePlugin registerWithRegistrar:[registry registrarForPlugin:@"FLTFirebaseCorePlugin"]];
  [FLTFirebaseDynamicLinksPlugin registerWithRegistrar:[registry registrarForPlugin:@"FLTFirebaseDynamicLinksPlugin"]];
  [FlutterLoginFacebookPlugin registerWithRegistrar:[registry registrarForPlugin:@"FlutterLoginFacebookPlugin"]];
  [FLTGoogleSignInPlugin registerWithRegistrar:[registry registrarForPlugin:@"FLTGoogleSignInPlugin"]];
  [LocationPlugin registerWithRegistrar:[registry registrarForPlugin:@"LocationPlugin"]];
  [MoneyConverterPlugin registerWithRegistrar:[registry registrarForPlugin:@"MoneyConverterPlugin"]];
  [FLTPathProviderPlugin registerWithRegistrar:[registry registrarForPlugin:@"FLTPathProviderPlugin"]];
  [FLTVideoPlayerPlugin registerWithRegistrar:[registry registrarForPlugin:@"FLTVideoPlayerPlugin"]];
  [WakelockPlugin registerWithRegistrar:[registry registrarForPlugin:@"WakelockPlugin"]];
  [FLTWebViewFlutterPlugin registerWithRegistrar:[registry registrarForPlugin:@"FLTWebViewFlutterPlugin"]];
}

@end
