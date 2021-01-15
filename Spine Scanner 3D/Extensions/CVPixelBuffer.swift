//
//  CVPixelBuffer.swift
//  Spine Scanner 3D
//
//  Created by Carlotta Rödling on 13.01.21.
//
import Foundation
import CoreImage
import UIKit

// Um ein Sinus auf das Bild "zu legen" damit die Tiefe besser erkannt wird 
extension CVPixelBuffer {
    func sinus(withMaxDepth maxDepth: Float, andFrequence frequence :Float) {
        let width = CVPixelBufferGetWidth(self)
        let height = CVPixelBufferGetHeight(self)
        
        CVPixelBufferLockBaseAddress(self, CVPixelBufferLockFlags(rawValue: 0))
        let floatBuffer = unsafeBitCast(CVPixelBufferGetBaseAddress(self), to: UnsafeMutablePointer<Float>.self)
        
        for y in stride(from: 0, to: height, by: 1) {
            for x in stride(from: 0, to: width, by: 1) {
                
                var pixel = floatBuffer[y * width + x]
                if pixel > maxDepth {  // clipping ab maxDepth
                    pixel = 0
                } else {
                    pixel /= maxDepth  // Normalisieren auf Werte zw. 0-1
                }
                
                pixel = min(1.0, max(pixel, 0.0)) // Wertebereich (0-1) sicherstellen
                floatBuffer[y * width + x] = sin(pixel*frequence)+1.0/2.0 // sinus mit hoher frequenz und transponiert in den Wertebereich von 0-1
            }
        }
        
        CVPixelBufferUnlockBaseAddress(self, CVPixelBufferLockFlags(rawValue: 0))
    }
    
    
    func exportAsArray() -> [[Float32]] {

        let width = CVPixelBufferGetWidth(self)
        let height = CVPixelBufferGetHeight(self)
        var floatArray = Array(repeating: Array(repeating: Float32(0.0), count: height), count: width)
        
        CVPixelBufferLockBaseAddress(self, CVPixelBufferLockFlags(rawValue: 0))
        let floatBuffer = unsafeBitCast(CVPixelBufferGetBaseAddress(self), to: UnsafeMutablePointer<Float>.self)
        
        for y in stride(from: 0, to: height, by: 1) {
            for x in stride(from: 0, to: width, by: 1) {
                floatArray[x][y] = floatBuffer[y * width + x]
            }
        }
        CVPixelBufferUnlockBaseAddress(self, CVPixelBufferLockFlags(rawValue: 0))
        return floatArray
    }
    
    func toUIImage() -> UIImage {
         let ciImage = CIImage(cvPixelBuffer: self)
         let context = CIContext(options: nil)
         let cgImage = context.createCGImage(ciImage, from: ciImage.extent)
         let uiImage = UIImage(cgImage: cgImage!)
         return uiImage
     }
}

