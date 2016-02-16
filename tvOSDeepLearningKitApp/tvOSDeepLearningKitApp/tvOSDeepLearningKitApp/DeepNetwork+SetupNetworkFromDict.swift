//
//  DeepNetwork+SetupNetworkFromDict.swift
//  MemkiteMetal
//
//  Created by Amund Tveit on 10/12/15.
//  Copyright © 2015 memkite. All rights reserved.
//

import Foundation
import Metal

public extension DeepNetwork {
    
    func setupNetworkFromDict(deepNetworkAsDict: NSDictionary, inputimage: MTLBuffer, inputshape: [Float], caching_mode:Bool) {
        
        let start = NSDate()

        print(" ==> setupNetworkFromDict()")
        // Add input image
        var layer_number = 0
        layer_data_caches.append(Dictionary<String, MTLBuffer>()) // for input
        pool_type_caches.append(Dictionary<String,String>())
        blob_cache.append(Dictionary<String,([Float],[Float])>())
        namedDataLayers.append(("input", inputimage))
        ++layer_number
        
        
        // Add remaining network
        var previousBuffer:MTLBuffer = inputimage
        var previousShape:[Float] = inputshape
        
        self.deepNetworkAsDict = deepNetworkAsDict
        
        // create new command buffer for next layer
        var currentCommandBuffer: MTLCommandBuffer = metalCommandQueue.commandBufferWithUnretainedReferences()
        
        var t = NSDate()
        for layer in deepNetworkAsDict["layer"] as! [NSDictionary] {
            if let type = layer["type"] as? String {
                let layer_string = layer["name"] as! String
                
                layer_data_caches.append(Dictionary<String, MTLBuffer>())
                pool_type_caches.append(Dictionary<String,String>())
                blob_cache.append(Dictionary<String,([Float],[Float])>())

                
                if type == "ReLU" {
                    self.gpuCommandLayers.append(currentCommandBuffer)
                    //(previousBuffer, currentCommandBuffer) = createRectifierLayer(previousBuffer)
                    (previousBuffer, currentCommandBuffer) = createRectifierLayer(previousBuffer, metalCommandQueue:metalCommandQueue, metalDefaultLibrary:metalDefaultLibrary, metalDevice:metalDevice)
                    self.namedDataLayers.append((layer["name"]! as! String, previousBuffer))
                } else if type == "Pooling" {
                    self.gpuCommandLayers.append(currentCommandBuffer)
                    //                    (previousBuffer, currentCommandBuffer, previousShape) = createPoolingLayer(layer, inputBuffer: previousBuffer, inputShape: previousShape)
                    (previousBuffer, currentCommandBuffer, previousShape) = createPoolingLayerCached(layer, inputBuffer: previousBuffer, inputShape: previousShape, metalCommandQueue: metalCommandQueue, metalDefaultLibrary: metalDefaultLibrary, metalDevice: metalDevice, pool_type_caches: &pool_type_caches, layer_data_caches: &layer_data_caches, layer_number: layer_number, layer_string: layer_string, caching_mode: caching_mode)
                    self.namedDataLayers.append((layer["name"]! as! String, previousBuffer))
                } else if type == "Convolution" {
                    self.gpuCommandLayers.append(currentCommandBuffer)
                    //                    (previousBuffer, currentCommandBuffer, previousShape) = createConvolutionLayer(layer, inputBuffer: previousBuffer, inputShape: previousShape)
                    (previousBuffer, currentCommandBuffer, previousShape) = createConvolutionLayerCached(layer, inputBuffer: previousBuffer, inputShape: previousShape, metalCommandQueue: metalCommandQueue, metalDefaultLibrary:metalDefaultLibrary, metalDevice:metalDevice, layer_data_caches: &layer_data_caches, blob_cache: &blob_cache, layer_number: layer_number, layer_string: layer_string, caching_mode: caching_mode)
                    
                    
                    self.namedDataLayers.append((layer["name"]! as! String, previousBuffer))
                }
                let name = layer["name"] as! String
                print("\(name): \(NSDate().timeIntervalSinceDate(t))")
                t = NSDate()
                ++layer_number
                
            }
        }
        
        self.gpuCommandLayers.append(currentCommandBuffer)
        
        print("bar")
        
        print("AFTER LAYER DATA CHACES = \(layer_data_caches[0])")
        
        print("POOL TYPE CACHES = \(pool_type_caches)")
        
        print("Time to set up network: \(NSDate().timeIntervalSinceDate(start))")

    }
}
