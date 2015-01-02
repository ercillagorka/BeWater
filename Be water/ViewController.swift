import UIKit
import HealthKit

class ViewController: UIViewController {
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    @IBAction func saveUserWeight() {
        let kilogramUnit = HKUnit.gramUnitWithMetricPrefix(HKMetricPrefix.Kilo)
        let weightQuantity = HKQuantity(unit: kilogramUnit,
            doubleValue: (textField.text as NSString).doubleValue)
        let now = NSDate()
        let sample = HKQuantitySample(type: weightQuantityType,
            quantity: weightQuantity,
            startDate: now,
            endDate: now)
        
        healthStore.saveObject(sample, withCompletion:{
            (succeeded: Bool, error: NSError!) in
            if error == nil{
                println("Successfully saved the user's weight")
            } else{
                println("Failed to save the user's weight")
            }
            })
    }
    
    let textFieldRightLabel = UILabel(frame: CGRectZero)
    let weightQuantityType = HKQuantityType.quantityTypeForIdentifier(
        HKQuantityTypeIdentifierBodyMass)
    
    lazy var types: NSSet = {
        return NSSet(object: self.weightQuantityType)
    }()
    
    lazy var healthStore = HKHealthStore()
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if HKHealthStore.isHealthDataAvailable(){
            healthStore.requestAuthorizationToShareTypes(types, readTypes: types,
                completion: {[weak self]
                    (succeeded: Bool, error: NSError!) in
                let strongSelf = self!
                if succeeded && error == nil {
                    println("Succesfully authorization")
                    dispatch_async(dispatch_get_main_queue(), strongSelf.readWeightInformation)
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
        textField.rightView = textFieldRightLabel
        textField.rightViewMode = UITextFieldViewMode.Always
    }
    
    func textFieldShouldReturn(textField: UITextField!) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func readWeightInformation(){
        let sortDescription = NSSortDescriptor(key: HKSampleSortIdentifierEndDate,
            ascending: false)
        let query = HKSampleQuery(sampleType: weightQuantityType,
            predicate: nil,
            limit: 1,
            sortDescriptors: [sortDescription],
            resultsHandler: {[weak self] (query: HKSampleQuery!,
                results: [AnyObject]!,
                error: NSError!) in
            
            if results.count > 0{
                let sample = results[0] as HKQuantitySample
                let weightInKilograms = sample.quantity.doubleValueForUnit(HKUnit.gramUnitWithMetricPrefix(HKMetricPrefix.Kilo))
                
                let formatter = NSMassFormatter()
                let kilogramSuffix = formatter.unitStringFromValue(weightInKilograms, unit: NSMassFormatterUnit.Kilogram)
                dispatch_async(dispatch_get_main_queue(),{
                    let strongSelf = self!
                    strongSelf.textFieldRightLabel.text = kilogramSuffix
                    strongSelf.textFieldRightLabel.sizeToFit()
                    
                    let weightFormattedAsString = NSNumberFormatter.localizedStringFromNumber(
                        NSNumber (double: weightInKilograms),
                        numberStyle: NSNumberFormatterStyle.NoStyle)
                    strongSelf.textField.text = weightFormattedAsString
                    
                    })
            }else {
                println("Could not read the user's weght ")
                println("or no weight data was available ")
                
            }
            })
        healthStore.executeQuery(query)
    }
    
}

