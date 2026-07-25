# Flutter Rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }

# Firebase & Firestore Rules
-keep class com.google.firebase.** { *; }
-keep class com.google.firestore.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.firestore.**
