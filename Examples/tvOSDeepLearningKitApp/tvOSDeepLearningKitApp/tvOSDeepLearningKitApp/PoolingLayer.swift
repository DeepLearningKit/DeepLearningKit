//
//  PoolingLayer.swift
//  MemkiteMetal
//
//  Created by Amund Tveit on 25/11/15.
//  Copyright © 2015 memkite. All rights reserved.
//

import Foundation
import Metal


func createPoolingLayerCached(layer: NSDictionary,
    inputBuffer: MTLBuffer,
    inputShape: [Float],
    metalCommandQueue: MTLCommandQueue, metalDefaultLibrary:MTLLibrary, metalDevice:MTLDevice,
    inout pool_type_caches: [Dictionary<String,String>],
    inout layer_data_caches: [Dictionary<String,MTLBuffer>],
    layer_number: Int,
    layer_string: String,
    caching_mode:Bool) -> (MTLBuffer, MTLCommandBuffer, [Float]) {
        
        print(" ==> createPoolingLayerCached")
        let metalCommandBuffer = metalCommandQueue.commandBufferWithUnretainedReferences()
//        let metalCommandBuffer = metalCommandQueue.commandBuffer()
        
        var params = NSDictionary()
        var stride:Float = 1.0
        var kernel_size: Float = 1.0
        var pad: Float = 0.0
        var pooling_params = MetalPoolingParameters(kernel_size: kernel_size, pool_stride: stride, pad: pad)
        var pool_type = 0
        var h:Float = 0.0
        var w:Float = 0.0
        var shape:[Float] = []
        var outputCount:Float = 0
        var pool_width = 0
        var pool_height = 0
        var size_params:MetalShaderParameters = MetalShaderParameters(image_xdim:0.0, image_ydim:0.0, num_images: 0.0, filter_xdim: 0.0, filter_ydim: 0.0, num_filters: 0.0, conv_xdim: 0.0, conv_ydim: 0.0, pool_xdim: 0.0, pool_ydim: 0.0, b:0.0)
        var outputBuffer:MTLBuffer
        
        if(!caching_mode) {
            
            params = layer["pooling_param"] as! NSDictionary
            stride = 1.0
            kernel_size = 1.0
            pad  = 0.0
            if let val = params["stride"] {
                stride = val as! Float
            }
            if let val = params["kernel_size"] {
                kernel_size = val as! Float
                if val as! NSNumber != 3 {
                    pad = 0
                }
            }
            pooling_params = MetalPoolingParameters(kernel_size: kernel_size, pool_stride: stride, pad: pad)
            pool_type = params["pool"] as! Int
            
            // STORE pool type in cache!
            pool_type_caches[layer_number]["pool_type"] = String(pool_type)
            
            //TODO: calculate outputCount
            h = ceil((inputShape[2] + 2.0 * pad - kernel_size) / stride) + 1.0
            w = ceil((Float(inputShape[3]) + 2.0 * pad - kernel_size) / stride) + 1.0
            shape = [inputShape[0], inputShape[1], h, w]
            outputCount = shape.reduce(1, combine: *)
            pool_width = Int(shape[2])
            pool_height = Int(shape[3])
            size_params = MetalShaderParameters(image_xdim: Float(inputShape[2]), image_ydim: Float(inputShape[3]),
            num_images: Float(inputShape[0]),
            filter_xdim: 1.0, filter_ydim: 1.0, num_filters: Float(inputShape[1]),
            conv_xdim:0.0, conv_ydim: 0.0,
            pool_xdim: Float(pool_width), pool_ydim: Float(pool_height), b:0.0)
        } else {
            // need to fetch pool type from cache
            print("FETCHING POOL TYPE FROM CACHE!!!!!")
            pool_type = Int(pool_type_caches[layer_number]["pool_type"]!)!
        }
        
        if pool_type == 1 {
            outputBuffer = addPoolingCommandToCommandBufferCached(metalCommandBuffer, poolingMethod: "avg_pool", inputBuffer: inputBuffer, outputCount: Int(outputCount), size_params: size_params, pooling_params: pooling_params, metalDefaultLibrary: metalDefaultLibrary, metalDevice:metalDevice,
                layer_data_caches: &layer_data_caches, layer_number: layer_number, layer_string: layer_string)
        } else {
            outputBuffer = addPoolingCommandToCommandBufferCached(metalCommandBuffer, poolingMethod: "max_pool", inputBuffer: inputBuffer, outputCount: Int(outputCount), size_params: size_params, pooling_params: pooling_params,metalDefaultLibrary: metalDefaultLibrary, metalDevice: metalDevice,
                layer_data_caches: &layer_data_caches, layer_number: layer_number, layer_string: layer_string)
            
        }
        //metalCommandBuffer.commit()
        
        print(" <== createPoolingLayerCached")
        
        
        return (outputBuffer, metalCommandBuffer, shape)
}


func addPoolingCommandToCommandBufferCached(commandBuffer: MTLCommandBuffer,
    poolingMethod: String,
    inputBuffer: MTLBuffer,
    outputCount: Int,
    size_params: MetalShaderParameters,
    pooling_params: MetalPoolingParameters,
    metalDefaultLibrary:MTLLibrary, metalDevice:MTLDevice,
    inout layer_data_caches: [Dictionary<String,MTLBuffer>],
    layer_number: Int,
    layer_string: String) -> MTLBuffer {
        
        
        print(" ==> addPoolingCommandtoCommandBufferCached")
        
        var layer_data_cache = layer_data_caches[layer_number]
        
        let output = createFloatNumbersArray(outputCount)
        let (_, computePipelineState, _) = setupShaderInMetalPipeline(poolingMethod, metalDefaultLibrary: metalDefaultLibrary, metalDevice: metalDevice)
        
        let outputMetalBuffer = createOrReuseFloatMetalBuffer("outputMetalBuffer", data: output, cache: &layer_data_caches, layer_number: layer_number, metalDevice: metalDevice)
        //        let outputMetalBuffer = createFloatMetalBuffer(output, metalDevice: metalDevice)
        
        let sizeParamMetalBuffer = createOrReuseShaderParametersMetalBuffer("sizeParamMetalBuffer", data: size_params, cache: &layer_data_caches, layer_number: layer_number, metalDevice: metalDevice)
        
        //        let sizeParamMetalBuffer = createShaderParametersMetalBuffer(size_params, metalDevice: metalDevice)
        
        
        //        let poolingParamMetalBuffer = createPoolingParametersMetalBuffer(pooling_params, metalDevice: metalDevice)
        let poolingParamMetalBuffer = createOrReusePoolingParametersMetalBuffer("poolingParamMetalBuffer", data: pooling_params, cache: &layer_data_caches, layer_number: layer_number, metalDevice: metalDevice)
        // Create Metal Compute Command Encoder and add input and output buffers to it
        let metalComputeCommandEncoder = commandBuffer.computeCommandEncoder()
        metalComputeCommandEncoder.setBuffer(outputMetalBuffer, offset: 0, atIndex: 0)
        metalComputeCommandEncoder.setBuffer(inputBuffer, offset: 0, atIndex: 1)
        metalComputeCommandEncoder.setBuffer(sizeParamMetalBuffer, offset: 0, atIndex: 2)
        metalComputeCommandEncoder.setBuffer(poolingParamMetalBuffer, offset: 0, atIndex: 3)
        
        // Set the shader function that Metal will use
        metalComputeCommandEncoder.setComputePipelineState(computePipelineState)
        
        // Set up thread groups on GPU
        // TODO: check out http://metalbyexample.com/introduction-to-compute/
        let threadsPerGroup = MTLSize(width:computePipelineState.threadExecutionWidth,height:1,depth:1)
        // ensure at least 1 threadgroup
        let numThreadgroups = MTLSize(width:(outputCount-1)/computePipelineState.threadExecutionWidth + 1, height:1, depth:1)
        metalComputeCommandEncoder.dispatchThreadgroups(numThreadgroups, threadsPerThreadgroup: threadsPerGroup)
        
        // Finalize configuration
        metalComputeCommandEncoder.endEncoding()
        
        print(" <== addPoolingCommandtoCommandBufferCached")
        
        
        return outputMetalBuffer
}
