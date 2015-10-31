//
//  ViewController.swift
//  SpriteKitMixUIKit
//
//  Created by Milton Moura on 29/10/15.
//  Copyright © 2015 mgcm. All rights reserved.
//

import UIKit
import SpriteKit
import CoreMotion

class ViewController: UIViewController
{
    @IBOutlet weak var sceneView: SKView!

    let manager = CMMotionManager()
    let emitterScene = ParticleScene()

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        sceneView.showsFPS = true
        sceneView.presentScene(emitterScene, transition: SKTransition())

        if manager.deviceMotionAvailable {
            manager.deviceMotionUpdateInterval = 0.1
            manager.startDeviceMotionUpdatesToQueue(NSOperationQueue.mainQueue(), withHandler: {
                [weak self] (motionData: CMDeviceMotion?, error: NSError?) -> Void in

                self?.emitterScene.tiltParticles(motionData!.attitude.yaw * (-100))
            })
        }
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

        manager.stopDeviceMotionUpdates()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        emitterScene.startEmission()
    }
}

