//
//  MapViewViewController.swift
//  weChat
//
//  Created by 洪森達 on 2018/7/29.
//  Copyright © 2018年 sen. All rights reserved.
//

import UIKit
import MapKit

class MapViewViewController: UIViewController {

  
    
    @IBOutlet weak var MapView: MKMapView!
    var location:CLLocation!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "MAP"
        setupUI()
        creatRightButton()
    }
    
    //MARK: SetupUI
    
    func setupUI(){
        
        var region = MKCoordinateRegion()
        region.center.longitude = location.coordinate.longitude
         region.center.latitude = location.coordinate.latitude
            region.span.latitudeDelta = 0.01
            region.span.longitudeDelta = 0.01
        MapView.setRegion(region, animated: false)
        MapView.showsUserLocation = true
        let annotation = MKPointAnnotation()
            annotation.coordinate = location.coordinate
            MapView.addAnnotation(annotation)
    }
    
    
    func creatRightButton(){
        
        self.navigationItem.rightBarButtonItems = [UIBarButtonItem(title: "Open in Maps", style: .plain, target: self, action: #selector(self.openInMap))]
    }

    
    
    @objc func openInMap(){
    
        let regionDestination : CLLocationDistance = 10000
        let coordinates = location.coordinate
        let regionSpan = MKCoordinateRegion(center: coordinates, latitudinalMeters: regionDestination, longitudinalMeters: regionDestination)
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
             MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
        ]
        
        let placeMark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placeMark)
        mapItem.name = "User's Locaton"
        mapItem.openInMaps(launchOptions: options)
    
    
    }
}
