//
//  ParticleScene.swift
//  SpriteKitMixUIKit
//
//  Created by Milton Moura on 29/10/15.
//  Copyright © 2015 mgcm. All rights reserved.
//

import Foundation
import SpriteKit

class ParticleScene : SKScene
{
    private var emitter: SKEmitterNode!
    private var presentingView: SKView!

    override func didMoveToView(view: SKView) {
        scaleMode = .ResizeFill

        if let color = view.backgroundColor {
            backgroundColor = color
        }

        if let filter = CIFilter(name: "CIVignetteEffect") {
            filter.setDefaults()
            filter.setValue(CIVector(CGPoint: view.center), forKey: "inputCenter")
            filter.setValue(view.frame.size.width, forKey: "inputRadius")

            self.filter = filter
            self.shouldEnableEffects = true
        }

        presentingView = view
    }

    func startEmission() {
        emitter = SKEmitterNode(fileNamed: "Snow.sks")
        emitter.particlePositionRange = CGVectorMake(presentingView.bounds.size.width, 0)
        emitter.position = CGPointMake(presentingView.center.x, presentingView.bounds.size.height)
        emitter.targetNode = self

        addChild(emitter)
    }

    func tiltParticles(rotation: Double) {
        emitter.xAcceleration = CGFloat(rotation)
    }
}