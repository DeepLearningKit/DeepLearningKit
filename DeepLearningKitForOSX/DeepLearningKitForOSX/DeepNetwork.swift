//
//  DeepNetwork.swift
//  MemkiteMetal
//
//  Created by Amund Tveit & Torb Morland on 12/12/15.
//  Copyright © 2015 Memkite. All rights reserved.
//

import Foundation
import Metal

public class DeepNetwork {
    var gpuCommandLayers: [MTLCommandBuffer] = []
    var namedDataLayers: [(String, MTLBuffer)] = []
    var imageBuffer: MTLBuffer!
    var metalDevice: MTLDevice!
    var metalDefaultLibrary: MTLLibrary!
    var metalCommandQueue: MTLCommandQueue!
    var deepNetworkAsDict: NSDictionary! // for debugging perhaps
    var layer_data_caches: [Dictionary<String,MTLBuffer>] = []
    var pool_type_caches: [Dictionary<String,String>] = []
    var dummy_image: [Float]!
    var previous_shape: [Float]!
    var blob_cache: [Dictionary<String,([Float],[Float])>] = []
    
    public init() {
        // Get access to iPhone or iPad GPU
        metalDevice = MTLCreateSystemDefaultDevice()
        
        // Queue to handle an ordered list of command buffers
        metalCommandQueue = metalDevice.newCommandQueue()
        print("metalCommandQueue = \(unsafeAddressOf(metalCommandQueue))")
        
        // Access to Metal functions that are stored in Shaders.metal file, e.g. sigmoid()
        metalDefaultLibrary = metalDevice.newDefaultLibrary()
    }
    
    public func loadNetworkFromJson(jsonNetworkFileName: String) {
        deepNetworkAsDict = loadJSONFile(jsonNetworkFileName)!
    }
    
    public func classify(image: [Float], shape:[Float]) -> Int {
        let imageTensor = createMetalBuffer(image, metalDevice: metalDevice)
        
        gpuCommandLayers = []
        setupNetworkFromDict(deepNetworkAsDict, inputimage: imageTensor, inputshape: shape)
        
        let start = NSDate()
        for commandBuffer in gpuCommandLayers {
            commandBuffer.commit()
        }
        
        // wait until last layer in conv.net is finished
        gpuCommandLayers.last!.waitUntilCompleted()
        print("Time to run network: \(NSDate().timeIntervalSinceDate(start))")
        
        var classification_results =  [Float](count: 10, repeatedValue: 0.0)
        let (lastLayerName, lastMetalBuffer) = namedDataLayers.last!
        NSLog(lastLayerName)
        let data = NSData(bytesNoCopy: lastMetalBuffer.contents(),
            length: classification_results.count*sizeof(Float), freeWhenDone: false)
        data.getBytes(&classification_results, length:(Int(classification_results.count)) * sizeof(Float))
        print(classification_results)
        let maxValue:Float = classification_results.maxElement()!
        let indexOfMaxValue:Int = classification_results.indexOf(maxValue)!
        
        print("maxValue = \(maxValue), indexofMaxValue = \(indexOfMaxValue)")
        
        // empty command buffers!
        
        // return index
        return indexOfMaxValue
        
    }
}

