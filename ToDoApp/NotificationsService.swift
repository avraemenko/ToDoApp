//
//  NotificationsService.swift
//  ToDoApp
//
//  Created by Kateryna Avramenko on 21.11.22.
//

import Foundation
import UserNotifications
import UIKit

final class NotificationsService : NSObject {
    
    enum Error : Swift.Error {
        case invalidKey
    }
    
    enum NotificationType {
        
        case remote
        case local
        
    }
    
    private class Handler {
        
        var key: String
        var handler: (Any) -> ()
        
        init(key: String, _ handler: @escaping (Any) -> ()) {
            self.key = key
            self.handler = handler
        }
        
    }
    
    private var mapOfSubscribers : NSMapTable<AnyObject, Handler> = .weakToStrongObjects()
    static var shared : NotificationsService = .init()
    
    private var center = UNUserNotificationCenter.current()
    
    override init() {
        super.init()
    }
    
    
    func authorize(_ options: UNAuthorizationOptions, for type: NotificationType, completion : ((Bool) -> ())? = nil){
        center.requestAuthorization(options: options) { granted, _ in
            if type == .remote && granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
            completion?(granted)
        }
        
    }
    
    @discardableResult
    func decode<T: Decodable>(_ type: T.Type, by key: String, from userInfo: [AnyHashable : Any]) throws -> T {
       
        if let object = userInfo[key] {
            let data = try JSONSerialization.data(withJSONObject: object)
            let result = try JSONDecoder().decode(type, from: data)
            
            (mapOfSubscribers.objectEnumerator()?.allObjects.first(where: { ($0 as? Handler)?.key == key }) as? Handler)?.handler(result)
            
            return result
        }
        
        throw Error.invalidKey
    }
    
    func showLocal(_ userInfo: [AnyHashable : Any]) {
        let alertJSON = (userInfo["aps"] as? [String : Any])?["alert"] as? [String : String]
        
        let content = UNMutableNotificationContent()
        content.title = alertJSON?["title"] ?? ""
        content.subtitle = alertJSON?["subtitle"] ?? ""
        content.body = alertJSON?["body"] ?? ""
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
        
        //request
        
        //add reques do notificationCeter
        
        //....
     }
    
    func addListener(_ listener: AnyObject, for key: String, handler: @escaping (Any) -> ()) {
        mapOfSubscribers.setObject(Handler(key: key, handler), forKey: listener)
    }
    
    
   
}

extension NotificationsService : UNUserNotificationCenterDelegate {
    
}
