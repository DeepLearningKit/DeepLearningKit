//
//  ViewController.swift
//  tvOSDeepLearningKitApp
//
//  Created by Amund Tveit on 16/02/16.
//  Copyright © 2016 DeepLearningKit. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var label: UILabel!
    var deepNetwork: DeepNetwork!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(animated:Bool) {
        
        deepNetwork = DeepNetwork()
        
        // conv1.json contains a cifar 10 image of a cat
        let conv1Layer = deepNetwork.loadJSONFile("conv1")!
        let image: [Float] = conv1Layer["input"] as! [Float]
        
        // shows a tiny (32x32) CIFAR 10 image on screen
        showCIFARImage(image)
        
        var randomimage = createFloatNumbersArray(image.count)
        for i in 0..<randomimage.count {
            randomimage[i] = Float(arc4random_uniform(1000))
        }
        
        let imageShape:[Float] = [1.0, 3.0, 32.0, 32.0]
        
        var caching_mode = false
        
        // 0. load network in network model
        deepNetwork.loadDeepNetworkFromJSON("nin_cifar10_full", inputImage: image, inputShape: imageShape, caching_mode:caching_mode)
        
        // 1. classify image (of cat)
        deepNetwork.classify(image)
        
        
        // 2. reset deep network and classify random image
        deepNetwork.loadDeepNetworkFromJSON("nin_cifar10_full", inputImage: randomimage, inputShape: imageShape,caching_mode:caching_mode)
        deepNetwork.classify(randomimage)
        
        // 3. reset deep network and classify cat image again
        deepNetwork.loadDeepNetworkFromJSON("nin_cifar10_full", inputImage: image, inputShape: imageShape,caching_mode:caching_mode)
        deepNetwork.classify(image)
        
        exit(0)
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //***********************************************************************************
    
    func showCIFARImage(var cifarImageData:[Float]) {
        
        let size = CGSize(width: 32, height: 32)
        let rect = CGRect(origin: CGPoint(x: 0,y: 0), size: size)
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        UIColor.whiteColor().setFill() // or custom color
        UIRectFill(rect)
        var image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // CIFAR 10 images are 32x32 in 3 channels - RGB
        // it is stored as 3 sequences of 32x32 = 1024 numbers in cifarImageData, i.e.
        // red: numbers from position 0 to 1024 (not inclusive)
        // green: numbers from position 1024 to 2048 (not inclusive)
        // blue: numbers from position 2048 to 3072 (not inclusive)
        for i in 0..<32 {
            for j in 0..<32 {
                let r = UInt8(cifarImageData[i*32 + j])
                let g = UInt8(cifarImageData[32*32 + i*32 + j])
                let b = UInt8(cifarImageData[2*32*32 + i*32 + j])
                
                // used to set pixels - RGBA into an UIImage
                // for more info about RGBA check out https://en.wikipedia.org/wiki/RGBA_color_space
                image = image.setPixelColorAtPoint(CGPoint(x: j,y: i), color: UIImage.RawColorType(r,g,b,255))!
                
                // used to read pixels - RGBA from an UIImage
                var color = image.getPixelColorAtLocation(CGPoint(x:i, y:j))
            }
        }
        print(image.size)
        
        // Displaying original image.
        let originalImageView:UIImageView = UIImageView(frame: CGRectMake(20, 20, image.size.width, image.size.height))
        originalImageView.image = image
        self.view.addSubview(originalImageView)
    }



}

