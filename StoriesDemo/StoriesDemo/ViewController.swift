//
//  ViewController.swift
//  StoriesDemo
//
//  Created by vlad on 4/4/17.
//  Copyright © 2017 908. All rights reserved.
//

import UIKit
import CameraSDK

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        show(StoryBuilderViewController.storyboardController(), sender: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
