//
//  CameraViewController.swift
//  Spine Scanner 3D
//
//  Created by Carlotta Rödling on 12.01.21.
//

import UIKit
import Metal
import ARKit
import CoreGraphics

class CameraViewController: UIViewController, ARSessionDelegate {
    
    //Erstellen der Variablen
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var takePictureButton: RoundButton!
    @IBOutlet weak var realOrLidarControl: UISegmentedControl!
    var session: ARSession!
    var configuration = ARWorldTrackingConfiguration()
    
    // intrinsic Parameter
    var camWidth: Float?
    var camHeight: Float?
    var camOx: Float?
    var camOy: Float?
    var camFx: Float?
    var camFy: Float?

    var name: String = ""
    var age: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Setzt den viewController als den session's delegate.
        // Dass heisst der ViewController ruft die Func Session (-> ARSession()) immer wieder auf
        session = ARSession()
        session.delegate = self
        
        print("mein name ist im CameraView: \(name), alter: \(age)")
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Aktiviert smoothed scene depth frame-semantic.
        //https://developer.apple.com/documentation/arkit/arconfiguration/framesemantics/3674208-smoothedscenedepth
        configuration.frameSemantics = .smoothedSceneDepth
        
        // Startet die "Session" also den LiDAR
        session.run(configuration)
        
        // Damit der Bildschirm während der Aufnahme nicht abdunkelt (Standbymodi)
        UIApplication.shared.isIdleTimerDisabled = true
    }
        
    /*
     Von: https://developer.apple.com/forums/thread/663995
     color image and depth image are already aligned. That means the intrinsics of the Lidar are only scaled in relation to the color camera. As the depth image has a resolution of 584 x 384 (frame.sceneDepth!.depthMap) and the color image 3840 x 2880, you get fxD, fyD, cxD and cyD as follows:
     
     fxD = 534/3840 * 1598.34
     fyD = 384/2880 * 1598.34
     cxD = 534/3840 * 935.70917
     cyD = 384/2880 * 713.61804
     
     Before transforming the pointcloud to world coordinates, you have to flip them around the X axis to OpenGL coordinate system.
     
     frame.camera.imageResolution = (1920.0, 1440.0)
     */
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        guard let depthMap = frame.smoothedSceneDepth?.depthMap
        else {
            print ("Error")
            return }
        
        // Speichert die Kamerintrinsic und Bildauflösung
        
        //let camIntrinsicsMartix = frame.camera.intrinsics
        //let camImageResolution = frame.camera.imageResolution
        //self.camFx = camIntrinsicsMartix[0][0]
        //self.camFy = camIntrinsicsMartix[1][1]
        //self.camOx = camIntrinsicsMartix[0][2] // u0
        //self.camOy = camIntrinsicsMartix[1][2] // v0
        //self.camWidth = Float(camImageResolution.width)
        //self.camHeight = Float(camImageResolution.height)
        
        
        //Speicher die  Größe des LiDAR Bildes ab
        let depthMapHeight = CVPixelBufferGetHeight(depthMap)
        let depthMapWidth = CVPixelBufferGetWidth(depthMap)
        
        // Stoppt die Aufnahme kurz, um:
//        CVPixelBufferLockBaseAddress(depthMap, CVPixelBufferLockFlags(rawValue: 0))
//        let floatBuffer = unsafeBitCast(CVPixelBufferGetBaseAddress(depthMap), to: UnsafeMutablePointer<Float32>.self)
//        let depthMapX = depthMapWidth/2; //must be lower that cols
//        let depthMapY = depthMapHeight/2; // must be lower than rows
//        let baseAddressIndex = depthMapY  * depthMapWidth + depthMapX;
//        let pixelValue = floatBuffer[baseAddressIndex];
//        CVPixelBufferUnlockBaseAddress(depthMap, CVPixelBufferLockFlags(rawValue: 0))
//
        /* Da die DepthMap eine Größe von 256 * 192 (w * h) und die cam 1920 x 1440 entspricht die die Position des Tiefenwerts an der Stelle (u,v) in der DepthMap der Postion u / w * camWidth, v / h * camHeight der cam */

        let interfaceOrientation = UIApplication.shared.windows.first?.windowScene?.interfaceOrientation ?? UIInterfaceOrientation.unknown
        
        let viewPort = imageView.bounds
        let viewPortSize = imageView.bounds.size
        let depthMapSize = CGSize(width: depthMapWidth, height: depthMapHeight)
        let depthBuffer = CIImage(cvPixelBuffer: depthMap)
        
        
        // Normalisiert die x und y Koordinaten
        let normalizeTransform = CGAffineTransform(scaleX: 1.0/depthMapSize.width, y: 1.0/depthMapSize.height)
        
        // Flippt die Y Achse wenn die Bildschirmausrichtung im Portraitmodus ist
        // See also: https://developer.apple.com/documentation/arkit/arframe/2923543-displaytransform
        let flipTransform = (interfaceOrientation.isPortrait) ? CGAffineTransform(scaleX: -1, y: -1).translatedBy(x: -1, y: -1) : .identity

        let displayTransform = frame.displayTransform(for: interfaceOrientation, viewportSize: viewPortSize)
        
        // Bildschirmgröße
        let toViewPortTransform = CGAffineTransform(scaleX: viewPortSize.width, y: viewPortSize.height)
        
        // Transformiert das Bild auf die richtige Bildschirmgröße
        let transformedImage = depthBuffer.transformed(by: normalizeTransform.concatenating(flipTransform).concatenating(displayTransform).concatenating(toViewPortTransform)).cropped(to: viewPort)
        
        //let displayImage = UIImage(ciImage: transformedImage)
        let displayImage = UIImage(ciImage: transformedImage)
        
        //Display Darstellung
        DispatchQueue.main.async {
            switch self.realOrLidarControl.selectedSegmentIndex {
            case 0:
                self.imageView.image = displayImage
            case  1:
                self.imageView.image = CameraViewController.convertToUIImage(frame.capturedImage)
            default:
                self.imageView.image = displayImage
            }
        }
    }
    
    // Übergibt dem nächsten ViewController den aktuellen Frame
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let modelViewController: ModelViewController = segue.destination as! ModelViewController
        let modelData = ModelData(self.session.currentFrame)
        modelData.name = name
        modelData.age = age
        modelViewController.modelData = modelData
    }
    
    static func convertToUIImage(_ buffer: CVPixelBuffer) -> UIImage?{
        let ciImage = CIImage(cvPixelBuffer: buffer)
        let temporaryContext = CIContext(options: nil)
        if let temporaryImage = temporaryContext.createCGImage(ciImage, from: CGRect(x: 0, y: 0, width: CVPixelBufferGetWidth(buffer), height: CVPixelBufferGetHeight(buffer)))
        {
            let capturedImage = UIImage(cgImage: temporaryImage, scale: 1.0, orientation: .right)
            return capturedImage
        }
        return nil
    }

}

