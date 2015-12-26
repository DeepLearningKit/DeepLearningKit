//
//  RectifierLayer.swift
//  MemkiteMetal
//
//  Created by Torb Morland & Amund Tveit on 12/12/15.
//  Copyright © 2015 Memkite. All rights reserved.
//

import Foundation
import Metal

func createRectifierLayer(inputBuffer: MTLBuffer, metalCommandQueue: MTLCommandQueue, metalDefaultLibrary:MTLLibrary, metalDevice:MTLDevice) -> (MTLBuffer,MTLCommandBuffer) {
    print(" ==> createrectifierlayer")
//    let metalCommandBuffer = metalCommandQueue.commandBuffer()
    let metalCommandBuffer = metalCommandQueue.commandBufferWithUnretainedReferences()

    let result = addRectifierCommandToCommandBuffer(metalCommandBuffer, inputBuffer: inputBuffer,
        metalDefaultLibrary: metalDefaultLibrary, metalDevice:metalDevice)
    //metalCommandBuffer.commit()
    
    print(" <== createrectifierlayer")
    return (result, metalCommandBuffer)
}


func addRectifierCommandToCommandBuffer(commandBuffer: MTLCommandBuffer, inputBuffer: MTLBuffer,
    metalDefaultLibrary:MTLLibrary, metalDevice:MTLDevice) -> MTLBuffer {
    
        print("==> addRectifierToCommandBuffer")
        
    let count = inputBuffer.length / sizeof(Float)
    let (_, computePipelineState, _) = setupShaderInMetalPipeline("rectifier_linear", metalDefaultLibrary: metalDefaultLibrary,
        metalDevice: metalDevice)
    
    // Create Metal Compute Command Encoder and add input and output buffers to it
    let computeCommandEncoder = commandBuffer.computeCommandEncoder()
    computeCommandEncoder.setBuffer(inputBuffer, offset: 0, atIndex: 0)
    // Set the shader function that Metal will use
    computeCommandEncoder.setComputePipelineState(computePipelineState)
    
    // Set up thread groups on GPU
    let threadsPerGroup = MTLSize(width:computePipelineState.threadExecutionWidth,height:1,depth:1)
    // ensure at least 1 threadgroup
    let numThreadgroups = MTLSize(width:(count-1)/computePipelineState.threadExecutionWidth + 1, height:1, depth:1)
    computeCommandEncoder.dispatchThreadgroups(numThreadgroups, threadsPerThreadgroup: threadsPerGroup)
    
    // Finalize configuration
    computeCommandEncoder.endEncoding()
        
        print(" <== addRectifierToCommandBuffer")
    
    return inputBuffer
}
