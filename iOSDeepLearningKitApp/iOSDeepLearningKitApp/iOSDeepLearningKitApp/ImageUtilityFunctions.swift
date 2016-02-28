//
//  ImageUtilityFunctions.swift
//  iOSDeepLearningKitApp
//
//  This code is a contribution from Maciej Szpakowski - https://github.com/several27
//  with a minor fix by Stanislav Ashmanov https://github.com/ashmanov
//  ref: issue - https://github.com/DeepLearningKit/DeepLearningKit/issues/8
//
//  Copyright © 2016 DeepLearningKit. All rights reserved.
//

import Foundation
import UIKit
import Accelerate

func imageToMatrix(image: UIImage) -> ([Float], [Float], [Float], [Float])
{
    let imageRef = image.CGImage
    let width = CGImageGetWidth(imageRef)
    let height = CGImageGetHeight(imageRef)
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let bytesPerPixel = 4
    let bytesPerRow:UInt = UInt(bytesPerPixel) * UInt(width)
    let bitsPerComponent:UInt = 8
    let pix = Int(width) * Int(height)
    let count:Int = 4 * Int(pix)
    
    // Pulling the color out of the image
    let rawData = UnsafeMutablePointer<UInt8>.alloc(4 * width * height)
    let temp = CGImageAlphaInfo.PremultipliedLast.rawValue
    let context = CGBitmapContextCreate(rawData, Int(width), Int(height), Int(bitsPerComponent), Int(bytesPerRow), colorSpace, temp)
    CGContextDrawImage(context, CGRectMake(0, 0, CGFloat(width), CGFloat(height)), imageRef)
    
    // Unsigned char to double conversion
    var rawDataArray: [Float] = Array(count: count, repeatedValue: 0.0)
    vDSP_vfltu8(rawData, vDSP_Stride(1), &rawDataArray, 1, vDSP_Length(count))
    
    // Indices matrix
    var i: [Float] = Array(count: pix, repeatedValue: 0.0)
    var min: Float = 0.0
    var step: Float = 4.0
    vDSP_vramp(&min, &step, &i, vDSP_Stride(1), vDSP_Length(i.count))
    
    func increaseMatrix(var matrix: [Float]) -> [Float]
    {
        var increaser: Float = 1.0
        vDSP_vsadd(&matrix, vDSP_Stride(1), &increaser, &matrix, vDSP_Stride(1), vDSP_Length(i.count))
        
        return matrix
    }
    
    // Red matrix
    var r: [Float] = Array(count: pix, repeatedValue: 0.0)
    vDSP_vindex(&rawDataArray, &i, vDSP_Stride(1), &r, vDSP_Stride(1), vDSP_Length(r.count))
    
    increaseMatrix(i)
    min = 1.0
    vDSP_vramp(&min, &step, &i, vDSP_Stride(1), vDSP_Length(i.count))
    // Green matrix
    var g: [Float] = Array(count: pix, repeatedValue: 0.0)
    vDSP_vindex(&rawDataArray, &i, vDSP_Stride(1), &g, vDSP_Stride(1), vDSP_Length(g.count))
    
    increaseMatrix(i)
    min = 2.0
    vDSP_vramp(&min, &step, &i, vDSP_Stride(1), vDSP_Length(i.count))
    // Blue matrix
    var b: [Float] = Array(count: pix, repeatedValue: 0.0)
    vDSP_vindex(&rawDataArray, &i, vDSP_Stride(1), &b, vDSP_Stride(1), vDSP_Length(b.count))
    
    increaseMatrix(i)
    min = 3.0
    vDSP_vramp(&min, &step, &i, vDSP_Stride(1), vDSP_Length(i.count))
    // Alpha matrix
    var a: [Float] = Array(count: pix, repeatedValue: 0.0)
    vDSP_vindex(&rawDataArray, &i, vDSP_Stride(1), &a, vDSP_Stride(1), vDSP_Length(a.count))
    
    return (r, g, b, a)
}