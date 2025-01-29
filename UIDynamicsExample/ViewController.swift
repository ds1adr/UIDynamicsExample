//
//  ViewController.swift
//  UIDynamicsExample
//
//  Created by Wontai Ki on 1/28/25.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet var imageView: UIImageView!
    var panAnimator: UIDynamicAnimator?
    var endingAnimator: UIDynamicAnimator?
    var attachBehavior: UIAttachmentBehavior?
    var offset: UIOffset = .zero

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "UIDynamics"
        
        // Pan Gesture
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(actionPanGesture(_:)))
        imageView.addGestureRecognizer(panRecognizer)
        imageView.isUserInteractionEnabled = true
    }

    @objc
    func actionPanGesture(_ gesture: UIPanGestureRecognizer) {
        let pInView = gesture.location(in: view)
        let pInSubView = gesture.location(in: gesture.view)
        let center = CGPoint(x: (gesture.view?.bounds.size.width ?? 0) / 2, y: (gesture.view?.bounds.size.height ?? 0) / 2)
        
        let velocity = gesture.velocity(in: view)
        
        if gesture.state == .began {
            offset = UIOffset(horizontal: pInSubView.x - center.x, vertical: pInSubView.y - center.y)
        } else if gesture.state == .ended {
            
            endingAnimator = UIDynamicAnimator(referenceView: view)
            
            guard let targetView = gesture.view else { return }
            let push: UIPushBehavior = UIPushBehavior(items: [targetView], mode: .instantaneous)
            push.pushDirection = (CGVector(dx: velocity.x / 10.0, dy: velocity.y / 10.0))
            endingAnimator?.addBehavior(push)
            
            let gravity = UIGravityBehavior(items: [targetView])
            endingAnimator?.addBehavior(gravity)
            
            panAnimator = nil
        } else if gesture.state == .changed {
            guard let targetView = gesture.view else { return }
            
            if panAnimator == nil {
                panAnimator = UIDynamicAnimator(referenceView: view)
                
                let gravity = UIGravityBehavior(items: [targetView])
                panAnimator?.addBehavior(gravity)
                
                attachBehavior = UIAttachmentBehavior(item: targetView, offsetFromCenter: offset, attachedToAnchor: pInView)
                attachBehavior?.length = 0
                attachBehavior?.frequency = 0
                attachBehavior?.damping = 2
                panAnimator?.addBehavior(attachBehavior!)
            }
            
            attachBehavior?.anchorPoint = pInView
        } else if gesture.state == .cancelled {
            panAnimator = nil
            endingAnimator = nil
        }
    }
    
    @IBAction func resetAction() {
        panAnimator = nil
        endingAnimator = nil
        
        imageView.center = view.center
        imageView.transform = .identity
    }
}

