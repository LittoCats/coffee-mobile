//
//  CMRouter.swift
//  CoffeeMobile
//
//  Created by 程巍巍 on 5/20/15.
//  Copyright (c) 2015 Littocats. All rights reserved.
//

import Foundation

protocol CMRouterProtocol {
    func dispatch(#event: CMRouter.Event, context: AnyObject?)
}
struct CMRouter {
    typealias Event = NSURL
    
    private static var RouterMap: [String: protocol<CMRouterProtocol>] = [
        "CMCT": CTRouter(),         // control 主要负责页面的跳转
        "CMCM": CommandRouter()     // command  负责与界面无关的功能
    ]
    
    static func post(event: Event, params: [String: AnyObject]? = nil, context: AnyObject? = nil) {
        var URL = event
        if params != nil {
            if let URLComponents = NSURLComponents(URL: URL, resolvingAgainstBaseURL: false) {
                URLComponents.percentEncodedQuery = (URLComponents.percentEncodedQuery != nil ? URLComponents.percentEncodedQuery! + "&" : "") + NSURL.QueryParser.query(params!)
                URL = URLComponents.URL!
            }
        }
        
        if let scheme = URL.scheme {
            if let router = RouterMap[scheme.uppercaseString] {
                router.dispatch(event: URL, context: context)
            }
        }
    }
    
    static func register(#router: protocol<CMRouterProtocol>, withScheme scheme: String) ->Bool{
        RouterMap[scheme] = router
        return true
    }
}

extension CMRouter {
    struct CTRouter: CMRouterProtocol {
        init(){
            CMRouter.register(router: self, withScheme: "HTTPS")
            CMRouter.register(router: self, withScheme: "HTTP")
        }
        func dispatch(#event: CMRouter.Event, context: AnyObject?){
            if let scheme = event.scheme {
                
            }
        }
    }
}

extension CMRouter {
    struct CommandRouter: CMRouterProtocol {
        func dispatch(#event: CMRouter.Event, context: AnyObject?){
            
        }
    }
}