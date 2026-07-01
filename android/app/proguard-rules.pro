-dontwarn com.stripe.android.pushProvisioning.**
-keep class com.stripe.android.pushProvisioning.** { *; }
-keep interface com.stripe.android.pushProvisioning.** { *; }

# General Stripe rules just in case
-dontwarn com.stripe.**
-keep class com.stripe.** { *; }

# React Native Stripe SDK (used by flutter_stripe under the hood)
-dontwarn com.reactnativestripesdk.**
-keep class com.reactnativestripesdk.** { *; }
