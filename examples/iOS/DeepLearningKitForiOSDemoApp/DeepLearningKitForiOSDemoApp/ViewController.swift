//
//  ViewController.swift
//  DeepLearningKitForiOSDemoApp
//

import UIKit
import DeepLearningKitForiOS

class ViewController: UIViewController {
    
    var deepNetwork: DeepNetwork!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        deepNetwork = DeepNetwork()
        
        let image = loadExampleImageFromJSONFile("conv1")
        
        let random_image = createRandomImage(image.count)
        
        let imageShape:[Float] = [1.0, 3.0, 32.0, 32.0]
        
        deepNetwork.loadNetworkFromJson("nin_cifar10_full")
        //
        deepNetwork.classify(image, shape: imageShape)
        deepNetwork.classify(image, shape: imageShape)
        deepNetwork.classify(random_image, shape: imageShape)

        deepNetwork.classify(image, shape: imageShape)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadExampleImageFromJSONFile(filename:String) -> [Float] {
        let conv1Layer = deepNetwork.loadJSONFile(filename)!
        let image: [Float] = conv1Layer["input"] as! [Float]
        return image
    }
    
    func createRandomImage(size: Int) -> [Float] {
        var randomimage = [Float](count: size, repeatedValue: 0.0)
        for i in 0..<randomimage.count {
            randomimage[i] = Float(arc4random_uniform(1000))
        }
        return randomimage

    }
    
}

