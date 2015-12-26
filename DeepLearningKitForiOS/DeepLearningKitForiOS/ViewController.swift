//
//  ViewController.swift
//  memkite
//
//  Created by Amund Tveit on 13/08/15.
//  Copyright © 2015 Amund Tveit. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var deepNetwork: DeepNetwork!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        deepNetwork = DeepNetwork()
        
        var randomimage = createFloatNumbersArray(3072)
        for i in 0..<randomimage.count {
            randomimage[i] = Float(arc4random_uniform(1000))
        }
        
        let imageShape:[Float] = [1.0, 3.0, 32.0, 32.0]
        
        deepNetwork.loadJSONFile("foobar")
        deepNetwork.classify(randomimage, shape: imageShape)
        

        exit(0)
    }
}





//let imageLayer = deepNetworkBuilder.loadJSONFile("conv1")!
//let image: [Float] = imageLayer["input"] as! [Float]

