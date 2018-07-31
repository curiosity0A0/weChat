//
//  AppDelegate.swift
//  weChat
//
//  Created by 洪森達 on 2018/7/13.
//  Copyright © 2018年 sen. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var authListener: AuthStateDidChangeListenerHandle?
    var locationManager: CLLocationManager?
    var coordinates: CLLocationCoordinate2D?

    internal func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
         locationManagerStart()
            self.window?.backgroundColor = .white
         Thread.sleep(forTimeInterval: 2.0)
        //AutoLogin
        authListener = Auth.auth().addStateDidChangeListener({ (auth, user) in
            
            Auth.auth().removeStateDidChangeListener(self.authListener!)
            
            if user != nil {
                
                if UserDefaults.standard.object(forKey: kCURRENTUSER) != nil {
                    
                    DispatchQueue.main.async {
                            
                          self.goToApp()
                    }
               
                }
                
            }

        })

        
        return true
    }
    
    

    func applicationDidEnterBackground(_ application: UIApplication) {
        locationManagerStop()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        locationManagerStart()
    }
    
    //MARKL GOTOAPP
    func goToApp(){
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: USER_DID_LOGIN_NOTIFICATION), object: nil, userInfo: [kUSERID:FUser.currentId()])
        let vc  = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainVC") as! UITabBarController
        self.window?.rootViewController = vc
    }

}

extension AppDelegate: CLLocationManagerDelegate {
    
    //NARK: Location Manager
    func locationManagerStart(){
        if locationManager == nil {
            locationManager = CLLocationManager()
            locationManager!.delegate = self
            locationManager!.desiredAccuracy = kCLLocationAccuracyBest
            locationManager!.requestWhenInUseAuthorization()
        }
        locationManager!.startUpdatingLocation()
    }
    
    func locationManagerStop(){
        if locationManager != nil {
            locationManager!.stopUpdatingLocation()
        }
    }
    //MARK: DELEGATE
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("faild to get location\(error.localizedDescription)")
        
        
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        switch status {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse:
            manager.startUpdatingLocation()
        case .authorizedAlways:
            manager.startUpdatingLocation()
        case .restricted:
            print("restricted")
        case .denied:
           locationManager = nil
           print("denied location access")
            break
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        coordinates = locations.last!.coordinate
        
    }
    

}
