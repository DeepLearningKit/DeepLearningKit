//
//  MetalUtilFunctions.swift
//  MemkiteMetal
//
//  Created by Amund Tveit on 24/11/15.
//  Copyright © 2015 memkite. All rights reserved.
//

import Foundation
import Metal

func createComplexNumbersArray(count: Int) -> [MetalComplexNumberType] {
    let zeroComplexNumber = MetalComplexNumberType()
    return [MetalComplexNumberType](count: count, repeatedValue: zeroComplexNumber)
}

func createFloatNumbersArray(count: Int) -> [Float] {
    return [Float](count: count, repeatedValue: 0.0)
}

func createFloatMetalBuffer(vector: [Float], let metalDevice:MTLDevice) -> MTLBuffer {
    var vector = vector
    let byteLength = vector.count*sizeof(Float) // future: MTLResourceStorageModePrivate
    return metalDevice.newBufferWithBytes(&vector, length: byteLength, options: MTLResourceOptions.CPUCacheModeDefaultCache)
}

// TODO: could perhaps use generics to combine both functions below?
func createComplexMetalBuffer(vector:[MetalComplexNumberType], let metalDevice:MTLDevice) -> MTLBuffer {
    var vector = vector
    let byteLength = vector.count*sizeof(MetalComplexNumberType) // or size of and actual 1st element object?
    return metalDevice.newBufferWithBytes(&vector, length: byteLength, options: MTLResourceOptions.CPUCacheModeDefaultCache)
}

func createShaderParametersMetalBuffer(shaderParameters:MetalShaderParameters,  metalDevice:MTLDevice) -> MTLBuffer {
    var shaderParameters = shaderParameters
    let byteLength = sizeof(MetalShaderParameters)
    return metalDevice.newBufferWithBytes(&shaderParameters, length: byteLength, options: MTLResourceOptions.CPUCacheModeDefaultCache)
}

func createMatrixShaderParametersMetalBuffer(params: MetalMatrixVectorParameters,  metalDevice: MTLDevice) -> MTLBuffer {
    var params = params
    let byteLength = sizeof(MetalMatrixVectorParameters)
    return metalDevice.newBufferWithBytes(&params, length: byteLength, options: MTLResourceOptions.CPUCacheModeDefaultCache)
    
}

func createPoolingParametersMetalBuffer(params: MetalPoolingParameters, metalDevice: MTLDevice) -> MTLBuffer {
    var params = params
    let byteLength = sizeof(MetalPoolingParameters)
    return metalDevice.newBufferWithBytes(&params, length: byteLength, options: MTLResourceOptions.CPUCacheModeDefaultCache)
}

func createConvolutionParametersMetalBuffer(params: MetalConvolutionParameters, metalDevice: MTLDevice) -> MTLBuffer {
    var params = params
    let byteLength = sizeof(MetalConvolutionParameters)
    return metalDevice.newBufferWithBytes(&params, length: byteLength, options: MTLResourceOptions.CPUCacheModeDefaultCache)
}

func createTensorDimensionsVectorMetalBuffer(vector: [MetalTensorDimensions], metalDevice: MTLDevice) -> MTLBuffer {
    var vector = vector
    let byteLength = vector.count * sizeof(MetalTensorDimensions)
    return metalDevice.newBufferWithBytes(&vector, length: byteLength, options: MTLResourceOptions.CPUCacheModeDefaultCache)
}

func setupShaderInMetalPipeline(shaderName:String, metalDefaultLibrary:MTLLibrary, metalDevice:MTLDevice) -> (shader:MTLFunction!,
    computePipelineState:MTLComputePipelineState!,
    computePipelineErrors:NSErrorPointer!)  {
        let shader = metalDefaultLibrary.newFunctionWithName(shaderName)
        let computePipeLineDescriptor = MTLComputePipelineDescriptor()
        computePipeLineDescriptor.computeFunction = shader
        //        var computePipelineErrors = NSErrorPointer()
        //            let computePipelineState:MTLComputePipelineState = metalDevice.newComputePipelineStateWithFunction(shader!, completionHandler: {(})
        let computePipelineErrors:NSErrorPointer = nil
        var computePipelineState:MTLComputePipelineState? = nil
        do {
            computePipelineState = try metalDevice.newComputePipelineStateWithFunction(shader!)
        } catch {
            print("catching..")
        }
        return (shader, computePipelineState, computePipelineErrors)
        
}

func createMetalBuffer(vector:[Float], metalDevice:MTLDevice) -> MTLBuffer {
    var vector = vector
    let byteLength = vector.count*sizeof(Float)
    return metalDevice.newBufferWithBytes(&vector, length: byteLength, options: MTLResourceOptions.CPUCacheModeDefaultCache)
}

func preLoadMetalShaders(metalDevice: MTLDevice, metalDefaultLibrary: MTLLibrary) {
    let shaders = ["avg_pool", "max_pool", "rectifier_linear", "convolution_layer", "im2col"]
    for shader in shaders {
        setupShaderInMetalPipeline(shader, metalDefaultLibrary: metalDefaultLibrary,metalDevice: metalDevice) // TODO: this returns stuff
    }
}

func createOrReuseFloatMetalBuffer(name:String, data: [Float], inout cache:[Dictionary<String,MTLBuffer>], layer_number:Int, metalDevice:MTLDevice) -> MTLBuffer {
    var result:MTLBuffer
    if let tmpval = cache[layer_number][name] {
        print("found key = \(name) in cache")
        result = tmpval
    } else {
        print("didnt find key = \(name) in cache")
        result = createFloatMetalBuffer(data, metalDevice: metalDevice)
        cache[layer_number][name] = result
        // print("DEBUG: cache = \(cache)")
    }
    
    return result
}


func createOrReuseConvolutionParametersMetalBuffer(name:String,
    data: MetalConvolutionParameters,
    inout cache:[Dictionary<String,MTLBuffer>], layer_number: Int, metalDevice: MTLDevice) -> MTLBuffer {
        var result:MTLBuffer
        if let tmpval = cache[layer_number][name] {
           print("found key = \(name) in cache")
            result = tmpval
        } else {
            print("didnt find key = \(name) in cache")
            result = createConvolutionParametersMetalBuffer(data, metalDevice: metalDevice)
            cache[layer_number][name] = result
            //print("DEBUG: cache = \(cache)")
        }
        
        return result
}

func createOrReuseTensorDimensionsVectorMetalBuffer(name:String,
    data:[MetalTensorDimensions],inout cache:[Dictionary<String,MTLBuffer>], layer_number: Int, metalDevice: MTLDevice) -> MTLBuffer {
        var result:MTLBuffer
        if let tmpval = cache[layer_number][name] {
            print("found key = \(name) in cache")
            result = tmpval
        } else {
            print("didnt find key = \(name) in cache")
            result = createTensorDimensionsVectorMetalBuffer(data, metalDevice: metalDevice)
            cache[layer_number][name] = result
            //print("DEBUG: cache = \(cache)")
        }
        
        return result
}

//
//let sizeParamMetalBuffer = createShaderParametersMetalBuffer(size_params, metalDevice: metalDevice)
//let poolingParamMetalBuffer = createPoolingParametersMetalBuffer(pooling_params, metalDevice: metalDevice)

func createOrReuseShaderParametersMetalBuffer(name:String,
    data:MetalShaderParameters,inout cache:[Dictionary<String,MTLBuffer>], layer_number: Int, metalDevice: MTLDevice) -> MTLBuffer {
        var result:MTLBuffer
        if let tmpval = cache[layer_number][name] {
//            print("found key = \(name) in cache")
            result = tmpval
        } else {
//            print("didnt find key = \(name) in cache")
            result = createShaderParametersMetalBuffer(data, metalDevice: metalDevice)
            cache[layer_number][name] = result
            //print("DEBUG: cache = \(cache)")
        }
        
        return result
}

func createOrReusePoolingParametersMetalBuffer(name:String,
    data:MetalPoolingParameters,inout cache:[Dictionary<String,MTLBuffer>], layer_number: Int, metalDevice: MTLDevice) -> MTLBuffer {
        var result:MTLBuffer
        if let tmpval = cache[layer_number][name] {
//            print("found key = \(name) in cache")
            result = tmpval
        } else {
//            print("didnt find key = \(name) in cache")
            result = createPoolingParametersMetalBuffer(data, metalDevice: metalDevice)
            cache[layer_number][name] = result
            //print("DEBUG: cache = \(cache)")
        }
        
        return result
}


