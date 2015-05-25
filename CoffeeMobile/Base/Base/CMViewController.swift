//
//  CMViewController.swift
//  CoffeeMobile
//
//  Created by 程巍巍 on 5/20/15.
//  Copyright (c) 2015 Littocats. All rights reserved.
//

import UIKit

class CMViewController: UIViewController {
    
    /**
    MARK: 所有 CMViewController (及其子类) 的实例，共用一个 CMContext
    */
    private var GlobalContext = CMJSContext.defaultContext()
    private func compile(#coffee: String)->String {
        var compiler = GlobalContext.evaluateScript("CoffeeScript.compile")
        if compiler.isFunc {
            var js = compiler.callWithArguments([coffee])
            return js.toString()
        }
        return ""
    }
    
    /**
    MARK:
    page context ,  实际上是 GlobalContext 中的一个作用域
    */
    
    var context: CMContext!
    
    /**
    MARK:
    资源路径，javascript, 暂不支持重新载入
    */
    var URI: NSURL! = NSURL(string: "blank://") {
        didSet {
            var err = NSErrorPointer()
            if var source = String(contentsOfURL: URI, encoding: NSUTF8StringEncoding, error: err) {
                if let pathExtension = URI.pathExtension {
                    if pathExtension.lowercaseString == "coffee" {
                        source = compile(coffee: source)
                    }
                }
                var js = "new function(){\(source)}"
                context = CMContext(value: GlobalContext.evaluateScript(js))
            }
            assert(context != nil, "CMViewController error")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        context["viewDidLoad"].toClosure()?()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        context["viewWillAppear"].toClosure()?()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        context["viewDidAppear"].toClosure()?()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        context["viewWillDisappear"].toClosure()?()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        context["viewDidDisappear"].toClosure()?()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
