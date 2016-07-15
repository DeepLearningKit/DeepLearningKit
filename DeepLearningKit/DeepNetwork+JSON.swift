//
//  DeepNetwork+JSON.swift
//  MemkiteMetal
//
//  Created by Amund Tveit & Torb Morland on 12/12/15.
//  Copyright © 2015 Memkite. All rights reserved.
//

import Foundation

public extension DeepNetwork {
    
func loadJSONFile(filename: String) -> NSDictionary? {
    print(" ==> loadJSONFile(filename=\(filename)")
    
    do {
        let bundle = NSBundle.mainBundle()
        let path = bundle.pathForResource(filename, ofType: "json")!
        let jsonData = NSData(contentsOfFile: path)
        print(" <== loadJSONFile")
        return try NSJSONSerialization.JSONObjectWithData(jsonData!, options: .AllowFragments) as? NSDictionary
    } catch _ {
        return nil
    }
}
}