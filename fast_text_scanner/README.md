# fast_text_scanner

This is a fork of https://github.com/redflag/fast_text_scanner

See the README.md of the forked repo for the detailed description.

Please, add the following code to your application manifest (tag `application`)

```
     <meta-data
             android:name="com.google.mlkit.vision.DEPENDENCIES"
             android:value="ocr"/>
```

## Updates

1. Readme simplified.
2. Image inversion supported for Android,
   thus adding inverted data matrix barcode support for Android.
   (iOS support of this barcode type is already present.)
3. Text recognition supported
