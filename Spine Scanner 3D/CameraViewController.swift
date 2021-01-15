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
    @IBOutlet weak var realOrLidarButton: UIBarButtonItem!
    var name = ""
    var age = ""
    var session: ARSession!
    var configuration = ARWorldTrackingConfiguration()
    
    // intrinsic Parameter
    var camWidth: Float?
    var camHeight: Float?
    var camOx: Float?
    var camOy: Float?
    var camFx: Float?
    var camFy: Float?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Setzt den viewController als den session's delegate.
        // Dass heisst der ViewController ruft die Func Session (-> ARSession()) immer wieder auf
        session = ARSession()
        session.delegate = self
        
        print(name)
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
     From: https://developer.apple.com/forums/thread/663995
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
        
        let camIntrinsicsMartix = frame.camera.intrinsics
        let camImageResolution = frame.camera.imageResolution
        self.camFx = camIntrinsicsMartix[0][0]
        self.camFy = camIntrinsicsMartix[1][1]
        self.camOx = camIntrinsicsMartix[0][2] // u0
        self.camOy = camIntrinsicsMartix[1][2] // v0
        self.camWidth = Float(camImageResolution.width)
        self.camHeight = Float(camImageResolution.height)
        
        
        //Speicher die  Größe des LiDAR Bildes ab
        let depthMapHeight = CVPixelBufferGetHeight(depthMap)
        let depthMapWidth = CVPixelBufferGetWidth(depthMap)
        
        //print("depthmap w/h: ", w, h)
        //let bytesPerRow = CVPixelBufferGetBytesPerRow(depthMap)
        //print("w,h, bytesPerRow:", h, w, bytesPerRow) // 192, 256
        
        /*
         let f = CVPixelBufferGetPixelFormatType(depthMap)
         switch f {
         case kCVPixelFormatType_DepthFloat32:
         print("format: kCVPixelFormatType_DepthFloat32")
         case kCVPixelFormatType_OneComponent8:
         print("format: kCVPixelFormatType_OneComponent8")
         default:
         print("format: unknown")
         }
         */
        
        // Stoppt die Aufnahme kurz, um
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
        
        
        let displayImage = UIImage(ciImage: transformedImage)
        
        //Display Darstellung
        DispatchQueue.main.async {
            if self.realOrLidarButton.title == "RealPic" {
                self.imageView.image = displayImage
            } else {
                self.imageView.image = frame.capturedImage.toUIImage()
            }
        }
    }
    @IBAction func realOrLidarButtonPressed(_ sender: UIBarButtonItem) {
        if self.realOrLidarButton.title == "RealPic" {
            realOrLidarButton.title = "LidarPic"
        } else {
            realOrLidarButton.title = "RealPic"
        }
    }
    
    // Übergibt dem nächsten ViewController den aktuellen Frame
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let modelViewController: ModelViewController = segue.destination as! ModelViewController
        modelViewController.modelData = ModelData(self.session.currentFrame)
    }

}
