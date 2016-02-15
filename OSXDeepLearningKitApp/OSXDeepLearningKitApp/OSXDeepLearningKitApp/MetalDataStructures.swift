//
//  MetalDataStructures.swift
//  MemkiteMetal
//
//  Created by Amund Tveit on 24/11/15.
//  Copyright © 2015 memkite. All rights reserved.
//

import Foundation
import Foundation
import Metal
import QuartzCore

//////////////////////////////////////////
// Metal Data Types - their SWIFT Counterparts
//////////////////////////////////////////
public struct MetalComplexNumberType {
    var real: Float = 0.0
    var imag: Float = 0.0
}

public struct MetalShaderParameters {
    let image_xdim: Float
    let image_ydim: Float
    let num_images: Float
    let filter_xdim: Float
    let filter_ydim: Float
    let num_filters: Float
    let conv_xdim: Float // image_xdim - filter_xdim + 1 without striding
    let conv_ydim: Float  // image_ydim - filter_ydim + 1 without striding
    let pool_xdim: Float
    let pool_ydim: Float
    var b: Float
}

public struct MetalMatrixVectorParameters {
    let x_xdim: Float
    let x_ydim: Float
    let w_xdim: Float
    let w_ydim: Float
    let b_xdim: Float
    let b_ydim: Float
    let result_xdim: Float
    let result_ydim: Float
}

public struct MetalPoolingParameters {
    let kernel_size: Float
    let pool_stride: Float
    let pad: Float
}

public struct MetalTensorDimensions {
    let n: Float
    let channels: Float
    let width: Float
    let height: Float
}

public struct MetalConvolutionParameters {
    let pad: Float
    let kernel_size: Float
    let stride: Float
}
