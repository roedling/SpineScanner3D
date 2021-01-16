//
//  ModelData.swift
//  Spine Scanner 3D
//
//  Created by Carlotta Rödling on 13.01.21.
//
import Foundation
import SceneKit
import ARKit

class ModelData {
    
    private var depthMap: [[Float32]] = [[]]    // 2d array of depth data from the lidar
    private var vertices: [SCNVector3] = []     // 3d vertices of the mesh covering the scanned object
    private var normals: [SCNVector3] = []      // normals for each vertice
    private var texCoord: [simd_float2] = []    // texture coordinates
    private var idxMatrix: [[Int32?]] = [[]]    // 2d array with pointers into the verices array
                                                // maps from lidar pixel to vertice in world coordinates
                                                // value could be nil if vertice was skiped or removed
    private var triangleIndices: [Int32] = []   // 1d list of indices pointing to triangle vertices
    
    var frameCopy: ARFrame? = nil
    // Kamera intrinsics
    private var fx: Float32 = 0
    private var fy: Float32 = 0
    private var cx: Float32 = 0
    private var cy: Float32 = 0
    
    // Kamera euler angles
    private var euler = simd_float3(0,0,0)
    
    // Originales Farbbild
    var colorImage = UIImage()
    
    //Persönliche Daten
    var name: String = ""
    var age: String = ""
        
    // Konstruktor um die Daten aus dem JSON zu laden
//    init() {
//        let asset = NSDataAsset(name: "ExampleScan1", bundle: Bundle.main)
//        let json: NSDictionary = try! JSONSerialization.jsonObject(with: asset!.data, options: JSONSerialization.ReadingOptions.allowFragments) as! NSDictionary
//
//        if (json["depthMap"] == nil) {
//            print("No depth data found")
//            return
//        }
//
//        let depthMapAsDouble = json["depthMap"] as? [[Double]] ?? [[]]
//        depthMap = Array(repeating: Array(repeating: Float32(0), count: depthMapAsDouble[0].count), count: depthMapAsDouble.count)
//        for ix in 0..<depthMapAsDouble.count {
//            for iy in 0..<depthMapAsDouble[ix].count {
//                depthMap[ix][iy] = Float(depthMapAsDouble[ix][iy])
//            }
//        }
//
//        let cameraIntrinsics = json["cameraIntrinsics"] as? [[Float32]] ?? [[]]
//
//        // cam & lidar haben (scheinbar) immer querformat (landscape)
//        // bei aufnahme im hochformat (portrait) geht die x achse dann also nach oben (oder nach unten)
//        // das bild erscheint dann um 90 grad gedreht
//        //
//        // Quer (ausgangsformat):
//        // Euler: x = -2º, y = 0º, z = -1º  also Handy quer, kamera links oben = (0,0,0)
//        // Lidar: w = 256.0, h = 192.0, cx = 127.50073, cy = 91.79468
//        //
//        // Hochkant:
//        // Euler: x = -4º, y = 0º, z = -90º  Handy hochkannt => kamera rechts oben = querformat um -90º um die z-achse gedreht
//        // Lidar: w = 256.0, h = 192.0, cx = 123.33783, cy = 95.96991
//        //
//        // Euler positiv => drehung nach links, Euler negativ = drehung nach rechts
//
//
//        let camWidth = (json["camImageResolution"] as! NSDictionary)["width"] as! Float32
//        let camHeight = (json["camImageResolution"] as! NSDictionary)["height"] as! Float32
//
//        let lidarWidth = (json["depthMapResolution"] as! NSDictionary)["width"] as! Float32
//        let lidarHeight = (json["depthMapResolution"] as! NSDictionary)["height"] as! Float32
//
//        let xScale = 1.0/camWidth * lidarWidth
//        let yScale = 1.0/camHeight * lidarHeight
//
//        fx = cameraIntrinsics[0][0] * xScale
//        fy = cameraIntrinsics[1][1] * yScale
//        cx = cameraIntrinsics[0][2] * xScale
//        cy = cameraIntrinsics[1][2] * yScale
//
//        euler.x = Float32((json["cameraEulerAngle"] as! NSDictionary)["x"] as! Double)
//        euler.y = Float32((json["cameraEulerAngle"] as! NSDictionary)["y"] as! Double)
//        euler.z = Float32((json["cameraEulerAngle"] as! NSDictionary)["z"] as! Double)
//
//        if ((json["colorImage"]) != nil) {
//            let imgBase64 = (json["colorImage"] as? String)!
//            let imageDecoded = Data(base64Encoded: imgBase64, options: Data.Base64DecodingOptions.ignoreUnknownCharacters)!
//            colorImage = UIImage(data: imageDecoded)!
//        }
//
//        print("\(#function): Lidar: w = \(lidarWidth), h = \(lidarHeight), cx = \(cx), cy = \(cy)")
//        print("\(#function): Euler: x = \(Int(euler.x.inDegree().rounded()))º, y = \(Int(euler.y.inDegree().rounded()))º, z = \(Int(euler.z.inDegree().rounded()))º")
//
//    }
    
    // Konstruktor (während der Laufzeit)
    init(_ frame: ARFrame?) {
        if (frame == nil) {
            print("Error, no frame")
            return
        }
        frameCopy = frame!
        guard let cvDepthMap = frame!.smoothedSceneDepth?.depthMap else {
            print("Error, no depth map")
            return
        }
        let p = CVPixelBufferGetPixelFormatType(cvDepthMap)
        if p != kCVPixelFormatType_DepthFloat32 {
            print("Error, wrong depth map type")
            return
        }
        
        depthMap = cvDepthMap.exportAsArray()
        
        euler.x = frame!.camera.eulerAngles.x
        euler.y = frame!.camera.eulerAngles.y
        euler.z = frame!.camera.eulerAngles.z
        
        let camWidth = Float(frame!.camera.imageResolution.width)
        let camHeight = Float(frame!.camera.imageResolution.height)
        
        let lidarWidth = Float(CVPixelBufferGetWidth(cvDepthMap))
        let lidarHeight = Float(CVPixelBufferGetHeight(cvDepthMap))
        
        // Skaliert die Kamera intrinsics auf die Größe des LiDAR Sensor
        let xScale = 1.0/camWidth * lidarWidth
        let yScale = 1.0/camHeight * lidarHeight
        
        fx = frame!.camera.intrinsics[0][0] * xScale
        fy = frame!.camera.intrinsics[1][1] * yScale
        cx = frame!.camera.intrinsics[2][0] * xScale
        cy = frame!.camera.intrinsics[2][1] * yScale

        euler = frame!.camera.eulerAngles
        
        colorImage = frame!.capturedImage.toUIImage()
          
        print("\(#function): Euler: x = \(Int(euler.x.inDegree().rounded()))º, y = \(Int(euler.y.inDegree().rounded()))º, z = \(Int(euler.z.inDegree().rounded()))º")
        print("\(#function): Lidar: w = \(lidarWidth), h = \(lidarHeight), cx = \(cx), cy = \(cy)")
    }
    
    // generiert das Mesh
    func generateMesh(_ maxDepth: Float32 = 1.0) -> SCNGeometry {
        
        // reset array
        triangleIndices = []
        
        let w = depthMap.count
        let h = depthMap[0].count
        print("\(#function): w = \(w), h = \(h)")
        
        // kleinster z-wert aller vertices, um das Model später auf die richtige Entfernung zu setzen
        var minZ: Float32 = Float.greatestFiniteMagnitude
        
        // init 2d matrix of indices. Every index points to an 3d vertice. the x and y coordinates of the 3d vertices are aligned to the 2d matrix.
        idxMatrix = Array(repeating: Array(repeating: nil, count: h), count: w)
        
        // traverse the 2d depthMap. Calculate 3d points from the position of the depth value in the depth map in respect to the camera intrinsics
        var idx:Int32 = 0
        for ix in 0..<w {
            for iy in 0..<h {
                let z = depthMap[ix][iy] //
                
                if (z < maxDepth) {  // positionierung des  Models (z-werte anpassen)
                    
                    let x = z * (Float32(ix) - cx) / fx
                    let y = z * (Float32(iy) - cy) / fy
                    
                    var point3d: SCNVector3 = SCNVector3(-1*x, -1*y, z) // mirror at x and y axis to convert into SceneView coordinate system
                    point3d.rotateZ(euler.z)  // compensate camera roll (around z axis)
                    point3d.rotateX(euler.x)  // compensate camera pitch (around x axis)
                    
                    // coordinaten raum in sceneview ist: z zeigt zur kamera und die schaut nach -z, x nach rechts und y nach oben
                    // depth sensor schaut aber nach +z!
                    // aktuell wird die kamera einfach nach z=-1m verschoben und dann um 180º um die y achse gedreht
                    // danach zeigt die x achse allerdings nach links...
                    
                    vertices.append(point3d) // add calculated point to array of vertices
                    normals.append(SCNVector3(x:0,y:0,z:0)) // create an empty normal element
                    texCoord.append(simd_float2(Float(ix)/Float(w),Float(iy)/Float(h))) // add normalized texture coordinates
                    idxMatrix[ix][iy] = idx  // store corresponding index
                    idx+=1  // prepare for next index
                    
                    // compute smalest z value og point cloud
                    minZ = (point3d.z < minZ) ? point3d.z : minZ
                }
            }
        }
        
        // use x and y component of the vertice behind the center of the camera (or depth map)
        // to translate the point cloud back into the viewers line of sight after all rotational operations.
        // also do a translation in direction of z, so that the smallest value of z is 0 afterwards
        let idxCenter = idxMatrix[Int(w/2)][Int(h/2)] // get center of depth map
        var center = SCNVector3(0,0,0) // default, in case there is no center point
        if (idxCenter != nil) {
            center = vertices[Int(idxCenter!)]  // get vertice behind the center of the depth map
        }
        // now translate the point cloud
        for index in vertices.indices {
            vertices[index] += SCNVector3(-center.x,-center.y,-minZ)
        }
        
        print("\(#function): total points: \(w*h), valid points: \(idx)")
        
        // generate 2 triangles for every vertex (but skip last row & column)
        for ix in 0..<w-1 {
            for iy in 0..<h-1 {
                genTriangle(idxMatrix[ix][iy],idxMatrix[ix][iy+1],idxMatrix[ix+1][iy])
                genTriangle(idxMatrix[ix+1][iy],idxMatrix[ix][iy+1],idxMatrix[ix+1][iy+1])
            }
        }
        
        
        // create data structures needed by SCNGeometry
    
        let vertexData = NSData(bytes: vertices, length: MemoryLayout<SCNVector3>.size * vertices.count) as Data
        
        let vertexSource = SCNGeometrySource(data: vertexData,
                                             semantic: .vertex,
                                             vectorCount: vertices.count,
                                             usesFloatComponents: true,
                                             componentsPerVector: 3,
                                             bytesPerComponent: MemoryLayout<Float>.size,
                                             dataOffset: 0,
                                             dataStride: MemoryLayout<SCNVector3>.stride)
        
        let normalData = NSData(bytes: normals, length: MemoryLayout<SCNVector3>.size * normals.count) as Data
        
        let normalSource = SCNGeometrySource(data: normalData,
                                             semantic: .normal,
                                             vectorCount: normals.count,
                                             usesFloatComponents: true,
                                             componentsPerVector: 3,
                                             bytesPerComponent: MemoryLayout<Float>.size,
                                             dataOffset: 0,
                                             dataStride: MemoryLayout<SCNVector3>.stride)
        
        let texCoordData = NSData(bytes: texCoord, length: MemoryLayout<simd_float2>.size * texCoord.count) as Data
        let texCoordSource = SCNGeometrySource(data: texCoordData,
                                             semantic: .texcoord,
                                             vectorCount: texCoord.count,
                                             usesFloatComponents: true,
                                             componentsPerVector: 2,
                                             bytesPerComponent: MemoryLayout<Float>.size,
                                             dataOffset: 0,
                                             dataStride: MemoryLayout<simd_float2>.stride)
        
        let elementData = NSData(bytes: triangleIndices, length: MemoryLayout<Int32>.size * triangleIndices.count) as Data
        
        let element = SCNGeometryElement(data: elementData,
                                         primitiveType: .triangles,
                                         primitiveCount: triangleIndices.count/3,
                                         bytesPerIndex: MemoryLayout<Int32>.size)
        
        return SCNGeometry(sources: [vertexSource,normalSource,texCoordSource], elements: [element])
        
    }
    
    // generate triangle from 3 points (given as index into self.vertices[]) and
    // add the calculated normal to self.normals[]
    func genTriangle(_ p1:Int32?, _ p2:Int32?, _ p3:Int32?) {
        if (p1 == nil || p2 == nil || p3 == nil) {
            // generate no triangle if one or more vertices are nil (clipped away)
            return
        }
        triangleIndices.append(p1!)
        triangleIndices.append(p2!)
        triangleIndices.append(p3!)
        
        var n = calcNormal(p1!,p2!,p3!)  // find the normal of the triangle
        
        // just in case the resulting normal points away from the viewer (z is positive)
        // negate z to flip it around
        n.z = (n.z > 0) ? -n.z : n.z
        
        // add normalized normal of triangle to normal of all 3 vertices
        // In the end, all normal of the adjacent triangles were added to each vertice and
        // the resulting normal represents the mean value between all adjacent triangles
        normals[Int(p1!)] += n
        normals[Int(p1!)].normalize()
        normals[Int(p2!)] += n
        normals[Int(p2!)].normalize()
        normals[Int(p3!)] += n
        normals[Int(p3!)].normalize()
    }
    
    // Kalkulierung der Normalen und normalisierung
    func calcNormal(_ p1:Int32, _ p2:Int32, _ p3:Int32) -> SCNVector3
    {
        let v1 = vertices[Int(p1)]
        let v2 = vertices[Int(p2)]
        let v3 = vertices[Int(p3)]
        
        let n = (v2 - v1).cross(v3 - v1)
        
        return(n.normalized())
    }
    
}
