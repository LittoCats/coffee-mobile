//
//  ViewController.swift
//  CoffeeMobile
//
//  Created by 程巍巍 on 5/20/15.
//  Copyright (c) 2015 Littocats. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        var button = UIButton.buttonWithType(UIButtonType.System) as! UIButton
        button.setTitle("CMConstraint", forState: UIControlState.Normal)
        
        button.backgroundColor = UIColor.yellowColor()
        button.sizeToFit()
        
        self.view.addSubview(button)
        
        CMLayout(button).CenterX.Equal.to(self.view).CenterX.constraint().addTo(self.view)
        CMLayout(button).CenterY.Equal.to(self.view).CenterY.constraint().addTo(self.view)
    }
    
    
    func read() {
        println("un zip")
        var zip = CMZip.File(fileName: NSTemporaryDirectory().stringByAppendingPathComponent("cm_app.zip"), mode: CMZip.File.Mode.Unzip)
        var list = zip.fileList
        println("file list : \(list)")
        
        zip.close()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

