# GLKitExtended

Apple's excellent GLKit.framework makes working with OpenGL much easier on iOS and OS X. However, there is a *lot* missing - this library aims to add the missing bits.

(it also fixes some MAJOR bugs that Apple has left unfixed for the last few years, and/or refused to fix when we submitted bug reports)

## Usage

This library is the side-effect of a series of blog posts aimed at beginners, who've never used OpenGL or GL ES before. Those posts are the primary reference / documentation:

1. Part1: http://t-machine.org/index.php/2013/08/29/glkit-to-the-max-opengl-es-2-0-for-ios-part-1-features/
1. Part2: http://t-machine.org/index.php/2013/09/08/opengl-es-2-basic-drawing/
1. Part3: http://t-machine.org/index.php/2013/10/05/ios-open-gl-es-2-shaders-and-geometry/
1. Part4: http://t-machine.org/index.php/2013/10/18/ios-open-gl-es-2-multiple-objects-at-once/
1. Part5: http://t-machine.org/index.php/2013/11/29/opengl-es2-textures-1-of-3-texturing-triangles-using-shaders/

## Library

This project has two sub-folders, one for the "pure" library, and the other for the "demo iPhone/iPad app" that lets you test the library with simple code.

* GLKX-Demo -- stand-alone demo for iOS
* GLKX-Library -- stand-alone Static Library project

### Re-compiling/building the Library

Apple broke Static Libraries twice - once in Xcode 3, and again in Xcode 4.4. Apple admits this publicly, but so far refuses to fix it. So, we're using the standard workaround from this StackOverflow answer:

http://stackoverflow.com/questions/3520977/build-fat-static-library-device-simulator-using-xcode-and-sdk-4

If you've never used it before, a couple of things to note:

1. When you re-build the library, it AUTOMATICALLY builds both "simulator", "device" and "new devices" (64bit etc), all at once.
1. There is ONLY ONE lib*.a file - it contains everything (Apple used to do this for you until Xcode 3.x)
1. The header files are AUTOMATICALLY output into the subfolder "usr/local/include" (Apple used to do this until Xcode 4.4)
1. To be safe, the script outputs all builds to "Debug-Universal" or "Release-Universal" instead of "Debug-Device"/"Debug-Simulator"/etc. Make sure you grab the right copy.
1. After you've built the library, right click the Product, find it in Finder, go up one folder, find the "*-Universal" folder (which has the final output), and drag/drop that into your App project, overwriting what was there before.


## Questions / Comments

Best on twitter : @t_machine_org

Alternatively : comment directly on the above blog posts (you'll get an answer quickly).

## License

Everything here is MIT. All code and assets are Copyright Adam Martin (so that I can legally declare "everything here is MIT". Copyright law is strange)

## Contributions

If you submit a pull-request to this repository, you surrender your Copyrights for that code to Adam Martin, and warrant that you own what you've submitted. (this is so to prevent legal problems for everyone who uses the library)