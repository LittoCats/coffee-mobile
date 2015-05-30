//
//  ViewController.swift
//  CoffeeMobile
//
//  Created by 程巍巍 on 5/20/15.
//  Copyright (c) 2015 Littocats. All rights reserved.
//

import UIKit

class ViewController: CMViewController {
//class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
//        var button = UIButton()
//        button.setTitle("CMConstraint", forState: UIControlState.Normal)
//        button.backgroundColor = UIColor.blackColor()
//        
//        button.sizeToFit()
//        
//        self.view.addSubview(button)
//        
//        CMLayout(button).Top.Equal.to(self.view).Top.constraint(64.1).addTo(self.view)
//        CMLayout(button).Left.Equal.to(self.view).Left.constraint().addTo(self.view)
//        
//        var view = UIView()
//        self.view.addSubview(view)
//        var constraint = CMLayout(view).Top.Equal.to(self.view).Top.constraint(100, 1).addTo(self.view)
//        CMLayout(view).Leading.Equal.to(self.view).Leading.constraint(20, 1).addTo(self.view)
//        CMLayout(view).Height.Equal.constraint(44, 1).addTo(self.view)
//        CMLayout(view).Width.Equal.constraint(120, 1).addTo(self.view)
//        
//        view.backgroundColor = UIColor(hex: "#0088DD")
//
//        button.handle(events: UIControlEvents.TouchUpInside) { [weak self](sender, event) -> Void in
//            UIView.animateWithDuration(1.25, animations: { () -> Void in
//                constraint.constant = CGFloat(arc4random()%480) * (arc4random()%2 > 0 ? -1 : 1)
//                self?.view.layoutIfNeeded()
//            })
//        }

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

