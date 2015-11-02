#Taking advantage of SpriteKit in Cocoa Touch

##Introduction

Since Apple announced [SpriteKit](https://developer.apple.com/spritekit/) at WWDC 2013, along with iOS 7, it has been promoted as a framework for building 2D games with high-performance graphics and engaging gameplay. But, as I will show you in this article, by taking advantage of some of it's features in your UIKit-based application, you'll be able to add some nice visual effects to your user interface without pulling too much muscle. We will use the latest stable Swift version, along with Xcode 7.1 for our code examples. All the code in this article can be found in [this github repository](https://github.com/mgcm/SpriteKitMixUIKit).

##SpriteKit's infrastructure

SpriteKit provides an API for manipulating textured images (sprites), including animations, applying image filters, with optional physics simulation and sound playback. Although Cocoa Touch also provides other frameworks for these things, like Core Animation, UIDynamics and AV Foundation, SpriteKit is especially optimized for doing these operations in batch and performs them on a lower lever, transforming all graphics operations directly into OpenGL commands.

The top-level user interface object for SpriteKit are SKView's, that can be added to any application view controller, and then are used to present scene objects, of type SKScene, composed of possibly multiple nodes with content, that will render seamlessly with other layers or views that might  also be contained in the application's current view hierarchy.

This allows us to add smooth and optimized graphical effects to our application UI,  enriching the user experience and keeping our refresh rate at 60hz.

##Our sample project

To show how to combine typical UIKit controls with SpriteKit, we'll build a sample login screen, composed of UITextFields, UIButtons and UILabels, for our wonderful new WINTER APP. But instead of a boring, static background, we'll add an animated particle effect to simulate falling snow and apply a [Core Image](https://developer.apple.com/library/mac/documentation/GraphicsImaging/Reference/CoreImageFilterReference/index.html) vignette filter to mask them under a niffy spotlight-type effect.

![](https://raw.githubusercontent.com/mgcm/SpriteKitMixUIKit/master/Screenshots/SampleMovie.gif)

###1. Creating the view hierarchy

We'll start with a brand new Swift Xcode project, selecting the iOS > Single View Application template and opening the Main Storyboard. 

![](https://raw.githubusercontent.com/mgcm/SpriteKitMixUIKit/master/Screenshots/%231.png)

In the existing View Controller Scene, we add a new UIView that anchors to it's parent view's sides, top and bottom and change it's class from the default UIView to SKView. Also make sure the background color for this view is dark, so that the particles that we'll add later have a nice contrast.

![](https://raw.githubusercontent.com/mgcm/SpriteKitMixUIKit/master/Screenshots/%232.png)

Now, we'll add a few UITextFields, UILabels and UIButtons to replicate the following login screen. Also, we need an IBOutlet to our SKView. Let's call it sceneView. This is the SpriteKit view where we will add the [SKScene](https://developer.apple.com/library/ios/documentation/SpriteKit/Reference/SKScene_Ref/) with the particle and image filter effect.

![](https://raw.githubusercontent.com/mgcm/SpriteKitMixUIKit/master/Screenshots/%233.png)

###2. Adding a Core Image filter

We're done with UIKit for now. We currently have a fully (well, not really) functional login screen and it's now time to make it more dynamic. The first thing we need is a scene, so we'll add a new Swift class called [ParticleScene](https://github.com/mgcm/SpriteKitMixUIKit/blob/master/SpriteKitMixUIKit/ParticleScene.swift).

In order to use SpriteKit's objects, let's not forget to add an import statement for that and declare that our class is an SKScene.

		import SpriteKit

		class ParticleScene : SKScene
		{
			...
		}

The way we initialize a scene in SpriteKit is by overriding the `didMoveToView(_:)` method, which is called when a scene is added to an SKView. So let's do that and setup the Core Image filter. If you are not familiar with Core Image, it is a powerful image processing framework that provides over 90 filters that can be applied in real time to images, videos and, coincidentally, to SpriteKit nodes, of type [SKNode](https://developer.apple.com/library/prerelease/tvos/documentation/SpriteKit/Reference/SKNode_Ref/index.html). An SKNode is the basic unit of content in SpriteKit and our SKScene is one big node for rendering. Actually, SKScene is an [SKEffectNode](https://developer.apple.com/library/ios/documentation/SpriteKit/Reference/SKEffectNode_Ref/index.html#//apple_ref/swift/cl/c:objc(cs)SKEffectNode), which is a special type of node that allows its content to be post processed using Core Image filters. In the following snippet, we add a [CIVignetteEffect](https://developer.apple.com/library/mac/documentation/GraphicsImaging/Reference/CoreImageFilterReference/index.html#//apple_ref/doc/filter/ci/CIVignette) filter centered on our scene and with a radius equal to the width of our view frame:

		override func didMoveToView(view: SKView) {
			scaleMode = .ResizeFill
			
			// initialize the Core Image filter
			if let filter = CIFilter(name: "CIVignetteEffect") {
				// set the default input parameter values
            		filter.setDefaults()
				// make the vignette center be the center of the view
            		filter.setValue(CIVector(CGPoint: view.center), forKey: "inputCenter")
				// set the radius to be equal to the view width
            		filter.setValue(view.frame.size.width, forKey: "inputRadius")

				// apply the filter to the current scene
            		self.filter = filter
            		self.shouldEnableEffects = true
        		}

        		presentingView = view
    		}

If you run the application as is, you'll notice a nice spotlight effect behind our login form. But we're not done yet.

![](https://raw.githubusercontent.com/mgcm/SpriteKitMixUIKit/master/Screenshots/%234.png)

###3. Adding a particle system

Since this is a WINTER APP, let's add some falling snow flakes in the background. Add a new SpriteKit Particle File to the project and select the Snow template. Next, we add a method to setup our particle node emitter, an SKEmitterNode, that hides all the complexity of a particle system:

		func startEmission() {
			// load the snow template from the app bundle
			emitter = SKEmitterNode(fileNamed: "Snow.sks")
			// emit particles from the top of the view
			emitter.particlePositionRange = CGVectorMake(presentingView.bounds.size.width, 0)
			emitter.position = CGPointMake(presentingView.center.x, presentingView.bounds.size.height)
			emitter.targetNode = self

			// add the emitter to the scene
			addChild(emitter)
    }

9. To finish things off, let's create a new property to hold our particle scene in the [ViewController](https://github.com/mgcm/SpriteKitMixUIKit/blob/master/SpriteKitMixUIKit/ViewController.swift) and start the particle in the `viewDidAppear()` method: 

		class ViewController: UIViewController
		{
			...
			let emitterScene = ParticleScene()
			...

			override func viewDidAppear(animated: Bool) {
				super.viewDidAppear(animated)
				emitterScene.startEmission()
			}
		}

And we're done! We now have a nice UIKit login form with an animated background that is much more compelling than a simple background color, gradient or texture.

##Where to go from here

You can explore more Core Image filters to add stunning effects to your UI but be warned that some are not prepared for real-time, full-frame rendering. Indeed, SpriteKit is very powerful and you can even use OpenGL shaders in nodes and particles. 

You are welcome to checkout the [source code for this article](https://github.com/mgcm/SpriteKitMixUIKit) and you'll see that it has a little extra [Core Motion](https://developer.apple.com/library/ios/documentation/CoreMotion/Reference/CoreMotion_Reference/) trick, that shifts the direction of the falling snow according to the position of your device.