//
//  UIImageExtension.swift
//  ImageFun - original source project: https://github.com/kNeerajPro/ImagePixelFun
//             cloned and adapted to Swift 2.x: https://github.com/DeepLearningKit/ImagePixelFun
//  (ImageFun is also Apache 2.0 open source licence)
//
//  Created by Neeraj Kumar on 11/11/14.
//  Copyright (c) 2014 Neeraj Kumar. All rights reserved.
//  (minor adaptions to Swift 2.x by Amund Tveit - 2016)
//

import Foundation
import UIKit

private extension UIImage {
    private func createARGBBitmapContext(inImage: CGImageRef) -> CGContext {
        
        //Get image width, height
        let pixelsWide = CGImageGetWidth(inImage)
        let pixelsHigh = CGImageGetHeight(inImage)
        
        // Declare the number of bytes per row. Each pixel in the bitmap in this
        // example is represented by 4 bytes; 8 bits each of red, green, blue, and
        // alpha.
        let bitmapBytesPerRow = Int(pixelsWide) * 4
        _ = bitmapBytesPerRow * Int(pixelsHigh)
        
        // Use the generic RGB color space.
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        // Allocate memory for image data. This is the destination in memory
        // where any drawing to the bitmap context will be rendered.
        let bitmapData:UnsafeMutablePointer<UInt8> = nil
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.PremultipliedFirst.rawValue)
        
        // Create the bitmap context. We want pre-multiplied ARGB, 8-bits
        // per component. Regardless of what the source image format is
        // (CMYK, Grayscale, and so on) it will be converted over to the format
        // specified here by CGBitmapContextCreate.
        let context = CGBitmapContextCreate(bitmapData, pixelsWide, pixelsHigh, 8, bitmapBytesPerRow, colorSpace, bitmapInfo.rawValue)
        
        return context!
    }
    
    func sanitizePoint(point:CGPoint) {
        let inImage:CGImageRef = self.CGImage!
        let pixelsWide = CGImageGetWidth(inImage)
        let pixelsHigh = CGImageGetHeight(inImage)
        let rect = CGRect(x:0, y:0, width:Int(pixelsWide), height:Int(pixelsHigh))
        
        precondition(CGRectContainsPoint(rect, point), "CGPoint passed is not inside the rect of image.It will give wrong pixel and may crash.")
    }
}


// Internal functions exposed.Can be public.

extension  UIImage {
    public typealias RawColorType = (newRedColor:UInt8, newgreenColor:UInt8, newblueColor:UInt8,  newalphaValue:UInt8)
    
    
    /*
    Change the color of pixel at a certain point.If you want more control try block based method to modify pixels.
    */
    public func setPixelColorAtPoint(point:CGPoint, color: RawColorType) -> UIImage? {
        self.sanitizePoint(point)
        let inImage:CGImageRef = self.CGImage!
        let context = self.createARGBBitmapContext(inImage)
        
        let pixelsWide = CGImageGetWidth(inImage)
        let pixelsHigh = CGImageGetHeight(inImage)
        let rect = CGRect(x:0, y:0, width:Int(pixelsWide), height:Int(pixelsHigh))
        
        //Clear the context
        CGContextClearRect(context, rect)
        
        // Draw the image to the bitmap context. Once we draw, the memory
        // allocated for the context for rendering will then contain the
        // raw image data in the specified color space.
        CGContextDrawImage(context, rect, inImage)
        
        // Now we can get a pointer to the image data associated with the bitmap
        // context.
        let data = CGBitmapContextGetData(context)
        let dataType = UnsafeMutablePointer<UInt8>(data)
        
        let offset = 4*((Int(pixelsWide) * Int(point.y)) + Int(point.x))
        dataType[offset]   = color.newalphaValue
        dataType[offset+1] = color.newRedColor
        dataType[offset+2] = color.newgreenColor
        dataType[offset+3] = color.newblueColor
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.PremultipliedFirst.rawValue)
        
        let bitmapBytesPerRow = Int(pixelsWide) * 4
        _ = bitmapBytesPerRow * Int(pixelsHigh)
        
        let finalcontext = CGBitmapContextCreate(data, pixelsWide, pixelsHigh, 8, bitmapBytesPerRow, colorSpace, bitmapInfo.rawValue)
        
        let imageRef = CGBitmapContextCreateImage(finalcontext)
        return UIImage(CGImage: imageRef!, scale: self.scale,orientation: self.imageOrientation)
        
    }
    
    
    /*
    Get pixel color for a pixel in the image.
    */
    func getPixelColorAtLocation(point:CGPoint)->UIColor? {
        self.sanitizePoint(point)
        // Create off screen bitmap context to draw the image into. Format ARGB is 4 bytes for each pixel: Alpa, Red, Green, Blue
        let inImage:CGImageRef = self.CGImage!
        let context = self.createARGBBitmapContext(inImage)
        
        let pixelsWide = CGImageGetWidth(inImage)
        let pixelsHigh = CGImageGetHeight(inImage)
        let rect = CGRect(x:0, y:0, width:Int(pixelsWide), height:Int(pixelsHigh))
        
        //Clear the context
        CGContextClearRect(context, rect)
        
        // Draw the image to the bitmap context. Once we draw, the memory
        // allocated for the context for rendering will then contain the
        // raw image data in the specified color space.
        CGContextDrawImage(context, rect, inImage)
        
        // Now we can get a pointer to the image data associated with the bitmap
        // context.
        let data = CGBitmapContextGetData(context)
        let dataType = UnsafePointer<UInt8>(data)
        
        let offset = 4*((Int(pixelsWide) * Int(point.y)) + Int(point.x))
        let alphaValue = dataType[offset]
        let redColor = dataType[offset+1]
        let greenColor = dataType[offset+2]
        let blueColor = dataType[offset+3]
        
        let redFloat = CGFloat(redColor)/255.0
        let greenFloat = CGFloat(greenColor)/255.0
        let blueFloat = CGFloat(blueColor)/255.0
        let alphaFloat = CGFloat(alphaValue)/255.0
        
        return UIColor(red: redFloat, green: greenFloat, blue: blueFloat, alpha: alphaFloat)
        
        // When finished, release the context
        // Free image data memory for the context
    }
    
    
    // Get grayscale image from normal image.
    
    func getGrayScale() -> UIImage? {
        let inImage:CGImageRef = self.CGImage!
        let context = self.createARGBBitmapContext(inImage)
        let pixelsWide = CGImageGetWidth(inImage)
        let pixelsHigh = CGImageGetHeight(inImage)
        let rect = CGRect(x:0, y:0, width:Int(pixelsWide), height:Int(pixelsHigh))
        
        let bitmapBytesPerRow = Int(pixelsWide) * 4
        _ = bitmapBytesPerRow * Int(pixelsHigh)
        
        //Clear the context
        CGContextClearRect(context, rect)
        
        // Draw the image to the bitmap context. Once we draw, the memory
        // allocated for the context for rendering will then contain the
        // raw image data in the specified color space.
        CGContextDrawImage(context, rect, inImage)
        
        // Now we can get a pointer to the image data associated with the bitmap
        // context.
        
        
        let data = CGBitmapContextGetData(context)
        let dataType = UnsafeMutablePointer<UInt8>(data)
        _ = CGPointMake(0, 0)
        
        for x in 0 ..< Int(pixelsWide)  {
            for y in 0 ..< Int(pixelsHigh)  {
                let offset = 4*((Int(pixelsWide) * Int(y)) + Int(x))
                _ = dataType[offset]
                let red = dataType[offset+1]
                let green = dataType[offset+2]
                let blue = dataType[offset+3]
                
                let avg = (UInt32(red) + UInt32(green) + UInt32(blue))/3
                
                dataType[offset + 1] = UInt8(avg)
                dataType[offset + 2] = UInt8(avg)
                dataType[offset + 3] = UInt8(avg)
            }
        }
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.PremultipliedFirst.rawValue)
        
        let finalcontext = CGBitmapContextCreate(data, pixelsWide, pixelsHigh, 8,  bitmapBytesPerRow, colorSpace, bitmapInfo.rawValue)
        
        let imageRef = CGBitmapContextCreateImage(finalcontext)
        return UIImage(CGImage: imageRef!, scale: self.scale,orientation: self.imageOrientation)
    }
    
    
    
    // Defining the closure.
    typealias ModifyPixelsClosure = (point:CGPoint, redColor:UInt8, greenColor:UInt8, blueColor:UInt8, alphaValue:UInt8)->(newRedColor:UInt8, newgreenColor:UInt8, newblueColor:UInt8,  newalphaValue:UInt8)
    
    
    // Provide closure which will return new color value for pixel using any condition you want inside the closure.
    
    func applyOnPixels(closure:ModifyPixelsClosure) -> UIImage? {
        let inImage:CGImageRef = self.CGImage!
        let context = self.createARGBBitmapContext(inImage)
        let pixelsWide = CGImageGetWidth(inImage)
        let pixelsHigh = CGImageGetHeight(inImage)
        let rect = CGRect(x:0, y:0, width:Int(pixelsWide), height:Int(pixelsHigh))
        
        let bitmapBytesPerRow = Int(pixelsWide) * 4
        _ = bitmapBytesPerRow * Int(pixelsHigh)
        
        //Clear the context
        CGContextClearRect(context, rect)
        
        // Draw the image to the bitmap context. Once we draw, the memory
        // allocated for the context for rendering will then contain the
        // raw image data in the specified color space.
        CGContextDrawImage(context, rect, inImage)
        
        // Now we can get a pointer to the image data associated with the bitmap
        // context.
        
        
        let data = CGBitmapContextGetData(context)
        let dataType = UnsafeMutablePointer<UInt8>(data)
        _ = CGPointMake(0, 0)
        
        for x in 0 ..< Int(pixelsWide)  {
            for y in 0 ..< Int(pixelsHigh)  {
                let offset = 4*((Int(pixelsWide) * Int(y)) + Int(x))
                let alpha = dataType[offset]
                let red = dataType[offset+1]
                let green = dataType[offset+2]
                let blue = dataType[offset+3]
                //                let (newRedColor:UInt8, newGreenColor:UInt8?, newBlueColor:UInt8?, newAlphaValue:UInt8?)  =  closure(point: CGPointMake(CGFloat(x), CGFloat(y)), redColor: red, greenColor: green,  blueColor: blue, alphaValue: alpha)
                let (newRedColor, newGreenColor, newBlueColor, newAlphaValue)  =  closure(point: CGPointMake(CGFloat(x), CGFloat(y)), redColor: red, greenColor: green,  blueColor: blue, alphaValue: alpha)
                dataType[offset] = newAlphaValue
                dataType[offset + 1] = newRedColor
                dataType[offset + 2] = newGreenColor
                dataType[offset + 3] = newBlueColor
            }
        }
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.PremultipliedFirst.rawValue)
        
        let finalcontext = CGBitmapContextCreate(data, pixelsWide, pixelsHigh, 8,  bitmapBytesPerRow, colorSpace, bitmapInfo.rawValue)
        
        let imageRef = CGBitmapContextCreateImage(finalcontext)
        return UIImage(CGImage: imageRef!, scale: self.scale,orientation: self.imageOrientation)
    }
    
}