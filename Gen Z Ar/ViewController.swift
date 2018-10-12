//
//  ViewController.swift
//  Gen Z Ar
//
//  Created by Matthew Ortega on 10/12/18.
//  Copyright © 2018 Matthew Ortega. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
//import CoreMedia
import AVFoundation

class ViewController: UIViewController {
    
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var instructionLabel: UILabel!
    
    // if we want to anchor the 3d models
    private var worldConfiguration: ARWorldTrackingConfiguration?
    
    /// A serial queue for thread safety when modifying the SceneKit node graph.
    let updateQueue = DispatchQueue(label: Bundle.main.bundleIdentifier! +
        ".serialSceneKitQueue")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.delegate = self
        sceneView.showsStatistics = true

        let scene = SCNScene()
        sceneView.scene = scene
        
        setupImageDetection()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let configuration = worldConfiguration {
            sceneView.debugOptions = .showFeaturePoints
            sceneView.session.run(configuration)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    
    private func setupImageDetection() {
        worldConfiguration = ARWorldTrackingConfiguration()
        
        guard let referenceImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Images", bundle: nil) else {
            fatalError("Missing expected asset catalog resources")
        }
        
        worldConfiguration?.detectionImages = referenceImages
        
    }
}

extension ViewController: ARSessionDelegate {
    func session(_ session: ARSession, didFailWithError error: Error) {
        guard
            let error = error as? ARError,
            let code = ARError.Code(rawValue: error.errorCode)
            else { return }
        instructionLabel.isHidden = false
        switch code {
        case .cameraUnauthorized:
            instructionLabel.text = "Camera tracking is not available. Please check your camera permissions."
        default:
            instructionLabel.text = "Error starting ARKit. Please fix the app and relaunch."
        }
    }
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        switch camera.trackingState {
        case .limited(let reason):
            instructionLabel.isHidden = false
            switch reason {
            case .excessiveMotion:
                instructionLabel.text = "Too much motion! Slow down."
            case .initializing, .relocalizing:
                instructionLabel.text = "Move around slowly to calibrate."
            case .insufficientFeatures:
                instructionLabel.text = "Not enough features detected, try moving around a bit more or turning on the lights."
            }
        case .normal:
            instructionLabel.text = "Point the camera at an object."
        case .notAvailable:
            instructionLabel.isHidden = false
            instructionLabel.text = "Camera tracking is not available."
        }
    }
    
}

extension ViewController: ARSCNViewDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        // TODO: complete this function in the tutorial
        DispatchQueue.main.async { self.instructionLabel.isHidden = true }
        
        if let imageAnchor = anchor as? ARImageAnchor {
            
            handleFoundImage(imageAnchor, node)
        }
    }
    
    private func handleFoundImage(_ imageAnchor: ARImageAnchor, _ node: SCNNode) {
        let name = imageAnchor.referenceImage.name!
        print("you found a \(name) image")
        
        let size = imageAnchor.referenceImage.physicalSize
        
        switch name {
        case "image1":
            createVideoNode(size: size, resource: "sample_animation", node: node)
        case "image2":
            createVideoNode(size: size, resource: "sample_animation_2", node: node)
        default:
            break
        }
        
    }
    
    private func createVideoNode(size: CGSize, resource: String, node: SCNNode){
        
        if let videoNode = makeVideo(size: size, resource: resource) {
            node.addChildNode(videoNode)
            node.opacity = 1
            print("Node added")
        }
        
    }
    
    private func makeVideo(size: CGSize, resource: String) -> SCNNode? {
        // 1
        guard let videoURL = Bundle.main.url(forResource: resource,
                                             withExtension: "mp4") else {
                                                print("Error")
                                                return nil
        }
        
        
        // 2
        let avPlayerItem = AVPlayerItem(url: videoURL)
        let avPlayer = AVPlayer(playerItem: avPlayerItem)
        avPlayer.play()
        
        // 3 For looping
//        NotificationCenter.default.addObserver(
//            forName: .AVPlayerItemDidPlayToEndTime,
//            object: nil,
//            queue: nil) { notification in
//                avPlayer.seek(to: .zero)
//                avPlayer.play()
//        }
        
        // 4
        let avMaterial = SCNMaterial()
        avMaterial.diffuse.contents = avPlayer
        
        // 5
        let videoPlane = SCNPlane(width: size.width, height: size.height)
        videoPlane.materials = [avMaterial]
        
        // 6
        let videoNode = SCNNode(geometry: videoPlane)
        videoNode.eulerAngles.x = -.pi / 2
        videoNode.name = resource
        return videoNode
    }
    
}

