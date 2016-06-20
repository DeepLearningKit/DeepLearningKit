//
//  ViewController.swift
//  OSXDeepLearningKitApp
//
//  Created by Amund Tveit on 15/02/16.
//  Copyright © 2016 DeepLearningKit. All rights reserved.
//

import Cocoa
import DeepLearningKit

class ViewController: NSViewController {
    
    var deepNetwork: DeepNetwork!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear() {
        
        deepNetwork = DeepNetwork()
        
        // conv1.json contains a cifar 10 image of a cat
        let conv1Layer = deepNetwork.loadJSONFile("conv1")!
        let image: [Float] = conv1Layer["input"] as! [Float]
        
        
        var randomimage = createFloatNumbersArray(image.count)
        for i in 0..<randomimage.count {
            randomimage[i] = Float(arc4random_uniform(1000))
        }
        
        let imageShape:[Float] = [1.0, 3.0, 32.0, 32.0]
        
        // 0. load network in network model
        deepNetwork.loadNetworkFromJson("nin_cifar10_full")
        
        // 1. classify image (of cat)
        deepNetwork.classify(image, shape:imageShape)
        
        
        // 2. reset deep network and classify random image
        deepNetwork.loadNetworkFromJson("nin_cifar10_full")
        deepNetwork.classify(randomimage, shape:imageShape)
        
        // 3. reset deep network and classify cat image again
        deepNetwork.loadNetworkFromJson("nin_cifar10_full")
        deepNetwork.classify(image, shape:imageShape)
        
        exit(0)
    }
    
    
    override var representedObject: AnyObject? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    
}

