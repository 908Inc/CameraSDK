//
//  AppDelegate.swift
//  Stamps
//
//  Created by vlad on 10/5/16.
//  Copyright © 2016 908. All rights reserved.
//

import UIKit
import CameraSDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    let storyBuilder = StoryBuilderViewController.storyboardController()
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        storyBuilder.delegate = self
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = storyBuilder
        window?.makeKeyAndVisible()
        storyBuilder.showCamera(true)

        return true
    }
}


extension AppDelegate: StoryBuilderViewControllerDelegate {
    func shareImage(_ image: UIImage, from storyBuilder: StoryBuilderViewController) {
        storyBuilder.present(UIActivityViewController(activityItems: [image], applicationActivities: nil), animated: true)
    }
}
