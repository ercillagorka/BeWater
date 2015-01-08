import UIKit
import HealthKit

class ViewController: UIViewController, UIPageViewControllerDataSource{

    /** PageViewController **/
    private var myPageViewController: UIPageViewController?
    private let contentImages = ["nature_pic_1.png",
        "nature_pic_2.png",
        "nature_pic_2.png",
        "nature_pic_2.png",]
    
    /** HealthKit**/
    lazy var healthStore = HKHealthStore()
    let weightQuantity = HKQuantityType.quantityTypeForIdentifier(
        HKQuantityTypeIdentifierBodyMass)
    lazy var typesToRead: NSSet = {
        return NSSet(objects:self.weightQuantity)
        }()
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        createPageViewController()
        setupPageControl()
    }
    
    private func createPageViewController() {
        
        let pageController = self.storyboard!.instantiateViewControllerWithIdentifier("PageController") as UIPageViewController
        pageController.dataSource = self
        
        if contentImages.count > 0 {
            let firstController = getItemController(0)!
            let startingViewControllers: NSArray = [firstController]
            pageController.setViewControllers(
                startingViewControllers,
                direction: UIPageViewControllerNavigationDirection.Forward,
                animated: false,
                completion: nil)
        }
        
        myPageViewController = pageController
        addChildViewController(myPageViewController!)
        self.view.addSubview(myPageViewController!.view)
        myPageViewController!.didMoveToParentViewController(self)
    }
    
    private func setupPageControl() {
        let appearance = UIPageControl.appearance()
        appearance.pageIndicatorTintColor = UIColor.grayColor()
        appearance.currentPageIndicatorTintColor = UIColor.whiteColor()
        appearance.backgroundColor = UIColor.darkGrayColor()
    }
    
    // MARK: - UIPageViewControllerDataSource
    
    func pageViewController(pageViewController: UIPageViewController,
        viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        
        let itemController = viewController as PageItemController
        if itemController.itemIndex > 0 {
            return getItemController(itemController.itemIndex-1)
        }
        
        return nil
    }
    
    func pageViewController(pageViewController: UIPageViewController,
        viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        
        let itemController = viewController as PageItemController
        if itemController.itemIndex+1 < contentImages.count {
            if(itemController.itemIndex == 1){
                askPermissionToAccessHealthStore()
            }
            return getItemController(itemController.itemIndex+1)
        }else{
            for view in self.view.subviews {
                view.removeFromSuperview()
            }
        }
        
        return nil
    }
    
    private func getItemController(itemIndex: Int) -> PageItemController? {
        if itemIndex < contentImages.count {
            let pageItemController = self.storyboard!.instantiateViewControllerWithIdentifier("ItemController") as PageItemController
            pageItemController.itemIndex = itemIndex
            pageItemController.imageName = contentImages[itemIndex]
            return pageItemController
        }
        return nil
    }
    
    // MARK: - Page Indicator
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return contentImages.count
    }

    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 0
    }
    
    func askPermissionToAccessHealthStore(){
        if HKHealthStore.isHealthDataAvailable(){
            healthStore.requestAuthorizationToShareTypes(nil,
                readTypes: typesToRead,
                completion: {(succeeded: Bool, error: NSError!) in
                    
                    if succeeded && error == nil{
                        println("Successfully received authorization")
                    } else {
                        if let theError = error{
                            println("Error occurred = \(theError)")
                            if(theError.code == 7){
                                let alert = UIAlertController(
                                    title: nil,
                                    message: "Sin esta informacion no se podra calcular el agua diaria",
                                    preferredStyle: UIAlertControllerStyle.Alert)
                                
                                alert.addAction(UIAlertAction(
                                    title: "OK",
                                    style: UIAlertActionStyle.Default,
                                    handler: self.callPermission))
                                
                                alert.addAction(UIAlertAction(
                                    title: "NO",
                                    style: UIAlertActionStyle.Cancel,
                                    handler: nil))
                                
                                self.presentViewController(alert, animated: true, completion: nil)
                            }
                        }
                    }
                    
            })
            
        } else {
            println("Health data is not available")
        }
    }
    
    func callPermission(act:UIAlertAction!){
        askPermissionToAccessHealthStore()
    }
    
}

