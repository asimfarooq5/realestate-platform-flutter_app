# arcore_flutter_plus (Tape Measure tool) bundles Sceneform, which
# references optional animation/asset-loading classes and a desugar
# runtime helper that aren't actually present at runtime. Our usage
# (plane hit-testing + simple sphere markers) never touches that code
# path, so it's safe to tell R8 not to fail when it can't resolve them.
-dontwarn com.google.ar.sceneform.**
-dontwarn com.google.devtools.build.android.desugar.runtime.**
-keep class com.google.ar.core.** { *; }
-keep class com.google.ar.sceneform.** { *; }
