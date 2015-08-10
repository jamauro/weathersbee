//
//  ViewController.swift
//  WeatherFeel
//
//  Created by John Mauro on 7/14/15.
//  Copyright (c) 2015 John Mauro. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate, UIGestureRecognizerDelegate {
  @IBOutlet var realFeelLabel: UILabelNonClipping!
  @IBOutlet var summaryLabel: UILabel!
  @IBOutlet var realFeelTempLabel: UILabel!
  @IBOutlet var temperatureView: UIView!
  @IBOutlet var ambientTempLabel: UILabel!
  @IBOutlet var hiTempLabel: UILabel!
  @IBOutlet var lowTempLabel: UILabel!
  @IBOutlet var windLabel: UILabel!
  @IBOutlet var humidityLabel: UILabel!
  @IBOutlet var uvIndexLabel: UILabel!
  @IBOutlet var currentConditionsView: UIView!
  
  @IBOutlet var currentWeatherIcon: UIImageView!
  @IBOutlet var windIcon: UIImageView!
  @IBOutlet var humidityIcon: UIImageView!
  @IBOutlet var uvIcon: UIImageView!
  @IBOutlet var divider: UIView!
  @IBOutlet var winkView: UIImageView!
  
  @IBOutlet var weathersbeeTitle: UIImageView!
  var locationManager = CLLocationManager()
  var locationFixAchieved: Bool = false
  var previousLocation: CLLocation!
  // var latitude: CLLocationDegrees! = 37.9392
  // var longitude: CLLocationDegrees! = -107.8163
  var postalCode: String!
  
  var realFeel = ""
  var realFeelTemp = Int()
  var ambientTemp = Int()
  var hiTemp = Int()
  var lowTemp = Int()
  var windSpeed = Int()
  var windDirection = ""
  var humidity = Int()
  var icon = ""
  var todaySummary = ""
  var todayPrecipProb: Double!
  var hourlySummary = ""
  var recommendation = ""
  
  let minUVForNotice: Int = 5
  let minUVForExtreme: Int = 10
  var maxUVIndex = 0
  var maxUVTime = ""
  var lastUVIndexHour: Int = 0
  var uvByTime = [String: Int]()
  
  var currentDate = NSDate()
  var userCalendar: NSCalendar = NSCalendar.currentCalendar()
  var comps: NSDateComponents!
  var currentHour: Int!
  var formatter = NSDateFormatter()
  var uvChecked: NSDate = NSDate(timeIntervalSince1970: 0)
  
  // Temperature colors
  let scorcherColor = UIColor(hex: 0xFE324A) // or 0xF73C4B or 0xFE3241
  let hotColor = UIColor(hex: 0xFF7033)
  let warmColor = UIColor(hex: 0xFFA333)
  let perfectColor = UIColor(hex: 0xFFE033)
  let niceColor = UIColor(hex: 0x31F988)
  let coolColor = UIColor(hex: 0x33E5F6)
  let chillyColor = UIColor(hex: 0x3CB1F7)
  let coldColor = UIColor(hex: 0x4389F8)
  let freezingColor = UIColor(hex: 0x4A65F8)
  let bitterlycoldColor = UIColor(hex: 0x6B49F8)
  let subzeroColor = UIColor(hex: 0x8A43F8)
  
  // Prevent italic display font from being cut off
  let realFeelLabelColor = UIColor(hex: 0x727C83) // 0x858F96  or  0x727C83
  var displayFont: UIFont!
  // var paragraphStyle = NSMutableParagraphStyle()
  var attributes: NSDictionary!
  
  var flick: UIPanGestureRecognizer!
  var longPress: UILongPressGestureRecognizer!
  var bounceViewCount: Int = 0
  var constraintTemperatureViewHeight: NSLayoutConstraint!

  override func viewDidLoad() {
    super.viewDidLoad()
    temperatureView.hidden = true
    ambientTempLabel.hidden = true
    hiTempLabel.hidden = true
    lowTempLabel.hidden = true
    windLabel.hidden = true
    humidityLabel.hidden = true
    uvIndexLabel.hidden = true
    currentConditionsView.hidden = true
    
    currentWeatherIcon.hidden = true
    windIcon.hidden = true
    humidityIcon.hidden = true
    uvIcon.hidden = true
    divider.hidden = true
    
    let screenSize: CGRect = UIScreen.mainScreen().bounds
    constraintTemperatureViewHeight = NSLayoutConstraint (item: temperatureView,
      attribute: NSLayoutAttribute.Height,
      relatedBy: NSLayoutRelation.Equal,
      toItem: nil,
      attribute: NSLayoutAttribute.NotAnAttribute,
      multiplier: 1,
      constant: round(screenSize.height / 3))
    self.view.addConstraint(constraintTemperatureViewHeight)
    
    // Do any additional setup after loading the view, typically from a nib.
    animateWink()
    // Get the location data
    locationManager.delegate = self
    locationManager.distanceFilter = 100.0
    locationManager.desiredAccuracy = kCLLocationAccuracyBest
    locationManager.requestWhenInUseAuthorization()
    // locationManager.startUpdatingLocation()
    
    

    

    // Prevent italic display font from being cut off
    displayFont = UIFont(name: "PlayfairDisplay-Italic", size: 36)!
    // paragraphStyle.lineHeightMultiple = 0.95
    attributes = [NSFontAttributeName: displayFont, NSForegroundColorAttributeName: realFeelLabelColor] // , NSParagraphStyleAttributeName: paragraphStyle
    /*
    var initialString = "Retrieving the weather bits for you..."
    
    

    realFeelLabel.attributedText = NSMutableAttributedString(string: initialString as String, attributes: attributes as [NSObject : AnyObject])
    */
    
    // currentConditionsView.hidden = true
    formatter.dateStyle = .MediumStyle //time
    // print(formatter.stringFromDate(currentDate))
    
    // get the current hour
    comps = userCalendar.components(.CalendarUnitHour, fromDate: currentDate)
    currentHour = comps.hour
    
    
  
    flick = UIPanGestureRecognizer(target: self, action: "handleFlick:")
    flick.delegate = self
    temperatureView.addGestureRecognizer(flick)
    
    longPress = UILongPressGestureRecognizer(target: self, action: "handleLongPress:")
    longPress.delegate = self
    self.view.addGestureRecognizer(longPress)
    
    
    // Update data when app enters foreground
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshData:", name: "refreshData", object: nil)
    
    // Store the initial bounce view count of 0
    NSUserDefaults.standardUserDefaults().setInteger(bounceViewCount, forKey: "bounceViewCount")
    
  }
  
  func animateWink() {
    winkView.animationImages = [UIImage(named: "wink.png")!, UIImage(named: "launch.png")!]
    
    winkView.animationDuration = 0.4
   
    winkView.animationRepeatCount = 2
    
    winkView.startAnimating()
    
    //locationManager.startUpdatingLocation()
    
    UIView.animateWithDuration(0.4, delay: 1.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 1.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
      //self.winkView.stopAnimating()
      self.winkView.transform = CGAffineTransformConcat(CGAffineTransformMakeScale(0.4, 0.4), CGAffineTransformMakeTranslation(0, -160))
      // self.winkView.transform =
      // self.winkView.transform =
      
      //self.locationManager.startUpdatingLocation()
      self.weathersbeeTitle.alpha = 0.0
      /*
      UIView.animateWithDuration(0.4, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 1.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
        self.weathersbeeTitle.alpha = 0.0
      }, completion: { (complete) -> Void in
        self.weathersbeeTitle.hidden = true
      })
      */
      
      
    }) { (complete) -> Void in
      self.weathersbeeTitle.hidden = true
      self.locationManager.startUpdatingLocation()
      
      // Prevent italic display font from being cut off
      
      if self.realFeelLabel.text == "" {
        var initialString = "Fetching those weather bits..." //
        // self.displayFont = UIFont(name: "PlayfairDisplay-Italic", size: 36)!
        // self.attributes = [NSFontAttributeName: self.displayFont, NSForegroundColorAttributeName: self.realFeelLabelColor]
        self.realFeelLabel.attributedText = NSMutableAttributedString(string: initialString as String, attributes: self.attributes as [NSObject : AnyObject])
      }
      
      if self.summaryLabel.text == "" {
        self.summaryLabel.text = "One moment please..."
      }
      
      self.temperatureView.hidden = false
      self.ambientTempLabel.hidden = false
      self.hiTempLabel.hidden = false
      self.lowTempLabel.hidden = false
      self.windLabel.hidden = false
      self.humidityLabel.hidden = false
      self.uvIndexLabel.hidden = false
      self.currentConditionsView.hidden = false
      
      self.currentWeatherIcon.hidden = false
      self.windIcon.hidden = false
      self.humidityIcon.hidden = false
      self.uvIcon.hidden = false
      self.divider.hidden = false
      
    }
    
    
  }
  
  override func viewDidAppear(animated: Bool) {
    
    
    /*
    
    winkView.animationImages = [UIImage(named: "launch.png")!, UIImage(named: "wink.png")!, UIImage(named: "launch.png")!]
  
    winkView.animationDuration = 0.5
    
    winkView.startAnimating()
    
    winkView.hidden = true
    */
    /*
    UIView.animateWithDuration(5.0, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
      
      self.winkView.image = UIImage(named: "wink.png")
      
      }) { (complete) -> Void in
        
        
        UIView.animateWithDuration(5.0, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
          
          self.winkView.image = UIImage(named: "launch.png")
          
          }) { (complete) -> Void in
            
            self.winkView.hidden = true
            
            self.locationManager.startUpdatingLocation()
            // Prevent italic display font from being cut off
            var initialString = "Retrieving the weather bits for you..."
            self.displayFont = UIFont(name: "PlayfairDisplay-Italic", size: 36)!
            self.attributes = [NSFontAttributeName: self.displayFont, NSForegroundColorAttributeName: self.realFeelLabelColor]
            self.realFeelLabel.attributedText = NSMutableAttributedString(string: initialString as String, attributes: self.attributes as [NSObject : AnyObject])
        }
        
    } 
    */
  }
  
  // swift 2 can have notification: NSNotification? = nil
  // this func will be called initially and any time app enters foreground
  func refreshData(notification: NSNotification?) {
    // get the current hour
    comps = userCalendar.components(.CalendarUnitHour, fromDate: currentDate)
    currentHour = comps.hour
    
    locationManager.startUpdatingLocation()
  }
  
  func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
    
    // Start the spinner in the status bar
    UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    
    var userLocation: CLLocation = locations[0] as! CLLocation
    print(" got location ")
    // if (userLocation.horizontalAccuracy > 0) {
      locationManager.stopUpdatingLocation()

      // get pressure via forecast API
      // swift 2: can remove nil
      getWeatherConditions(userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
      
      print("previous location: \(previousLocation)")
      
      
      // only get the UVindex if it hasn't already been checked or if you've moved a lot
      print(" uvChecked has NOT been checked today: \(!userCalendar.isDateInToday(uvChecked)) ")
      if (previousLocation == nil || userLocation.distanceFromLocation(previousLocation) > 1000) || (!userCalendar.isDateInToday(uvChecked)) {
        print(" new location is more than 1000m from current or UVindex hasn't been checked today ")
        // get the nearest address
        CLGeocoder().reverseGeocodeLocation(userLocation, completionHandler: { (placemarks, error) -> Void in
          
          if (error != nil) {
            println(error)
          } else {
            if let p = CLPlacemark(placemark: placemarks?[0] as! CLPlacemark) {
              print(" postal code: \(p.postalCode) ")
              print(" city is: \(p.locality) ")
              self.postalCode = p.postalCode
              
              self.getUVIndex(self.postalCode)
            }
          }
          
        })

      } else {
        print(" new location is close to previous ")
      }
      
      previousLocation = userLocation
      
      // update UV label
      if !uvByTime.isEmpty {
        print(" setting the UV ")
        uvIndexLabel.text = "\(uvByTime[format12H(currentHour)]!)"
      }
      
    //}
    
    
  }
  
  func bounceView() {
    UIView.animateWithDuration(0.2, delay: 2.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 1.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
      
      self.temperatureView.transform = CGAffineTransformMakeTranslation(0, -20)
      
      }) { (complete) -> Void in
        
        // print("bottom view moved up")
        UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 0.3, initialSpringVelocity: 0.8, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
          
          self.temperatureView.transform = CGAffineTransformIdentity
          
          }) { (complete) -> Void in
            
            // print("bottom view moved up")
        }

    }
    
    
  }
  
  
  func handleFlick(gesture: UIPanGestureRecognizer) {
    
      var translation = gesture.translationInView(temperatureView)
      if translation.y < 0 {
        
       // self.temperatureView.transform = CGAffineTransformMakeTranslation(0, translation.y)
        
        
        UIView.animateWithDuration(0.25, delay: 0.0, usingSpringWithDamping: 0.9, initialSpringVelocity: 2.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
          
          self.temperatureView.transform = CGAffineTransformMakeTranslation(0, -self.currentConditionsView.frame.height)
        
          }) { (complete) -> Void in
            
            // print("bottom view moved up")
        }
        
        
      } else if translation.y > 0 {
        UIView.animateWithDuration(0.25, delay: 0.0, usingSpringWithDamping: 0.9, initialSpringVelocity: 2.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
          
           self.temperatureView.transform = CGAffineTransformIdentity
          // self.temperatureView.transform = CGAffineTransformTranslate(self.temperatureView.transform, 0, 110)
          // self.currentConditionsView.hidden = false
          }) { (complete) -> Void in
            
            // print("bottom view moved down")
        }
      }

  
  }
  
  func handleLongPress(gesture: UILongPressGestureRecognizer) {
    print(" i was long pressed ")
    
    let image = takeScreenShot()
    let textToShare: String = "via weathersbee. Download here: "
    
    let objectsToShare = [image, textToShare]
    let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
      
      //Excluded Activities
      activityVC.excludedActivityTypes = [UIActivityTypeAirDrop, UIActivityTypeAddToReadingList]
      
      
      self.presentViewController(activityVC, animated: true, completion: nil)
  }
  

  func takeScreenShot() -> UIImage {
    //Create the UIImage
    let layer = UIApplication.sharedApplication().keyWindow!.layer
    let scale = UIScreen.mainScreen().scale
    UIGraphicsBeginImageContextWithOptions(layer.frame.size, false, scale);
    
    layer.renderInContext(UIGraphicsGetCurrentContext())
    let screenshot = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return screenshot
  }

  
  func getWeatherConditions(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
    
    print(" getWeather called with lat \(latitude) and lon \(longitude) ")
    
    
    let forecastID = valueForAPIKey(keyname: "API_CLIENT_ID")
    
    let urlPath = "https://api.forecast.io/forecast/\(forecastID)/" + toString(latitude) + "," + toString(longitude)
    
    let url = NSURL(string: urlPath)
    print(url!)
    
    let session = NSURLSession.sharedSession()
    let task = session.dataTaskWithURL(url!) { (data, response, error) -> Void in
      if error == nil {
        
        let jsonResult = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers, error: nil) as! NSDictionary
        
        // print(jsonResult)
        
        if let currentConditions = jsonResult["currently"] as? NSDictionary {
          self.realFeelTemp = Int(round(currentConditions["apparentTemperature"] as! Double))
          print("real feel temp is: \(self.realFeelTemp)")
          self.ambientTemp = Int(round(currentConditions["temperature"] as! Double))
          self.windSpeed = Int(round(currentConditions["windSpeed"] as! Double))
          self.windDirection = self.getWindDirection(currentConditions["windBearing"] as! Int)
          self.humidity = Int((currentConditions["humidity"] as! Double) * 100)
          self.icon = currentConditions["icon"] as! String
        }
        
      
        let dailyData = jsonResult["daily"]!["data"]! as! NSArray
        let hourly = jsonResult["hourly"] as! NSDictionary
        
        self.todaySummary = dailyData[0]["summary"] as! String
        self.hiTemp = Int(round(dailyData[0]["temperatureMax"] as! Double))
        self.lowTemp = Int(round(dailyData[0]["temperatureMin"] as! Double))
        let todayHumidity = dailyData[0]["humidity"] as! Double
        // let todaywindSpeed = dailyData[0]["windSpeed"] as! Double
        self.todayPrecipProb = dailyData[0]["precipProbability"] as! Double
        
        self.hourlySummary = hourly["summary"] as! String
        
        print(" today summary: \(self.todaySummary)")
        print(" hourly summary: \(self.hourlySummary)")
        
        // alerts
        /*
        if let alerts: NSArray = jsonResult["alerts"] as? NSArray {
          let lastAlert: AnyObject = alerts.lastObject!
          print("last alert is: \(lastAlert)")
          if let alertTitle = lastAlert["title"] as? String {
            self.alertTitle = alertTitle.trimUpTo("for").uppercaseString
          }
          if let expires: NSTimeInterval = lastAlert["expires"] as? NSTimeInterval {
            self.alertLocalExpireTime = self.formatDate(expires)
          }
          
          if let description = lastAlert["description"] as? String {
            self.alertDescription = self.formatDescription(description)
            print("description is: \(description)")
          }
          
          /* WEATHER ALERTS!
          dispatch_async(dispatch_get_main_queue(), { () -> Void in
          self.showWeatherAlert()
          })
          */
          
          
        }
        */
        
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
          self.getRealFeel(self.humidity, windSpeed: self.windSpeed, precipProb: self.todayPrecipProb)
          self.realFeelTempLabel.text = "\(self.realFeelTemp)º"
          if self.icon == "" {
            self.currentWeatherIcon.image = UIImage(named: "partly-cloudy-day")
          } else {
            self.currentWeatherIcon.image = UIImage(named: self.icon)
          }
          
          self.ambientTempLabel.text = "\(self.ambientTemp)º"
          self.hiTempLabel.text = "\(self.hiTemp)º"
          self.lowTempLabel.text = "\(self.lowTemp)º"
          self.windLabel.text = "\(self.windSpeed) mph  \(self.windDirection)"
          self.humidityLabel.text = "\(self.humidity)%"
          // Stop the spinner in the status bar
          UIApplication.sharedApplication().networkActivityIndicatorVisible = false
          UIView.animateWithDuration(0.2, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 1.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
            self.winkView.hidden = true
            //self.winkView.transform = CGAffineTransformMakeScale(0.05, 0.05)
          }, completion: { (complete) -> Void in
            //self.winkView.hidden = true
          })
          
          
        })
        
        
        
      } else {
        // something went wrong with API call to forecast
        print(error)
      }
      /* swift 2.0
      do {
      let jsonResult = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
      print(jsonResult)
      let hourlyData = jsonResult["hourly"]!["data"]! as! NSArray
      
      for data in hourlyData {
      
      guard let pressureInFuture = data["pressure"]! else {
      return
      }
      self.futurePressures.append(pressureInFuture as! Double)
      
      }
      
      
      print(self.futurePressures)
      let pressureDirection = self.determinePressureDirection(self.futurePressures)
      
      guard let currentConditions = jsonResult["currently"] else {
      return
      }
      guard let currentPressure = currentConditions["pressure"] else {
      return
      }
      
      dispatch_async(dispatch_get_main_queue(), { () -> Void in
      self.pressure = self.convertPressure(currentPressure as! Double)
      self.pressureLabel.text = "\(self.pressure)"
      self.pressureDirectionLabel.image = UIImage(named: pressureDirection)
      })
      
      
      
      } catch {
      print(error)
      self.pressureLabel.text = "N/A"
      }
      */
      
      
    }
    
    task.resume()
    
    // Read from stored bounce count
    bounceViewCount = NSUserDefaults.standardUserDefaults().objectForKey("bounceViewCount") as! Int
    if bounceViewCount < 2 {
      bounceView()
      bounceViewCount++
      // Store the bounce view count
      NSUserDefaults.standardUserDefaults().setInteger(bounceViewCount, forKey: "bounceViewCount")
    }
    
    print(" bounce view count is: \(bounceViewCount) ")
    
    /*
    if postalCode != nil {
      getUVIndex(postalCode)
    }
    */
    

  }
  
  func getWindDirection(bearing: Int) -> String {
    let cards = ["N", "NE", "E", "SE", "S", "SW", "W", "NW"]
    var dir = ""
    for (i, card) in enumerate(cards) {
      if Double(bearing) < 45.0/2.0 + 45.0*Double(i) {
        dir = card
        break
      }
    }
    return dir
  }
  
  func getRealFeel(humidity: Int, windSpeed: Int, precipProb: Double) {
    
    var uvIndex = 5
    var temp: String!
    var humidityFeel: String!
    var wind: String!
    
    switch realFeelTemp {
    case 100...200:
      temp = "scorcher" // red
      temperatureView.backgroundColor = scorcherColor
      divider.backgroundColor = scorcherColor
    case 92...99:
      temp = "hot" // red-orange
      temperatureView.backgroundColor = hotColor
      divider.backgroundColor = hotColor
    case 80...91:
      temp = "warm" // orange
      temperatureView.backgroundColor = warmColor
      divider.backgroundColor = warmColor
    case 70...79:
      temp = "perfect" // yellow
      temperatureView.backgroundColor = perfectColor
      divider.backgroundColor = perfectColor
    case 65...69:
      temp = "nice" // green
      temperatureView.backgroundColor = niceColor
      divider.backgroundColor = niceColor
    case 50...64:
      temp = "cool" // blue-green
      temperatureView.backgroundColor = coolColor
      divider.backgroundColor = coolColor
    case 40...49:
      temp = "chilly" // standard blue
      temperatureView.backgroundColor = chillyColor
      divider.backgroundColor = chillyColor
    case 33...39:
      temp = "cold" //3C89F7?
      temperatureView.backgroundColor = coldColor
      divider.backgroundColor = coldColor
    case 20...32:
      temp = "freezing" //blue-purple? 4D5AF8
      temperatureView.backgroundColor = freezingColor
      divider.backgroundColor = freezingColor
    case 0...19:
      temp = "bitterlycold" //purple?
      temperatureView.backgroundColor = bitterlycoldColor
      divider.backgroundColor = bitterlycoldColor
    case -150..<0:
      temp = "subzero" //need
      temperatureView.backgroundColor = subzeroColor
      divider.backgroundColor = subzeroColor
    default:
      temp = "default"
    }
    
    switch humidity {
    case 0...30:
      humidityFeel = "dry"
    case 31...60:
      humidityFeel = "comfortable"
    case 61...79:
      humidityFeel = "sticky"
    case 80...100:
      humidityFeel = "wet"
    default:
      humidityFeel = "default"
    }
    
    switch windSpeed {
    case 0...5:
      wind = "calm"
    case 6...10:
      wind = "light"
    case 11...20:
      wind = "breezy"
    case 20...31:
      wind = "blustery"
    case 32...999:
      wind = "gale"
    default:
      wind = "default"
    }
    
    
    if temp == "scorcher" {
      if humidityFeel == "sticky" {
        if wind == "calm" || wind == "light" {
          realFeel = "It's African hot, find A/C stat"
        }
      } else if humidityFeel == "wet" {
        realFeel = "It's middle-of-the jungle hot, stay indoors"
      } else if humidityFeel == "dry" {
        realFeel = "It's oven-esque, find a cool shelter"
      } else {
        realFeel = "It's a scorcher, grab a cold lemonade"
      }
      
    } else if temp == "hot" {
      if humidityFeel == "sticky" {
        if wind == "calm" || wind == "light" {
          realFeel = "It's sweltering, find A/C stat"
        } else {
          realFeel = "It's sultry with a sticky breeze"
        }
      } else if humidityFeel == "wet" {
        realFeel = "It's like a sauna, find A/C"
      } else if humidityFeel == "dry" {
        realFeel = "Not too bad in the shade, wear flip flops"
      } else {
        realFeel = "It's super hot, wear wicking clothing"
      }
      
    } else if temp == "warm" {
      if humidityFeel == "wet" {
        realFeel = "Doesn't get much steamier than this"
      } else if humidityFeel == "sticky" {
        realFeel = "The air's warm and thick, wear shorts"
        if wind == "breezy" {
          realFeel = "The air's warm and thick but it's breezy"
        }
      } else if humidityFeel == "dry" {
        realFeel = "It's nice in the shade, wear flip flops"
      } else {
        realFeel = "Sure is warm, great time to jump in a pool"
      }
      
    } else if temp == "perfect" {
      if humidityFeel == "wet" {
        if wind == "light" || wind == "breezy" {
          realFeel = "It's a bit humid but nice with the breeze"
        } else {
          realFeel = "It's like pea soup"
        }
      } else if humidityFeel == "sticky" {
        realFeel = "Nearly perfect, just a touch humid"
      } else {
        realFeel = "Make time to play outside, it's perfect"
      }
      
    } else if temp == "nice" {
      if humidityFeel == "sticky" || humidityFeel == "wet" {
        if wind != "calm" && wind != "light" {
          realFeel = "It's like a chilled pea soup with the breeze, wear a windbreaker"
        } else {
          realFeel = "It's like pea soup"
        }
      } else {
        realFeel = "Make time to play outside, it's perfect"
      }
      
    } else if temp == "cool" {
      if humidityFeel == "dry" || humidityFeel == "comfortable" {
        if wind == "calm" || wind == "light" {
          realFeel = "It's crisp, put on a long-sleeve shirt"
        } else {
          realFeel = "It's brisk, put on a sweatshirt"
        }
      } else if humidityFeel == "sticky" {
        if wind == "calm" || wind == "light" {
          realFeel = "It's cool out there, wear a hoodie"
        } else {
          realFeel = "It's cool and breezy, wear a light jacket"
        }
      } else if humidityFeel == "wet" {
        realFeel = "It's damp, wear a light jacket"
      }
      
    } else if temp == "chilly" {
      if humidityFeel == "wet" {
        if wind != "calm" && wind != "light" {
          realFeel = "It's chilly and breezy, wear a windbreaker"
        } else {
          realFeel = "It's chilly and pea-soupy, wear a rain jacket"
        }
      } else {
        realFeel = "It's chilly, wear a sweater"
      }
      
    } else if temp == "cold" {
      if wind != "calm" && wind != "light" {
        realFeel = "It's bone chilling and windy, wear a thick coat"
      } else {
        realFeel = "It's cold, wear a coat"
      }
      
    } else if temp == "freezing" {
      if (humidityFeel != "dry" && humidityFeel != "comfortable") && (wind != "calm" && wind != "light") {
        realFeel = "It's bone chilling, layer up"
      } else {
        realFeel = "It's freezing, wear a heavy coat"
      }
      
    } else if temp == "bitterlycold" {
      if wind != "calm" && wind != "light" {
        realFeel = "It's bitterly cold, wear a heavy coat and beanie"
      } else {
        realFeel = "It's like walking in a cold wind tunnel, wear your heaviest coat"
      }
      
    } else if temp == "subzero" {
      realFeel = "Yikes, stay indoors to avoid frostbite"
    }
  
    
    
    print("realFeel is: \(realFeel)")
    
    var attributedRealFeel = NSMutableAttributedString(string: realFeel, attributes: attributes as [NSObject : AnyObject])

    
    //realFeelLabel.text = realFeel
    realFeelLabel.attributedText = attributedRealFeel
    
    setSummary(self.todayPrecipProb, uvIndex: maxUVIndex)
    
    // set the colors for the icons
    setColor(temp)
    
    print("\(temp), \(humidityFeel), and \(wind)")

  }
  
  func setColor(temp: String) {
    windIcon.image = UIImage(named: "wind-icon-\(temp)")
    humidityIcon.image = UIImage(named: "humidity-icon-\(temp)")
    uvIcon.image = UIImage(named: "uv-icon-\(temp)")
  }
  
  func setSummary(precipProb: Double?, uvIndex: Int?) {
   
    var summary = ""
    print(" current hour is: \(currentHour) ")
    
    // switch to hourly summary at 12pm
    if currentHour < 12 {
      summary = todaySummary
    } else {
      summary = hourlySummary
    }
    
    if precipProb > 0.79 {
      print(" precipProb is: \(precipProb) ")
      let grabUmbrella = "Grab an umbrella. "
      provideRecommendation(grabUmbrella, summary: summary)
    } else if maxUVIndex >= minUVForNotice && currentHour < lastUVIndexHour {
      print(" getting uvIndexNotice ")
      let uvRecommendation = uvIndexNotice(uvByTime)
      provideRecommendation(uvRecommendation, summary: summary)
    } else {
      summaryLabel.text = summary
    }
    
  }
  
  
  func getUVIndex(postalCode: String) {
    
    // don't get the UV data again if it's already been checked today
    
   //  if userCalendar.isDateInToday(uvChecked) {
   //     print("uv has already been checked today")
   //  } else {
      let urlPath = "http://iaspub.epa.gov/enviro/efservice/getEnvirofactsUVHOURLY/ZIP/\(postalCode)/JSON"
      
      let url = NSURL(string: urlPath)
      
      let session = NSURLSession.sharedSession()
      let task = session.dataTaskWithURL(url!) { (data, response, error) -> Void in
        print(" error on UVindex: \(error) ")
        if error == nil {
          
          
          
          let jsonResult = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers, error: nil) as! NSArray
          
          print(" uv index json: \(jsonResult)")
          
          
          for data in jsonResult {
            
            let time = data["DATE_TIME"] as! String
            let formattedTime = self.formatTime(time)
            let uvIndex = data["UV_VALUE"] as! Int
            self.uvByTime[formattedTime] = uvIndex
            
          }
          
          
          for (time, uvIndex) in self.uvByTime {
            if uvIndex > self.maxUVIndex {
              self.maxUVIndex = uvIndex
              self.maxUVTime = time
            }
            // get the last hour where the UV index is over the min threshold
            if uvIndex >= self.minUVForNotice {
              if self.formatMilitaryTime(time) > self.lastUVIndexHour {
                self.lastUVIndexHour = self.formatMilitaryTime(time)
              }
            }
          }
          
          print(" maxUVIndex is: \(self.maxUVIndex) ")
          print(" lastUVIndex hour is: \(self.lastUVIndexHour) ")
          
          
          
          
          
          /*
          if let currentConditions = jsonResult["currently"] {
          self.realFeelTemp = Int(round(currentConditions["apparentTemperature"] as! Double))
          print("real feel temp is: \(self.realFeelTemp)")
          
          }
          
          
          
          
          
          let todaySummary = dailyData[0]["summary"] as! String
          self.summary = todaySummary
          
          
          */
          dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.uvIndexLabel.text = "\(self.uvByTime[self.format12H(self.currentHour)]!)"
            self.setSummary(self.todayPrecipProb, uvIndex: self.maxUVIndex)
          
          })

        } else {
          // something went wrong with API call to forecast
          print(error)
        }
      }
      
      task.resume()
      
      uvChecked = NSDate()

    //}
    
  }
  
  func uvIndexNotice(uvByTime: Dictionary<String, Int>) -> String {
    
    var uvTimesSunburn: [String] = []
    var uvTimesExtreme: [String] = []
    var uvRecommendation = ""
    
    for (time, uvIndex) in uvByTime {
      // var shortTime = formatTime(time)
      if uvIndex >= minUVForNotice && uvIndex < minUVForExtreme {
        uvTimesSunburn.append(time)
      } else if uvIndex >= minUVForExtreme {
        uvTimesExtreme.append(time)
      }
    }
    
    let sortedUVTimesExtreme = sorted(uvTimesExtreme)
    print(" uvTimesExtreme sorted: \(sortedUVTimesExtreme)" )
    let sortedUVTimesSunburn = sorted(uvTimesSunburn)
    print(" uvTimesSunburn sorted: \(sortedUVTimesSunburn)" )
    
    if !uvTimesExtreme.isEmpty && currentHour < formatMilitaryTime(sortedUVTimesExtreme.last!) {
      uvRecommendation = "Avoid the sun between \(sortedUVTimesExtreme.first!) - \(sortedUVTimesExtreme.last!). "
    } else {
      // else if currentHour < formatMilitaryTime(sortedUVTimesSunburn.last!)
      uvRecommendation = "Use sunscreen from \(sortedUVTimesSunburn.first!) - \(sortedUVTimesSunburn.last!). "
    }
    
    /*
    
    if uvTimesExtreme.count > 0 {
      uvRecommendation = "Avoid the sun between \(uvTimesExtreme.first!) - \(uvTimesExtreme.last!). "
      /*
      summary = "Avoid the sun between \(uvTimesExtreme.first!) - \(uvTimesExtreme.last!). " + summary
      print("Avoid the sun between \(uvTimesExtreme.first!) - \(uvTimesExtreme.last!). " + summary)
      */
    } else if uvTimesSunburn.count > 0 {
      uvRecommendation = "Put on sunscreen between \(uvTimesSunburn.first!) - \(uvTimesSunburn.last!). "
      
      /*
      summary = "Put on sunscreen between \(uvTimesSunburn.first!) - \(uvTimesSunburn.last!). " + summary
      print("Put on sunscreen between \(uvTimesSunburn.first!) - \(uvTimesSunburn.last!). " + summary)
      */
    }
    
    */
    return uvRecommendation
    
  }
  
  func provideRecommendation(recommendation: String, summary: String) {
    print(" *providing a recommendation* ")
    
    var recommendationAndSummary = recommendation + summary
    var attributedSummary = NSMutableAttributedString(string: summary)
    var styledRecommendationandSummary = NSMutableAttributedString(string: recommendationAndSummary)
    styledRecommendationandSummary.addAttribute(NSForegroundColorAttributeName, value: temperatureView.backgroundColor!, range: NSRange(location: 0, length: count(recommendation)))
    
    dispatch_async(dispatch_get_main_queue(), { () -> Void in
      self.summaryLabel.attributedText = styledRecommendationandSummary
    })
    
  }
  

  func formatTime(time: String) -> String {
    
    var formattedTime = time.trimAfter(" ").stringByReplacingOccurrencesOfString(" ", withString: "")
    if formattedTime[formattedTime.startIndex] == "0" {
      formattedTime = formattedTime.stringByReplacingOccurrencesOfString("0", withString: "")
    }
    return formattedTime.lowercaseString
    
  }
  
  func formatMilitaryTime(time: String) -> Int {
    
    var militaryTime = ""
    switch time {
    case "12am":
      militaryTime = "00"
    case "1am":
      militaryTime = "01"
    case "2am":
      militaryTime = "02"
    case "3am":
      militaryTime = "03"
    case "4am":
      militaryTime = "04"
    case "5am":
      militaryTime = "05"
    case "6am":
      militaryTime = "06"
    case "7am":
      militaryTime = "07"
    case "8am":
      militaryTime = "08"
    case "9am":
      militaryTime = "09"
    case "10am":
      militaryTime = "10"
    case "11am":
      militaryTime = "11"
    case "12pm":
      militaryTime = "12"
    case "1pm":
      militaryTime = "13"
    case "2pm":
      militaryTime = "14"
    case "3pm":
      militaryTime = "15"
    case "4pm":
      militaryTime = "16"
    case "5pm":
      militaryTime = "17"
    case "6pm":
      militaryTime = "18"
    case "7pm":
      militaryTime = "19"
    case "8pm":
      militaryTime = "20"
    case "9pm":
      militaryTime = "21"
    case "10pm":
      militaryTime = "22"
    case "11pm":
      militaryTime = "23"
    default:
      militaryTime = "00"
    }
    
    return militaryTime.toInt()!
  }
  
  func format12H(time: Int) -> String {
    
    var time12H = ""
    switch time {
    case 00:
      time12H = "12am"
    case 01:
      time12H = "1am"
    case 02:
      time12H = "2am"
    case 03:
      time12H = "3am"
    case 04:
      time12H = "4am"
    case 05:
      time12H = "5am"
    case 06:
      time12H = "6am"
    case 07:
      time12H = "7am"
    case 08:
      time12H = "8am"
    case 09:
      time12H = "9am"
    case 10:
      time12H = "10am"
    case 11:
      time12H = "11am"
    case 12:
      time12H = "12pm"
    case 13:
      time12H = "1pm"
    case 14:
      time12H = "2pm"
    case 15:
      time12H = "3pm"
    case 16:
      time12H = "4pm"
    case 17:
      time12H = "5pm"
    case 18:
      time12H = "6pm"
    case 19:
      time12H = "7pm"
    case 20:
      time12H = "8pm"
    case 21:
      time12H = "9pm"
    case 22:
      time12H = "10pm"
    case 23:
      time12H = "11pm"
    default:
      time12H = "12am"
    }
    
    return time12H
  }

  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

}

