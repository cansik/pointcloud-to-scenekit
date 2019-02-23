//
//  GameViewController.swift
//  PLYToSceneKit
//
//  Created by Florian Bruggisser on 2019-02-23.
//  Copyright © 2019 bildspur. All rights reserved.
//

import SceneKit
import QuartzCore

class GameViewController: NSViewController {
    var convertedScene = SCNScene()

    override func viewDidLoad() {
        super.viewDidLoad()

        let scene = SCNScene()

        let ambientLight = SCNLight()
        ambientLight.color = NSColor.white
        ambientLight.type = SCNLight.LightType.ambient
        scene.rootNode.light = ambientLight;

        let sphereGeometry = SCNSphere(radius: 1.5)
        let sphereMaterial = SCNMaterial()
        sphereMaterial.diffuse.contents =  NSColor.white
        sphereGeometry.materials = [sphereMaterial]
        let sphere = SCNNode(geometry: sphereGeometry)

        scene.rootNode.addChildNode(sphere)

        let scnView = self.view as! SCNView
        scnView.scene = scene
        scnView.allowsCameraControl = false
        scnView.showsStatistics = false
        scnView.backgroundColor = NSColor.black

        // Add a click gesture recognizer
        let clickGesture = NSClickGestureRecognizer(target: self, action: #selector(handleClick(_:)))
        var gestureRecognizers = scnView.gestureRecognizers
        gestureRecognizers.insert(clickGesture, at: 0)
        scnView.gestureRecognizers = gestureRecognizers
    }

    func showFileLoader()
    {
        let dialog = NSOpenPanel();

        dialog.title                   = "Choose a .ply file";
        dialog.showsResizeIndicator    = true;
        dialog.showsHiddenFiles        = false;
        dialog.canChooseDirectories    = false;
        dialog.canCreateDirectories    = true;
        dialog.allowsMultipleSelection = false;
        dialog.allowedFileTypes        = ["ply"];

        if (dialog.runModal() == NSApplication.ModalResponse.OK) {
            let result = dialog.url

            if (result != nil) {
                let path = result!.path
                convertCloud(path: path)
            }
        } else {
            return
        }
    }

    @objc
    func handleClick(_ gestureRecognizer: NSGestureRecognizer) {
        showFileLoader()
    }

    func showFileSaver()
    {
        let dialog = NSSavePanel();

        dialog.title                   = "Choose a location to save the converted scene";
        dialog.showsResizeIndicator    = true;
        dialog.showsHiddenFiles        = false;
        dialog.canCreateDirectories    = true;
        dialog.allowedFileTypes        = ["scn"];

        if (dialog.runModal() == NSApplication.ModalResponse.OK) {
            let result = dialog.url

            if (result != nil) {
                let path = result!.path
                saveConvertedScene(path: path)
            }
        } else {
            return
        }
    }

    func saveConvertedScene(path: String){
        print("storing scene...")
        // save model
        let success = convertedScene.write(to: URL.init(fileURLWithPath:path), options: nil, delegate: nil) { (totalProgress, error, stop) in
            print("Progress \(totalProgress) Error: \(String(describing: error))")
        }
        print("Success: \(success)")
    }

    func convertCloud(path: String) {
        convertedScene = SCNScene()

        print("loading cloud...")

        let pointcloud = PointCloud()
        pointcloud.load(file: path)
        let cloud = pointcloud.getNode(useColor: true)
        convertedScene.rootNode.addChildNode(cloud)

        print("loaded!")

        showFileSaver()
    }
}
