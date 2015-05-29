//
//  ViewController.swift
//  CoffeeMobile
//
//  Created by 程巍巍 on 5/20/15.
//  Copyright (c) 2015 Littocats. All rights reserved.
//

import UIKit

class ViewController: CMViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        var button = UILabel()
//        button.setTitle("CMConstraint", forState: UIControlState.Normal)
        
        button.sizeToFit()
        
        self.view.addSubview(button)
        
        CMLayout(button).CenterX.Equal.to(self.view).CenterX.constraint().addTo(self.view)
        CMLayout(button).CenterY.Equal.to(self.view).CenterY.constraint().addTo(self.view)
        
        Async.main { () -> Void in
            var attrString = NSAttributedString(xml: "<t size='15' color='#FF0000' stroke='5'>确定</t><t st='1' stcolor='#00FFFF'>我中划线</t>")
            button.attributedText = attrString
        }
        
//        var count = 0
//        CMTimer.timeOut(1.2, repeat: true, userInfo: nil, strict: true, context: button) { (timer) -> (Bool) in
//            println(count++)
//            return false
//        }

//        Async.main(after: 6) { () -> Void in
//            button.removeFromSuperview()
//        }
        var name = "width"
        var script = "root.width-2*3"
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

