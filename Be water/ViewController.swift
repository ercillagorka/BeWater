//
//  ViewController.swift
//  Be water
//
//  Created by Gorka Ercilla on 2/1/15.
//  Copyright (c) 2015 gorka. All rights reserved.
//

import UIKit
import HealthKit

class ViewController: UIViewController {
    
    let jeightQuantity = HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeight)
    let weightQuantity = HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyMass)
    
    lazy var healthStore = HKHealthStore()
    lazy var typesToShare: NSSet = {
        return NSSet(objects: self.jeightQuantity,
        self.weightQuantity)
    }()
    lazy var typesToRead: NSSet = {
        return NSSet(objects: self.jeightQuantity,
            self.weightQuantity)
        }()
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if HKHealthStore.isHealthDataAvailable(){
            healthStore.requestAuthorizationToShareTypes(typesToShare, readTypes: typesToRead,
                completion: {(succeeded: Bool, error: NSError!) in
                
                if succeeded && error == nil {
                    println("Succesfully authorization")
                } else {
                    if let theError = error{
                        println("Error occurred = \(theError)")
                    }
                }
                
            })
        } else {
            println("Health data is not available")
        }
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    
}

