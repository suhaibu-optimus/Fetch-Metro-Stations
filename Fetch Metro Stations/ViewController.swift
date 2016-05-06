//
//  ViewController.swift
//  Fetch Metro Stations
//
//  Created by Suhaib Umar on 4/21/16.
//  Copyright © 2016 Suhaib. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate {

    
    @IBOutlet var mapView: MKMapView!
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var myLocation = CLLocationCoordinate2D()
    var myPresentLocation = CLLocationCoordinate2D()
    var stationsNameArray : NSArray = NSArray()
    var stationsDistanceArray : NSDictionary = NSDictionary()
    var stationsImageArray : NSMutableArray = NSMutableArray()
    var calloutView : UIView = UIView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        myLocation = appDelegate.myLocation
        self.reconfigureView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
   
    override func viewDidAppear(animated: Bool) {
        myPresentLocation = appDelegate.myLocation
        if !(myLocation.latitude == myPresentLocation.latitude && myLocation.longitude == myPresentLocation.longitude) {
            myLocation = myPresentLocation
            self.reconfigureView()
        }
        mapView.setRegion(MKCoordinateRegionMakeWithDistance(myLocation, 10000, 10000), animated: true)
    }
    
    //function to reconfigure the map
    func reconfigureView() {
        mapView.removeAnnotations(mapView.annotations)
        stationsNameArray = appDelegate.stationsNameArray
        stationsDistanceArray = appDelegate.stationsDistanceArray
        stationsImageArray = appDelegate.stationsImageArray
        let dropPin = MKPointAnnotation()
        dropPin.coordinate = myLocation
        dropPin.title = "My Present Location"
        mapView.addAnnotation(dropPin)
        self.addMapAnnotations()
    }
    
    //function to add the annotation
    func addMapAnnotations() {
        for var i = 0; i < stationsNameArray.count; i++ {
            let dropPin = CustomAnnotation()
            let latitude = stationsNameArray.objectAtIndex(i).objectForKey("geometry")?.objectForKey("location")?.objectForKey("lat")!
            let longitude = stationsNameArray.objectAtIndex(i).objectForKey("geometry")?.objectForKey("location")?.objectForKey("lng")!
            let coordinate = CLLocationCoordinate2DMake(latitude as! Double, longitude as! Double)
            dropPin.coordinate = coordinate
            dropPin.number = i
            mapView.addAnnotation(dropPin)
        }
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        //set the view of annotation
        if annotation.isKindOfClass(CustomAnnotation) {
            let myLocation = annotation as! CustomAnnotation
            myLocation.title = stationsNameArray.objectAtIndex(myLocation.number!).objectForKey("name")! as? String
            myLocation.subtitle = "Driving Distance is : \((stationsDistanceArray.objectForKey("rows")!.objectAtIndex(0).objectForKey("elements")!.objectAtIndex(myLocation.number!).objectForKey("distance")!.objectForKey("text")!) as! String)"
            var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier("CustomAnnotation")
            if (annotationView == nil) {
                annotationView = myLocation.annotationView()
            }
            else {
                annotationView!.annotation = annotation;
            }
            annotationView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
            return annotationView;
        }
        else {
            return nil
        }
    }

    
    //function to handle the callout button click
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if !view.annotation!.isKindOfClass(CustomAnnotation) {
            return
        }
        let annotationTapped: CustomAnnotation = (view.annotation as! CustomAnnotation)
        self.performSegueWithIdentifier("detailsView", sender: annotationTapped)
    }
   
    //function for preparing for passing data to detailsview page
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "detailsView") {
            let destination = segue.destinationViewController as! DetailsViewController
            if ((sender as? UIButton) != nil) {
                destination.name = (stationsNameArray.objectAtIndex(sender.tag).objectForKey("name")! as? String)!
                destination.address = "Station Address is : \((stationsDistanceArray.objectForKey("destination_addresses")!.objectAtIndex(sender.tag)) as! String)"
                destination.distance = "Driving Distance is : \((stationsDistanceArray.objectForKey("rows")!.objectAtIndex(0).objectForKey("elements")!.objectAtIndex(sender.tag).objectForKey("distance")!.objectForKey("text")!) as! String)"
            }
            else {
                let sendBy = sender as! CustomAnnotation
                destination.name = (sender.title!)!
                destination.distance = (sender.subtitle!)!
                destination.address = "Station Address is : \((stationsDistanceArray.objectForKey("destination_addresses")!.objectAtIndex(sendBy.number!)) as! String)"
            }
        }
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        if view.annotation!.isKindOfClass(CustomAnnotation) {
            let myLocation = view.annotation as! CustomAnnotation
            //image view
            let imageView : UIImageView = UIImageView(frame:CGRectMake(10, 10, 50, 50))
            imageView.image = stationsImageArray.objectAtIndex(myLocation.number!) as? UIImage
            imageView.backgroundColor = UIColor.whiteColor()
            
            //title
            let title: UILabel = UILabel(frame: CGRectMake(imageView.frame.origin.x + 60, 10, 300, 20))
            title.textColor = UIColor.blackColor()
            title.numberOfLines = 0
            title.font = UIFont(name: "Arial-BoldMT", size: 15)
            title.text = "\((stationsNameArray.objectAtIndex(myLocation.number!).objectForKey("name")!) as! String) Metro Station"
            title.sizeToFit()
            title.backgroundColor = UIColor(red: 0, green: 1, blue: 0, alpha: 1)
            
            //subtitle
            let subTitle: UILabel = UILabel(frame: CGRectMake(title.frame.origin.x, title.frame.size.height + 10, 300, 20))
            subTitle.text = "Driving Distance is : \((stationsDistanceArray.objectForKey("rows")!.objectAtIndex(0).objectForKey("elements")!.objectAtIndex(myLocation.number!).objectForKey("distance")!.objectForKey("text")!) as! String)"
            subTitle.font = UIFont(name: "Arial", size: 14)
            subTitle.backgroundColor = UIColor(red: 1, green: 0, blue: 0, alpha: 1)
            subTitle.textColor = UIColor.whiteColor()
            subTitle.sizeToFit()
            if (title.frame.size.width > subTitle.frame.size.width) {
                subTitle.frame.size.width = title.frame.size.width
            }
            else {
                title.frame.size.width = subTitle.frame.size.width
            }
            
            //button
            let button: UIButton = UIButton(type: .RoundedRect)
            button.setTitle("Details View", forState: .Normal)
            button.frame = CGRectMake((title.frame.size.width + imageView.frame.size.width - 60 )/2, title.frame.size.height + subTitle.frame.size.height + 20 , 90, 20)
            button.setTitleColor(UIColor.blackColor(), forState: .Normal)
            button.backgroundColor = UIColor.whiteColor()
            button.tag = myLocation.number!
            button.addTarget(self, action: "annotationButtonTapped:", forControlEvents: .TouchUpInside)
            
            //callout view
            let calloutSize: CGSize = CGSizeMake(title.frame.size.width + imageView.frame.size.width + 30, title.frame.size.height + subTitle.frame.size.height + 50)
            calloutView = UIView(frame: CGRectMake((view.frame.origin.x) / 2 - 20, view.frame.origin.y - calloutSize.height, calloutSize.width, calloutSize.height))
            calloutView.backgroundColor = UIColor(red: 0.5, green: 0.8, blue: 1, alpha: 0.5)
            calloutView.layer.cornerRadius = 15
            calloutView.clipsToBounds = true
            calloutView.addSubview(imageView)
            calloutView.addSubview(title)
            calloutView.addSubview(subTitle)
            calloutView.addSubview(button)
            if (calloutView.frame.size.height > view.frame.origin.y) {
                calloutView.frame.origin.y = view.frame.origin.y + 15
            }
            if (calloutView.frame.size.width > (UIScreen.mainScreen().bounds.width - calloutView.frame.origin.x)) {
                calloutView.frame.origin.x = UIScreen.mainScreen().bounds.width - calloutView.frame.size.width
            }
            if (calloutView.frame.origin.x < 0) {
                calloutView.frame.origin.x = 2
            }
            
            mapView.addSubview(calloutView)
        }
    }
    
    func annotationButtonTapped(sender:UIButton) {
        self.performSegueWithIdentifier("detailsView", sender: sender)
    }
    
    func mapView(mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        calloutView.removeFromSuperview()
        if (mapView.selectedAnnotations.count > 0) {
            mapView.deselectAnnotation(mapView.selectedAnnotations[0], animated: true)
        }
    }
    
    func mapView(mapView: MKMapView, didDeselectAnnotationView view: MKAnnotationView) {
        calloutView.removeFromSuperview()
    }
    
    func setImageSize(image: UIImage) -> UIImage {
        UIGraphicsBeginImageContext(CGSizeMake(50, 50))
        image.drawInRect(CGRectMake(10, 10, 50, 50))
        let destImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return destImage
    }
}