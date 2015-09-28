//
//  ViewController.swift
//  WeatherFeel
//
//  Created by John Mauro on 7/14/15.
//  Copyright (c) 2015 John Mauro. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate, UIGestureRecognizerDelegate, MKMapViewDelegate {
  
  var locationManager = CLLocationManager()
  var locationFixAchieved: Bool = false
  var previousLocation: CLLocation!
  // var latitude: CLLocationDegrees! = 37.9392
  // var longitude: CLLocationDegrees! = -107.8163
  // var postalCode: String!
  
  var realFeel = ""
  var realFeelTemp = Int()
  var ambientTemp = Int()
  var hiTemp = Int()
  var lowTemp = Int()
  var windSpeed = Int()
  var windDirection = ""
  var humidity = Int()
  var icon = ""
  var currentPrecipProb: Double = 0.0
  var todaySummary = ""
  var todayPrecipProb: Double!
  var precipLikely: [String] = []
  let minPrecipProb = 0.50
  var hourlySummary = ""
  var recommendation = ""
  var futureTempsByTime = [NSDate: Double]()
  
  let minUVForNotice: Int = 5
  let minUVForExtreme: Int = 11
  var maxUVIndex = 0
  var maxUVTime = 0
  var lastUVIndexHour: Int = 0
  var uvByTime = [Int: Int]()
  
  var currentDate = NSDate()
  var userCalendar: NSCalendar = NSCalendar.currentCalendar()
  // var comps: NSDateComponents!
  var currentHour: Int!
  var formatter = NSDateFormatter()
  var uvChecked: NSDate = NSDate(timeIntervalSince1970: 0)
  var weatherChecked: NSDate = NSDate(timeIntervalSince1970: 0)
  
  
  // Temperature colors
  let scorcherColor = UIColor(hex: 0xFF2558) // or 0xF73C4B or 0xFE3241
  let hotColor = UIColor(hex: 0xFF7827)
  let warmColor = UIColor(hex: 0xFFAB25)
  let perfectColor = UIColor(hex: 0xFFF126) // FFF824 FAFF00
  let niceColor = UIColor(hex: 0x26FF8B)
  let coolColor = UIColor(hex: 0x27EDFF)
  let chillyColor = UIColor(hex: 0x26AFFF)
  let coldColor = UIColor(hex: 0x2886FF)
  let freezingColor = UIColor(hex: 0x4D5AFF)
  let bitterlycoldColor = UIColor(hex: 0x6C38FF)
  let subzeroColor = UIColor(hex: 0x8F41FF)
  
  // Prevent italic display font from being cut off
  let realFeelLabelColor = UIColor(hex: 0x727C83) // 0x858F96  or  0x727C83
  var displayFont: UIFont!
  // var paragraphStyle = NSMutableParagraphStyle()
  var attributes: NSDictionary!
  
  var flick: UIPanGestureRecognizer!
  var longPress: UILongPressGestureRecognizer!
  var tap: UITapGestureRecognizer!
  var bounceViewCount: Int! = 0
  var constraintTemperatureViewHeight: NSLayoutConstraint!
  
  var animationFinished: Bool = false
  var getWeatherFinished: Bool = false
  
  let mapCornerRadius: CGFloat = 10
  
  // var imageURL: UIImageView!
  var centerCoord: CLLocationCoordinate2D!
  var region: MKCoordinateRegion!
  var radarImage: UIImage!
  var neCoord: CLLocationCoordinate2D!
  var swCoord: CLLocationCoordinate2D!
  var radarImagesArray = [UIImage]()
  var timer: NSTimer?
  var imageCount = 0
  var overlayView: RadarOverlayView!
  var radarAnimationSpeed: NSTimeInterval = 2.0
  var radarImageIndex = 0
  var animatedRadar: AnimatedRadar!
  var radarOverlay: RadarTileOverlay!
  
  
  var radarPositions = [Int]()
  var radarImageToUse: UIImage!
  var originalMapFrame: CGRect!
  var isMapFullScreen = false
  
  enum snappedTo {
    case Bottom
    case Middle
    case Top

  }
  var temperatureViewPosition: snappedTo!
  
  var futureHour1: NSDictionary!
  var futureHour2: NSDictionary!
  var futureHour3: NSDictionary!
  var futureHour4: NSDictionary!
  var futureHour5: NSDictionary!
  
  var hourlyOffset = 3
  
  var futureHourlyData: Array = [NSDictionary]()
  
  var sunriseTime: NSDate!
  var sunsetTime: NSDate!
  
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

  @IBOutlet var feelsLikeLabel: UILabel!
  @IBOutlet var currentWeatherIcon: UIImageView!
  @IBOutlet var windIcon: UIImageView!
  @IBOutlet var humidityIcon: UIImageView!
  @IBOutlet var uvIcon: UIImageView!
  @IBOutlet var divider: UIView!
  @IBOutlet var winkView: UIImageView!
  @IBOutlet var mapView: MKMapView!
  @IBOutlet var weathersbeeTitle: UIImageView!
  
  @IBOutlet var resizeMapButton: UIButton!
  
  @IBAction func resizeMap(sender: AnyObject?) {
    if isMapFullScreen == false {
      UIView.animateWithDuration(0.25, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 2.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: ({
        // self.map.frame = self.originalMapFrame
        self.mapView.removeConstraints(self.mapView.constraints)
        self.mapShadow.alpha = 0
        self.mapView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height - 60)
        
        self.mapView.layer.cornerRadius = 0
        self.resizeMapButton.hidden = true
        
      })) { (complete) -> Void in
        
        self.mapView.translatesAutoresizingMaskIntoConstraints = true
        // self.mapView.setNeedsUpdateConstraints()
        // self.resizeMapButton.setNeedsUpdateConstraints()
       
        print(self.mapView.frame, terminator: "")
        print(self.resizeMapButton.frame, terminator: "")
       
        self.resizeMapButton.imageView!.image = UIImage(named: "minimize")
        self.resizeMapButton.hidden = false
        self.isMapFullScreen = true
      }
      
    } else {
      UIView.animateWithDuration(0.25, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 2.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: ({
        self.mapView.removeConstraints(self.mapView.constraints)
        self.mapView.frame = self.originalMapFrame
        //CGRect(x: 20, y: 129, width: 280, height: 280)
        // self.mapView.frame = self.mapShadow.frame
        // self.mapView.bounds = self.mapShadow.bounds
        self.mapView.layer.cornerRadius = 10
        self.resizeMapButton.hidden = true
        
        self.mapShadow.alpha = 1
        
        // self.mapView.userTrackingMode = MKUserTrackingMode.Follow
      })) { (complete) -> Void in
        
        self.mapView.translatesAutoresizingMaskIntoConstraints = true
        // self.mapView.setNeedsUpdateConstraints()
        print(self.mapView.frame, terminator: "")
        print(self.resizeMapButton.frame, terminator: "")
        self.mapView.setRegion(self.region, animated: true)
        self.resizeMapButton.imageView!.image = UIImage(named: "maximize")
        self.resizeMapButton.hidden = false
        self.isMapFullScreen = false
      }

    }
  }
  
  @IBOutlet var mapShadow: UIImageView!
  
  @IBOutlet var futureHour1Time: UILabel!
  @IBOutlet var futureHour1Image: UIImageView!
  @IBOutlet var futureHour1Temp: UILabel!
  
  @IBOutlet var futureHour2Time: UILabel!
  @IBOutlet var futureHour2Image: UIImageView!
  @IBOutlet var futureHour2Temp: UILabel!
  
  @IBOutlet var futureHour3Time: UILabel!
  @IBOutlet var futureHour3Image: UIImageView!
  @IBOutlet var futureHour3Temp: UILabel!
  
  @IBOutlet var futureHour4Time: UILabel!
  @IBOutlet var futureHour4Image: UIImageView!
  @IBOutlet var futureHour4Temp: UILabel!
  
  @IBOutlet var futureHour5Time: UILabel!
  @IBOutlet var futureHour5Image: UIImageView!
  @IBOutlet var futureHour5Temp: UILabel!
  
  @IBOutlet var sunriseTimeLabel: UILabel!
  @IBOutlet var sunsetTimeLabel: UILabel!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    mapView.delegate = self
    
    originalMapFrame = mapView.frame
    
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
    
    
    // Get the location data
    locationManager.delegate = self
    locationManager.distanceFilter = 100.0
    locationManager.desiredAccuracy = kCLLocationAccuracyBest
    locationManager.requestWhenInUseAuthorization()
    locationManager.startUpdatingLocation()
    
    animateWink()

    

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
    currentHour = currentDate.hour()
    print(" currentDate initially:  \(currentDate) ", terminator: "")
    print(" currentHour initially: \(currentHour) ", terminator: "")
  
    flick = UIPanGestureRecognizer(target: self, action: "handleFlick:")
    flick.delegate = self
    temperatureView.addGestureRecognizer(flick)
    
    tap = UITapGestureRecognizer(target: self, action: "handleTap:")
    tap.delegate = self
    temperatureView.addGestureRecognizer(tap)
    
    longPress = UILongPressGestureRecognizer(target: self, action: "handleLongPress:")
    longPress.delegate = self
    self.view.addGestureRecognizer(longPress)
    
    
    // Update data when app enters foreground
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshData:", name: "refreshData", object: nil)
    
    // Store the initial bounce view count of 0
    NSUserDefaults.standardUserDefaults().setInteger(bounceViewCount, forKey: "bounceViewCount")
    
    mapView.layer.cornerRadius = mapCornerRadius
    mapView.showsUserLocation = true
    
    /*
    if let radarUrl = NSURL(string: "http://radar.weather.gov/ridge/Conus/RadarImg/latest_radaronly.gif") {
      downloadImage(radarUrl) { (result) -> Void in
          if let radarImage = result {
            print("radarImage in viewDidLoad is: \(radarImage)")
          }
      }
    }
    */
    
    temperatureViewPosition = snappedTo.Bottom
  }
  
 
  
  func animateWink() {
    
    winkView.animationImages = [UIImage(named: "launch.png")!, UIImage(named: "wink.png")!]
    winkView.animationDuration = 0.6
    winkView.animationRepeatCount = 1
    winkView.startAnimating()
    
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
      self.animationFinished = true
      self.weathersbeeTitle.hidden = true
 
      print(" getWeatherFinished is \(self.getWeatherFinished) ")
      
      if self.getWeatherFinished == true {
        self.displayWeatherData()
      } else {
        let initialString = "Fetching those weather bits..."
        self.realFeelLabel.attributedText = NSMutableAttributedString(string: initialString, attributes: self.attributes as? [String: AnyObject])
        self.summaryLabel.text = "One moment please..."
      }

      /*
      if self.getWeatherFinished == true {
        self.displayWeatherData()
      }
      */
      /*
      if self.summaryLabel.text == "" {
        self.summaryLabel.text = "One moment please..."
      }
      */
      
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
    
    //animateWink()
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
    currentDate = NSDate()
    currentHour = currentDate.hour()
    print(" currentDate in refreshData is \(currentDate) ", terminator: "")
    print(" currentHour in refreshData is: \(currentHour) ", terminator: "")
    
    locationManager.startUpdatingLocation()
  }
  
  
  func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    
    // Start the spinner in the status bar
    UIApplication.sharedApplication().networkActivityIndicatorVisible = true

    var userLocation: CLLocation = locations[0]
    print(" got location ", terminator: "")
    print(" time since checked weather \(currentDate.timeIntervalSinceDate(weatherChecked)) ")
    if (userLocation.horizontalAccuracy > 0 && currentDate.timeIntervalSinceDate(weatherChecked) > 0) {
      
      locationManager.stopUpdatingLocation()
      
      print(" locationManager stopped ")
      // get pressure via forecast API
      getWeatherConditions(userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
      
      
      print("previous location: \(previousLocation)", terminator: "")
      
      
      // only get the UVindex if it hasn't already been checked or if you've moved a lot
      print(" uvChecked has NOT been checked today: \(!userCalendar.isDateInToday(uvChecked)) ", terminator: "")
      
      if (previousLocation == nil || userLocation.distanceFromLocation(previousLocation) > 1000) || (!userCalendar.isDateInToday(uvChecked)) {
        print(" new location is more than 1000m from current or UVindex hasn't been checked today ", terminator: "")
        // get the nearest address
        CLGeocoder().reverseGeocodeLocation(userLocation, completionHandler: { (placemarks, error) -> Void in
          
          if (error != nil) {
            print(error)
          } else {
            guard let p: CLPlacemark = placemarks?.first else { return }
            print(" postal code: \(p.postalCode) ", terminator: "")
            print(" city is: \(p.locality) ", terminator: "")
            guard let postalCode = p.postalCode else { return }
            // self.postalCode = postalCode
            self.getUVIndex(postalCode)
            
  
          }
          
        })
        // getRadarImages()
        

      } else {
        print(" new location is close to previous ", terminator: "")
        // update UV label
        if !uvByTime.isEmpty {
          print(" updating the UV for \(currentHour) ", terminator: "")
          uvIndexLabel.text = "\(uvByTime[currentHour]!)"
        }

      }
      
      // Set up radar overlay
      // sets the zoom level for map
      var latDelta: CLLocationDegrees = 2.0
      var lonDelta: CLLocationDegrees = 2.0
      
      centerCoord = CLLocationCoordinate2DMake(userLocation.coordinate.latitude, userLocation.coordinate.longitude)
      var span = MKCoordinateSpanMake(latDelta, lonDelta)
      region = MKCoordinateRegionMake(centerCoord, span)
      mapView.region = region
      
      mapView.setRegion(region, animated: false)
      
      // add annotation
      /*
      var objectAnnotation = MKPointAnnotation()
      objectAnnotation.coordinate = centerCoord
      objectAnnotation.title = "Your location"
      self.mapView.addAnnotation(objectAnnotation)
      */
      
      print(" mapview bounds: \(mapView.bounds.origin) ", terminator: "")
      var nePoint: CGPoint = CGPointMake(mapView.bounds.maxX, mapView.bounds.origin.y);
      var swPoint: CGPoint = CGPointMake(mapView.bounds.minX, mapView.bounds.maxY);
      
      neCoord = mapView.convertPoint(nePoint, toCoordinateFromView: mapView)
      swCoord = mapView.convertPoint(swPoint, toCoordinateFromView: mapView)
      
      
      // var topRight = MKMapPointForCoordinate(neCoord)
      // var bottomLeft = MKMapPointForCoordinate(swCoord)
      
      print(" neCoord lat is \(neCoord.latitude) ", terminator: "")
      print(" neCoord lon is \(neCoord.longitude) ", terminator: "")
      print(" swCoord lat is \(swCoord.latitude) ", terminator: "")
      print(" swCoord lon is \(swCoord.longitude) ", terminator: "")
      // addRadarOverlay()
      getRadarTiles()
      
      
      // overlayBoundingMapRect = MKMapRectMake(bottomLeft.x, topRight.y, fabs(topRight.x - bottomLeft.x), fabs(bottomLeft.y - topRight.y))
      
      previousLocation = userLocation
    
    // end horizontal accuracy check
    }
    
    
  }
  
  func getRadarTiles() {
   
    if mapView.overlays.count > 0 {
      print(" **removing overlays** ")
      mapView.removeOverlays(mapView.overlays)
    }
    
    // tiles for last hour-ish
    // let pastTiles = ["nexrad-n0q-900913-m50m", "nexrad-n0q-900913-m40m", "nexrad-n0q-900913-m30m", "nexrad-n0q-900913-m20m", "nexrad-n0q-900913-m10m", "nexrad-n0q-900913"]
    let pastTiles = ["nexrad-n0q-900913"]
    var radarTileOverlays: Array = [RadarTileOverlay]()
    
    for tile in pastTiles {
      var urlTemplate = "http://mesonet.agron.iastate.edu/cache/tile.py/1.0.0/\(tile)/{z}/{x}/{y}.png"
      var overlay = RadarTileOverlay(URLTemplate: urlTemplate)
      radarTileOverlays.append(overlay)
     // self.mapView.addOverlay(overlay)
     // self.mapView.removeOverlay(overlay)
  
      /*
      if (radarOverlay != nil) {
        mapView.removeOverlay(radarOverlay)
      }
      radarOverlay = RadarTileOverlay(URLTemplate: urlTemplate)
      
      self.mapView.addOverlay(radarOverlay, level: MKOverlayLevel.AboveLabels)
      
      print(" urlTemplate \(urlTemplate) ")
      */
    }
    
    
    print(" radarTileOverlays: \(radarTileOverlays.last) ", terminator: "")
    print(" **adding radar overlay** ")
    self.mapView.addOverlay(radarTileOverlays.last!)
    print(" number of mapview overlays: \(mapView.overlays.count) ")
    
    
    //Don't want to replace underlying Apple map
    // radarOverlay.canReplaceMapContent = false
    // animateRadarOverlay(radarTileOverlays)
    
    // timer = NSTimer.scheduledTimerWithTimeInterval(3.0, target: self, selector: "animateTileOverlay", userInfo: nil, repeats: true)
    
  }
  
  func animateRadarOverlay(tileOverlays: Array<RadarTileOverlay>) {
    for tile in tileOverlays {
      UIView.animateWithDuration(2, animations: { () -> Void in
        self.mapView.addOverlay(tile)
      }, completion: { (complete) -> Void in
        UIView.animateWithDuration(2, delay: 0.2, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
          tile.alpha = 0
        }, completion: { (complete) -> Void in
           self.mapView.removeOverlay(tile)
        })
        
      })
      
    }
  }
  
  func addRadarOverlay(urlTemplate: String) {
    
    print( "adding radar overlay ", terminator: "")
    /* attempt #1
    var overlay = RadarOverlay(lowerLeftCoordinate: CLLocationCoordinate2DMake(21.652538062803, -127.620375523875420), upperRightCoordinate: CLLocationCoordinate2DMake(50.406626367301044, -66.517937876818))
    print(" overlay boundingMapRect: \(overlay.boundingMapRect.size.height) ")
    print(" radar image before adding overlay is \(radarImage) ")
    mapView.addOverlay(overlay)
    */
    /* attempt #2
    // var neCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2DMake(50.406626367301044, -66.517937876818)
    // var swCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2DMake(21.652538062803, -127.620375523875420)
    
    var neCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2DMake(50.406625, -65.60158888888888)
    var swCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2DMake(21.65253888888889, -129.314525)
    
    
    var topRight = MKMapPointForCoordinate(neCoordinate)
    var bottomLeft = MKMapPointForCoordinate(swCoordinate)
    var boundingMapRect = MKMapRectMake(bottomLeft.x, topRight.y, fabs(topRight.x - bottomLeft.x), fabs(bottomLeft.y - topRight.y))
    var radarRegion = MKCoordinateRegionForMapRect(boundingMapRect)
    var radarRect = mapView.convertRegion(radarRegion, toRectToView: mapView)
    
    
    animatedRadar = AnimatedRadar(frame: radarRect, images: radarImagesArray)
    print( " adding RADAR subview ")
    mapView.addSubview(animatedRadar)
    print(" startAnimatingRadar called ")
    
    animatedRadar.startAnimatingRadar()
    */
    // attempt #3 - this time with tiles
    //Get the URL template to the map tiles
  
      // radarOverlay = RadarTileOverlay(URLTemplate: urlTemplate)
      
      //Don't want to replace underlying Apple map
      //radarOverlay.canReplaceMapContent = false
      
      //Add the overlay
      self.mapView.addOverlay(radarOverlay, level: MKOverlayLevel.AboveLabels)
  }
  
  func animateTileOverlay() {
    /* attempt #1
    print( "animateTileOverlay called ")
    if (radarOverlay != nil) {
      mapView.removeOverlay(radarOverlay)
    }
    var pastTiles = ["nexrad-n0q-900913", "nexrad-n0q-900913-m50m", "nexrad-n0q-900913-m40m", "nexrad-n0q-900913-m30m", "nexrad-n0q-900913-m20m", "nexrad-n0q-900913-m10m"]
    if radarImageIndex >= pastTiles.count{
      radarImageIndex = 0
    }
    var urlTemplate = "http://mesonet.agron.iastate.edu/cache/tile.py/1.0.0/\(pastTiles[radarImageIndex])/{z}/{x}/{y}.png"
    // nexrad-n0q-900913-m50m
    print( " urlTemplate used: \(urlTemplate) ")
    addRadarOverlay(urlTemplate)
    radarImageIndex++
    */
    
    // attempt #2
    /*
    print( "animateTileOverlay called ")
    if (radarOverlay != nil) {
      mapView.removeOverlay(radarOverlay)
    }
    var pastTiles = ["nexrad-n0q-900913", "nexrad-n0q-900913-m50m", "nexrad-n0q-900913-m40m", "nexrad-n0q-900913-m30m", "nexrad-n0q-900913-m20m", "nexrad-n0q-900913-m10m"]
    if radarImageIndex >= pastTiles.count{
      radarImageIndex = 0
    }
    var urlTemplate = "http://mesonet.agron.iastate.edu/cache/tile.py/1.0.0/\(pastTiles[radarImageIndex])/{z}/{x}/{y}.png"
    // nexrad-n0q-900913-m50m
    print( " urlTemplate used: \(urlTemplate) ")
    self.mapView.addOverlay(radarOverlay, level: MKOverlayLevel.AboveLabels)
    radarImageIndex++
    */
    if radarOverlay != nil {
      mapView.removeOverlay(radarOverlay)
    }
    let pastTiles = ["nexrad-n0q-900913-m50m", "nexrad-n0q-900913-m40m", "nexrad-n0q-900913-m30m", "nexrad-n0q-900913-m20m", "nexrad-n0q-900913-m10m", "nexrad-n0q-900913"]
    for tile in pastTiles {
      let urlTemplate = "http://mesonet.agron.iastate.edu/cache/tile.py/1.0.0/\(tile)/{z}/{x}/{y}.png"
      let overlay = RadarTileOverlay(URLTemplate: urlTemplate)
      UIView.animateWithDuration(1.0, animations: { () -> Void in
        self.mapView.addOverlay(overlay, level: MKOverlayLevel.AboveLabels)
        }) { (complete) -> Void in
          self.mapView.removeOverlay(overlay)
      }

    }

  }
 
  func removeAnimatedRadar() {
    //if animatedRadar != nil {
      animatedRadar.stopAnimating()
      animatedRadar.removeFromSuperview()
     //}
  }
  
  func mapView(mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
    
    if animatedRadar != nil {
      print(" removing radar overlay ", terminator: "")
      removeAnimatedRadar()
    }
    // timer?.invalidate()
    // radarImageIndex = 0
  }
  
  func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
    if animatedRadar != nil {
      // addRadarOverlay()
    }
    
    // timer = NSTimer.scheduledTimerWithTimeInterval(radarAnimationSpeed, target: self, selector: "animateRadar", userInfo: nil, repeats: true)
  }
  
  
  /*
  func getDataFromURL(urL:NSURL, completion: ((data: NSData?) -> Void)) {
    NSURLSession.sharedSession().dataTaskWithURL(urL) { (data, response, error) in
      completion(data: data)
      }.resume()
  }
  */
  
  func downloadImage(url: NSURL, completionHandler: (radarImage: UIImage?) -> Void) {
    
    let session = NSURLSession.sharedSession()
    let task = session.dataTaskWithURL(url) { (data, response, error) -> Void in
      if error == nil {
        
        let imageData = NSData(data: data!)
        dispatch_async(dispatch_get_main_queue()) {
          print( " finished downloading \(url) ", terminator: "")
          // print( "imageURL is: \(self.imageURL)")
          
          self.radarImage = UIImage(data: imageData)
          // self.addRadarOverlay()
    
          // self.imageURL.image = UIImage(data: imageData)
        }
      } else {
        print(" error getting radar image ", terminator: "")
      }
    }
    
    task.resume()
    

  }
  
  func getRadarImages() {
    // take 2 minutes off because they post data on the 8 min mark
    let noaaLatestDate = currentDate.nearestMinuteFloor(10).dateByAddingTimeInterval(-60*2)
    
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "yyyyMMdd_HHmm"
    dateFormatter.timeZone = NSTimeZone(abbreviation: "UTC")
    
    var noaaTimes = [String]()
    
    for i in 0...6 {
      let pastDate = noaaLatestDate.dateByAddingTimeInterval(-60*10*NSTimeInterval(i))
      noaaTimes.append(dateFormatter.stringFromDate(pastDate))
      // print(i*2)
    }
    // print(noaaTimes)
    let noaaOrderedTimes = Array(noaaTimes.reverse())
    print(" last noaaOrderedTime: \(noaaOrderedTimes.last) ", terminator: "")
    // var radarImagesArray = [UIImage]()
    /*
    for (index, value) in enumerate(noaaOrderedTimes) {
      radarImagesArray.append(UIImage(data: NSData(contentsOfURL: NSURL(string: "http://radar.weather.gov/ridge/Conus/RadarImg/Conus_\(value)_N0Ronly.gif")!)!)!)
      
      /*
      downloadImage(NSURL(string: "http://radar.weather.gov/ridge/Conus/RadarImg/Conus_\(value)_N0Ronly.gif")!) { (result) -> Void in
        if let radarImage = result {
          radarImagesArray.append(radarImage)
        }
      }
      */

      // radarImagesArray.append(downloadImage(NSURL(string: "http://radar.weather.gov/ridge/Conus/RadarImg/Conus_\(value)_N0Ronly.gif")!))
    }
    */
    radarImagesArray.append(UIImage(data: NSData(contentsOfURL: NSURL(string: "http://mesonet.agron.iastate.edu/archive/data/2015/09/14/GIS/uscomp/n0r_201509142250.png")!)!)!)
    
    // http://mesonet.agron.iastate.edu/data/gis/images/4326/USCOMP/n0r_0.png
    print(" radarImagesArray: \(radarImagesArray) ", terminator: "")
    print(" radarImagesCount: \(radarImagesArray.count)", terminator: "")
   //  addRadarOverlay()
    // radarImageIndex = 0
    // timer = NSTimer.scheduledTimerWithTimeInterval(radarAnimationSpeed, target: self, selector: "animateRadar", userInfo: nil, repeats: true)
    // animateRadar(radarImagesArray)

  }
  
  func animateRadar() {
    print(" animating Radar ", terminator: "")
    // print( "radarImageIndex: \(radarImageIndex) ")
    
    /*
    if radarImageIndex >= radarImagesArray.count {
      radarImageIndex = 0
    }
*/
    print(" radarImageIndex: \(radarImageIndex) ", terminator: "")
    
    
    
    if radarImageIndex >= radarImagesArray.count {
      radarImageIndex = 0
    } else {
      radarImageIndex++
    }
    
    // overlayView.setNeedsDisplay(radarImageIndex, images: radarImagesArray)

    //Animate images in UIImageview
    /*
    _radarImageView.animationImages = imagesArray;
    _radarImageView.animationDuration = 3.0;
    _radarImageView.animationRepeatCount = 0;
    [_radarImageView startAnimating];
    */
    
  }
  
  
  /*
  func updateRadarImage(image: UIImage) {
    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
      // let radarImage: UIImage = NSURL(string: "http://radar.weather.gov/ridge/Conus/RadarImg/latest_radaronly.gif")!
      if overlay is RadarOverlay {
        print(" calling renderer ")
        // print(" radarImage in mapView func is: \(radarImage) ")
        
        // let testImage = UIImage(data: NSData(contentsOfURL: NSURL(string: "http://radar.weather.gov/ridge/Conus/RadarImg/latest_radaronly.gif")!)!)
        // let overlayView = RadarOverlayView(overlay: overlay, overlayImagesArray: radarImage)
        let overlayView = RadarOverlayView(overlay: overlay, overlayImage: image)
        overlayView.alpha = 0.4
        
        
        return overlayView
      } else {
        return nil
      }
      
      
    }

  }
  */
  
  // renderer

  func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
    /*
    if overlay is RadarOverlay {
      print(" calling renderer ")
      print(" radarImage in mapView func is: \(radarImage) ")
      
      // let testImage = UIImage(data: NSData(contentsOfURL: NSURL(string: "http://radar.weather.gov/ridge/Conus/RadarImg/latest_radaronly.gif")!)!)
      
      // overlayView = RadarOverlayView(overlay: overlay, overlayImagesArray: radarImagesArray)
      // overlayView = RadarOverlayView(overlay: overlay, overlayImagesArray: radarImagesArray, index: radarImageIndex)
      /*
      if radarImageToUse == nil {
        radarImageToUse = radarImagesArray[0]
      } else {
        radarImageToUse = radarImagesArray[radarImageIndex]
      }
      */
      
      radarImageToUse = radarImagesArray[radarImageIndex]
      print(" radar image used: \(radarImageToUse) ")
      overlayView = RadarOverlayView(overlay: overlay, overlayImage: radarImageToUse)
      overlayView.alpha = 0.4
      
      return overlayView
    } else {
      return nil
    }
    
    */
   
    // if overlay is MKTileOverlay {
      let renderer = MKTileOverlayRenderer(overlay: overlay)
      renderer.alpha = 0.6
      return renderer
   // }
   // return nil
  }

  
  func bounceView() {
    UIView.animateWithDuration(0.2, delay: 1.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 1.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
      
      self.temperatureView.transform = CGAffineTransformMakeTranslation(0, -20)
      
      }) { (complete) -> Void in
        
        // print("bottom view moved up")
        UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 0.3, initialSpringVelocity: 0.8, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
          
          self.temperatureView.transform = CGAffineTransformIdentity
          
          }) { (complete) -> Void in
            
            // print("bottom view moved up")
        }
        
        // Increment and store the bounce view count
        self.bounceViewCount!++
        print( " bounce view count in bounceView is: \(self.bounceViewCount) ", terminator: "")
        NSUserDefaults.standardUserDefaults().setInteger(self.bounceViewCount, forKey: "bounceViewCount")
    }
    
    
  }
  
  func snapToBottom() {
    UIView.animateWithDuration(0.25, delay: 0.0, usingSpringWithDamping: 0.9, initialSpringVelocity: 2.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
      if self.isMapFullScreen {
        self.resizeMap(nil)
      }
      self.temperatureView.transform = CGAffineTransformIdentity
      self.currentConditionsView.transform = CGAffineTransformIdentity
      self.realFeelTempLabel.hidden = false
      self.feelsLikeLabel.hidden = false
      
      
      }) { (complete) -> Void in
        self.temperatureViewPosition = .Bottom
        // self.isSnappedToBottom = true
        
    }
  }
  
  func handleTap(gesture: UITapGestureRecognizer) {
    if temperatureViewPosition == .Top {
      snapToBottom()
    }
  }
  
  func handleFlick(gesture: UIPanGestureRecognizer) {
    
      let translation = gesture.translationInView(temperatureView)
      let velocity = gesture.velocityInView(temperatureView)
      // print(" translation is \(translation) ", terminator: "")
      // print(" velocity is \(velocity) ", terminator: "")
      // print(" temperatureView origin y \(temperatureView.frame.origin.y) ", terminator: "")
    
      var startingPosition = temperatureView.frame.origin.y
      var bottomThreshold = CGFloat(379)
      var topThreshold = CGFloat(-100)
      var midThreshold = CGFloat(277)
    /*
    if gesture.state == .Began {
      
      startingPosition = temperatureView.frame.origin.y
      print(" starting position \(startingPosition) ")
    }
    
    if gesture.state == .Changed {
      if temperatureView.frame.origin.y <= bottomThreshold && temperatureView.frame.origin.y >= topThreshold {
        if temperatureView.frame.origin.y > midThreshold {
          self.temperatureView.transform = CGAffineTransformMakeTranslation(0, translation.y)
        } else {
          if translation.y < 0 {
            self.temperatureView.transform = CGAffineTransformMakeTranslation(0, translation.y)
            self.currentConditionsView.transform = CGAffineTransformMakeTranslation(0, translation.y + 102)
          } else {
            self.temperatureView.transform = CGAffineTransformTranslate(self.temperatureView.transform, 0, translation.y)
            self.currentConditionsView.transform = CGAffineTransformTranslate(self.currentConditionsView.transform, 0, translation.y)
          }
        }

      }
      
    }
    
    if gesture.state == .Ended {
      if temperatureView.frame.origin.y < midThreshold {
        if velocity.y < 0 {
          // snapToTop()
          UIView.animateWithDuration(0.25, delay: 0.0, usingSpringWithDamping: 0.9, initialSpringVelocity: 2.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
            // self.temperatureView.transform = CGAffineTransformTranslate(self.temperatureView.transform, 0, -self.view.frame.height + 60 - translation.y)
            // self.currentConditionsView.transform = CGAffineTransformTranslate(self.currentConditionsView.transform, 0, -self.view.frame.height + 60 - translation.y)
            
            self.currentConditionsView.transform = CGAffineTransformMakeTranslation(0, -self.view.frame.height + 162)
            self.temperatureView.transform = CGAffineTransformMakeTranslation(0, -self.view.frame.height + 60)
            self.realFeelTempLabel.hidden = true
            self.feelsLikeLabel.hidden = true
            
            }) { (complete) -> Void in
              // self.isSnappedToBottom = false
              // self.isSnappedToTop = true
              // self.temperatureViewPosition = .Top
              
          }
        } else {
          // snapToBottom()
          UIView.animateWithDuration(0.25, delay: 0.0, usingSpringWithDamping: 0.9, initialSpringVelocity: 2.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
            if self.isMapFullScreen {
              self.resizeMap(nil)
            }
            self.temperatureView.transform = CGAffineTransformIdentity
            self.currentConditionsView.transform = CGAffineTransformIdentity
            self.realFeelTempLabel.hidden = false
            self.feelsLikeLabel.hidden = false
            
            
            }) { (complete) -> Void in
              // self.temperatureViewPosition = .Bottom
              // self.isSnappedToBottom = true
              
          }
        }
      } else {
        if velocity.y < 0 {
          // snapToMiddle()
          UIView.animateWithDuration(0.25, delay: 0.0, usingSpringWithDamping: 0.9, initialSpringVelocity: 2.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
            // self.temperatureView.transform = CGAffineTransformTranslate(self.temperatureView.transform, 0, -102 - translation.y)
            self.temperatureView.transform = CGAffineTransformMakeTranslation(0, -102)
            self.currentConditionsView.transform = CGAffineTransformIdentity
            
            }) { (complete) -> Void in
              // self.isSnappedToBottom = false
             // self.temperatureViewPosition = .Middle
              
          }

        } else {
          // snapToBottom()
          UIView.animateWithDuration(0.25, delay: 0.0, usingSpringWithDamping: 0.9, initialSpringVelocity: 2.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
            if self.isMapFullScreen {
              self.resizeMap(nil)
            }
            self.temperatureView.transform = CGAffineTransformIdentity
            self.currentConditionsView.transform = CGAffineTransformIdentity
            self.realFeelTempLabel.hidden = false
            self.feelsLikeLabel.hidden = false
            
            
            }) { (complete) -> Void in
              self.temperatureViewPosition = .Bottom
              // self.isSnappedToBottom = true
              
          }
        }
      }
    }
    */
    if gesture.state == .Changed {
    
      if temperatureViewPosition == .Bottom {
        
        //isSnappedToBottom
        if translation.y < 0 {
          //&& isSnappedToBottom
          self.temperatureView.transform = CGAffineTransformMakeTranslation(0, translation.y)
          
          if translation.y < -102 {
            self.currentConditionsView.transform = CGAffineTransformMakeTranslation(0, translation.y + 102)
            
          }
        }

      } else if temperatureViewPosition == .Middle {
          
        
        if translation.y < 0 && self.temperatureView.frame.origin.y > -100 {
          print("temperature origin y \(temperatureView.frame.origin.y) ", terminator: "")
          // self.temperatureView.transform = CGAffineTransformMakeTranslation(0, translation.y)
          // self.currentConditionsView.transform = CGAffineTransformMakeTranslation(0, translation.y)
          if self.temperatureView.frame.origin.y < 60 {
            self.realFeelTempLabel.hidden = true
            self.feelsLikeLabel.hidden = true
          } else {
            self.realFeelTempLabel.hidden = false
            self.feelsLikeLabel.hidden = false
          }
          
          self.temperatureView.transform = CGAffineTransformTranslate(self.temperatureView.transform, 0, translation.y)
          self.currentConditionsView.transform = CGAffineTransformTranslate(self.currentConditionsView.transform, 0, translation.y)
        } else if translation.y > 0 && self.temperatureView.frame.origin.y < 375 {
          if self.temperatureView.frame.origin.y > 276 {
            self.temperatureView.transform = CGAffineTransformTranslate(self.temperatureView.transform, 0, translation.y)
          } else {
            self.temperatureView.transform = CGAffineTransformTranslate(self.temperatureView.transform, 0, translation.y)
            self.currentConditionsView.transform = CGAffineTransformTranslate(self.currentConditionsView.transform, 0, translation.y)
          }
        }
        
        /*else if translation.y > 0 && self.temperatureView.frame.origin.y < 379 {
           self.temperatureView.transform = CGAffineTransformTranslate(self.temperatureView.transform, 0, translation.y)
          self.currentConditionsView.transform = CGAffineTransformTranslate(self.currentConditionsView.transform, 0, translation.y)
        */
         // self.currentConditionsView.transform = CGAffineTransformIdentity
  

  
        
        
          //CGAffineTransformTranslate(self.currentConditionsView.transform, 0, translation.y)
          
      } else if temperatureViewPosition == .Top {
        
        if self.temperatureView.frame.origin.y < 375 {
          self.realFeelTempLabel.hidden = false
          self.feelsLikeLabel.hidden = false
          self.temperatureView.transform = CGAffineTransformTranslate(self.temperatureView.transform, 0, translation.y)
          self.currentConditionsView.transform = CGAffineTransformTranslate(self.currentConditionsView.transform, 0, translation.y)
          
        }
        

      }

      }
    
    if gesture.state == .Ended {
      if temperatureViewPosition == .Bottom && translation.y > -102 && velocity.y < 0 {
        UIView.animateWithDuration(0.25, delay: 0.0, usingSpringWithDamping: 0.9, initialSpringVelocity: 2.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
            // self.temperatureView.transform = CGAffineTransformTranslate(self.temperatureView.transform, 0, -102 - translation.y)
            self.temperatureView.transform = CGAffineTransformMakeTranslation(0, -102)
            self.currentConditionsView.transform = CGAffineTransformIdentity
          
          }) { (complete) -> Void in
            // self.isSnappedToBottom = false
            self.temperatureViewPosition = .Middle
            
        }

        
      } else if (temperatureViewPosition == .Bottom && translation.y < -102 && velocity.y < 0) || (temperatureViewPosition == .Middle && translation.y < 0 && velocity.y < 0) {
        UIView.animateWithDuration(0.25, delay: 0.0, usingSpringWithDamping: 0.9, initialSpringVelocity: 2.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
            // self.temperatureView.transform = CGAffineTransformTranslate(self.temperatureView.transform, 0, -self.view.frame.height + 60 - translation.y)
            // self.currentConditionsView.transform = CGAffineTransformTranslate(self.currentConditionsView.transform, 0, -self.view.frame.height + 60 - translation.y)
    
            self.currentConditionsView.transform = CGAffineTransformMakeTranslation(0, -self.view.frame.height + 162)
            self.temperatureView.transform = CGAffineTransformMakeTranslation(0, -self.view.frame.height + 60)
            self.realFeelTempLabel.hidden = true
            self.feelsLikeLabel.hidden = true
          
          }) { (complete) -> Void in
            // self.isSnappedToBottom = false
            // self.isSnappedToTop = true
            self.temperatureViewPosition = .Top
            
        }
        
      } else if velocity.y >= 0 {
        print(" sending to bottom ", terminator: "")
        snapToBottom()

        // self.temperatureView.transform = CGAffineTransformIdentity
        // self.currentConditionsView.transform = CGAffineTransformIdentity }
      }
    }
  
    
    /*
      if velocity.y < -1500 {
      // if translation.y < 0 {
        
       // self.temperatureView.transform = CGAffineTransformMakeTranslation(0, translation.y)
        
        
        UIView.animateWithDuration(0.25, delay: 0.0, usingSpringWithDamping: 0.9, initialSpringVelocity: 2.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
            self.currentConditionsView.transform = CGAffineTransformMakeTranslation(0, -self.view.frame.height + 162)
            self.temperatureView.transform = CGAffineTransformMakeTranslation(0, -self.view.frame.height + 60)
          
            self.realFeelTempLabel.hidden = true
            self.feelsLikeLabel.hidden = true
          // self.temperatureView.transform = CGAffineTransformMakeTranslation(0, -self.currentConditionsView.frame.height)
        
          }) { (complete) -> Void in
            
            // print("bottom view moved up")
        }
        
        
      }  else if translation.y < 0 {
        // else if velocity.y > -1500 && velocity.y < 0
        UIView.animateWithDuration(0.25, delay: 0.0, usingSpringWithDamping: 0.9, initialSpringVelocity: 2.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
          
          
          self.temperatureView.transform = CGAffineTransformMakeTranslation(0, -102)
          
          }) { (complete) -> Void in
            
            // print("bottom view moved up")
        }

      } else if translation.y > 0 {
        UIView.animateWithDuration(0.25, delay: 0.0, usingSpringWithDamping: 0.9, initialSpringVelocity: 2.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
            if self.isMapFullScreen {
              self.resizeMap(nil)
            }
            self.temperatureView.transform = CGAffineTransformIdentity
            self.currentConditionsView.transform = CGAffineTransformIdentity
            self.realFeelTempLabel.hidden = false
            self.feelsLikeLabel.hidden = false
            self.mapView.alpha = 0
          // self.temperatureView.transform = CGAffineTransformTranslate(self.temperatureView.transform, 0, 110)
          // self.currentConditionsView.hidden = false
          }) { (complete) -> Void in
            self.mapView.alpha = 1
            // print("bottom view moved down")
        }
      }
      */
  
  }
  
  func handleLongPress(gesture: UILongPressGestureRecognizer) {
    print(" i was long pressed ", terminator: "")
    
    let image = takeScreenShot()
    let textToShare: String = "via weathersbee. Get the app here: http://apple.co/1JHjKMf"
    
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
    
    layer.renderInContext(UIGraphicsGetCurrentContext()!)
    let screenshot = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return screenshot
  }

  
  func getWeatherConditions(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
    
    print(" getWeather called with lat \(latitude) and lon \(longitude) ", terminator: "")
    
    var precipProbByTime = [NSDate: Double]()
    
    
    let forecastID = valueForAPIKey(keyname: "API_CLIENT_ID")
    
    let urlPath = "https://api.forecast.io/forecast/\(forecastID)/" + String(latitude) + "," + String(longitude)
    
    let url = NSURL(string: urlPath)
    print(url!, terminator: "")
    
    let session = NSURLSession.sharedSession()
    let task = session.dataTaskWithURL(url!) { (data, response, error) -> Void in
      if error == nil {
        
        let jsonResult = (try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)) as! NSDictionary
        
       // print(" forecast result: \(jsonResult) ")
        
        if let currentConditions = jsonResult["currently"] as? NSDictionary {
          self.realFeelTemp = Int(round(currentConditions["apparentTemperature"] as! Double))
          print("real feel temp is: \(self.realFeelTemp)", terminator: "")
          self.ambientTemp = Int(round(currentConditions["temperature"] as! Double))
          self.windSpeed = Int(round(currentConditions["windSpeed"] as! Double))
          self.windDirection = self.getWindDirection(currentConditions["windBearing"] as! Int)
          self.humidity = Int((currentConditions["humidity"] as! Double) * 100)
          self.icon = currentConditions["icon"] as! String
          self.currentPrecipProb = currentConditions["precipProbability"] as! Double
        }
        
      
        let dailyData = jsonResult["daily"]!["data"]! as! NSArray
        let hourly = jsonResult["hourly"] as! NSDictionary
        
        
        self.todaySummary = dailyData[0]["summary"] as! String
        self.hiTemp = Int(round(dailyData[0]["temperatureMax"] as! Double))
        self.lowTemp = Int(round(dailyData[0]["temperatureMin"] as! Double))
        let todayHumidity = dailyData[0]["humidity"] as! Double
        // let todaywindSpeed = dailyData[0]["windSpeed"] as! Double
        self.todayPrecipProb = dailyData[0]["precipProbability"] as! Double
        self.sunriseTime = NSDate(timeIntervalSince1970: dailyData[0]["sunriseTime"] as! NSTimeInterval)
        self.sunsetTime = NSDate(timeIntervalSince1970: dailyData[0]["sunsetTime"] as! NSTimeInterval)
        
        self.hourlySummary = hourly["summary"] as! String
        
        let hourlyData = jsonResult["hourly"]!["data"]! as! NSArray
        
        self.futureHourlyData = []
        for var i = self.hourlyOffset; i <= self.hourlyOffset*5; i += self.hourlyOffset {
          self.futureHourlyData.append(hourlyData[i] as! NSDictionary)
        }
        
        
        for data in hourlyData {
          let time: NSDate = NSDate(timeIntervalSince1970: data["time"] as! NSTimeInterval)
          let temperature: Double = data["temperature"] as! Double
          let hourlyPrecipProb: Double = data["precipProbability"] as! Double
          self.futureTempsByTime[time] = temperature
          if self.userCalendar.isDateInToday(time) {
            precipProbByTime[time] = hourlyPrecipProb
          }
          if self.userCalendar.isDateInToday(time) && hourlyPrecipProb > self.minPrecipProb {
            let precipHour: String = self.format12H(time.hour())
            self.precipLikely.append(precipHour)
          }
        }
        
        
        // print(" precip by time is: \(precipProbByTime) ", terminator: "")
       // print( "nonsorted precip likely is: \(self.precipLikely) ", terminator: "")
 
        
        
       // print(" today summary: \(self.todaySummary)", terminator: "")
        // print(" hourly summary: \(self.hourlySummary)", terminator: "")
        
        
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

        self.getWeatherFinished = true
        if self.animationFinished == true {
          dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.displayWeatherData()
          })
        }
        
        
        
      } else {
        // something went wrong with API call to forecast
        print(error, terminator: "")
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
    
    weatherChecked = NSDate()

  }
  
  
  func displayWeatherData() {
    print(" **displayWeatherData called** ", terminator: "")
    // dispatch_async(dispatch_get_main_queue(), { () -> Void in
      
      self.getRealFeel(self.humidity, windSpeed: self.windSpeed, precipProb: self.todayPrecipProb, precipLikely: self.precipLikely)
      self.realFeelTempLabel.text = "\(self.realFeelTemp)º"
      if self.icon == "" {
        self.currentWeatherIcon.image = UIImage(named: "partly-cloudy-day")
      } else {
        self.currentWeatherIcon.image = UIImage(named: self.icon)
      }
      self.currentWeatherIcon.alpha = 0.5
      
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
   
      
      
      var futureTimes = [self.futureHour1Time, self.futureHour2Time, self.futureHour3Time, self.futureHour4Time, self.futureHour5Time]
      var futureImages = [self.futureHour1Image, self.futureHour2Image, self.futureHour3Image, self.futureHour4Image, self.futureHour5Image]
      var futureTemps = [self.futureHour1Temp, self.futureHour2Temp, self.futureHour3Temp, self.futureHour4Temp, self.futureHour5Temp]
      
      let formatter = NSDateFormatter()
      formatter.dateFormat = "h a"
      print(" futureHourlyData count \(self.futureHourlyData.count) ")
      for (index, value) in self.futureHourlyData.enumerate() {
        let time: NSDate = NSDate(timeIntervalSince1970: value["time"] as! NSTimeInterval)
        futureTimes[index].text = "\(formatter.stringFromDate(time))"
        let icon: UIImage = UIImage(named: value["icon"] as! String)!
        futureImages[index].image = icon
        futureImages[index].image = futureImages[index].image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        futureImages[index].tintColor = UIColor(hex: 0xF3F4F4) // (hex: 0xF3F4F4)
        futureImages[index].alpha = 0.5
        let temp: Double = value["temperature"] as! Double
        futureTemps[index].text = "\(Int(round(temp)))º"
      }
      
      formatter.timeStyle = .ShortStyle
      self.sunriseTimeLabel.text = formatter.stringFromDate(self.sunriseTime)
      self.sunsetTimeLabel.text = formatter.stringFromDate(self.sunsetTime)
      
      
      print(" bounce view count is: \(self.bounceViewCount) ", terminator: "")
      if NSUserDefaults.standardUserDefaults().integerForKey("bounceViewCount") < 1 && self.temperatureViewPosition == .Bottom {
        self.bounceView()
      }
      
    // })
  }
  
  func getWindDirection(bearing: Int) -> String {
    let cards = ["N", "NE", "E", "SE", "S", "SW", "W", "NW"]
    var dir = "N"
    for (i, card) in cards.enumerate() {
      if Double(bearing) < 45.0/2.0 + 45.0*Double(i) {
        dir = card
        break
      }
    }
    return dir
  }
  
  func getRealFeel(humidity: Int, windSpeed: Int, precipProb: Double, precipLikely: Array<String>? = []) {
    
    var uvIndex = 5
    var temp: String!
    var humidityFeel: String!
    var wind: String!
    var timeOfDay: String!
    
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
    case 61...74:
      humidityFeel = "sticky"
    case 75...100: //originally 80
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
    
    switch currentHour {
    case 00...11:
      timeOfDay = "morning"
    case 12...17:
      timeOfDay = "afternoon"
    case 18...24:
      timeOfDay = "evening"
    default:
      timeOfDay = "default"
    }
    
    if temp == "scorcher" {
      if humidityFeel == "sticky" {
        if wind == "calm" || wind == "light" {
          realFeel = "It’s African hot, find A/C stat"
        }
      } else if humidityFeel == "wet" {
        realFeel = "It’s middle-of-the jungle hot, stay indoors"
      } else if humidityFeel == "dry" {
        realFeel = "It’s oven-esque, find a cool shelter"
      } else {
        realFeel = "It’s a scorcher, grab a cold lemonade" // Ideal for bikram yoga, a.k.a gross
      }
      
    } else if temp == "hot" {
      if humidityFeel == "sticky" {
        if wind == "calm" || wind == "light" {
          realFeel = "It’s sweltering, find A/C stat" // BIRDLE
        } else {
          realFeel = "It’s sultry with a sticky breeze"
        }
      } else if humidityFeel == "wet" {
        realFeel = "It’s like a sauna, find A/C"
      } else if humidityFeel == "dry" {
        realFeel = "Not too bad in the shade, wear flip flops" // BIRDLE // perfect if you were a cactus
      } else {
        realFeel = "It’s stifling, break out the slip ’n slide" // BIRDLE // like sitting in a hot car without A/C
      }
      
    } else if temp == "warm" {
      if humidityFeel == "wet" {
        realFeel = "Doesn’t get much steamier than this"
      } else if humidityFeel == "sticky" {
        realFeel = "The air’s warm & thick, wear your linens" // BIRDLE // It's like a fresh cinna-bun, warm & sticky
        if wind == "breezy" {
          realFeel = "The air’s warm and thick but it’s breezy" // BIRDLE
        }
      } else if humidityFeel == "dry" {
        realFeel = "It’s nice in the shade, wear flip flops"
      } else {
        realFeel = "Sure is a warm one, find a waterin’ hole" // BIRDLE // Sure is warm, great time to jump in a pool //  It's like spring break in Mexico
      }
      
    } else if temp == "perfect" {
      if humidityFeel == "wet" {
        if wind == "breezy" {
          realFeel = "It’s sticky but there’s a breeze" // BIRDLE
        } else {
          realFeel = "It’s like lukewarm pea soup"
        }
      } else if humidityFeel == "sticky" {
        realFeel = "Nearly ideal, just a touch muggy" // BIRDLE
      } else {
        if timeOfDay == "evening" {
          realFeel = "Lovely for an evening stroll, it’s perfect"
        } else {
          realFeel = "Make time to play outside, it’s perfect"
        }
      }
      
    } else if temp == "nice" {
      if humidityFeel == "wet" {
        if wind != "calm" && wind != "light" {
          realFeel = "It’s like chilled pea soup"
        } else {
          realFeel = "It’s like pea soup"
        }
      } else if humidityFeel == "sticky" {
        realFeel = "Nearly ideal, just a touch muggy" // BIRDLE
      } else {
        realFeel = "Make time to play outside, it’s perfect"
      }
      
    } else if temp == "cool" {
      if humidityFeel == "dry" || humidityFeel == "comfortable" {
        if wind == "calm" || wind == "light" {
          realFeel = "It’s crisp, put on a long-sleeve shirt" // BIRDLE
        } else {
          realFeel = "It’s brisk, put on a sweatshirt" // BIRDLE
        }
      } else if humidityFeel == "sticky" {
        if wind == "calm" || wind == "light" {
          realFeel = "It’s cool out, wear a hoodie" // BIRDLE
        } else {
          realFeel = "It’s cool and breezy, wear a light jacket" // BIRDLE
        }
      } else if humidityFeel == "wet" {
        realFeel = "It’s like a San Fran summer, damp & chilly" // It's damp with a slight chill, wear a light jacket
      }
      
    } else if temp == "chilly" {
      if humidityFeel == "wet" {
        if wind != "calm" && wind != "light" {
          realFeel = "It’s miserably cold, wear a windbreaker" // , wear a windbreaker
        } else {
          realFeel = "It’s chilly and soggy, wear a rain jacket" // wear a rain jacket"
        }
      } else {
        realFeel = "It’s chilly, break out the sweater" // BIRDLE
      }
      
    } else if temp == "cold" {
      if wind != "calm" && wind != "light" {
        realFeel = "It’s bone chillingly cold, wear a thick coat" // BIRDLE
      } else {
        realFeel = "It’s cold, wear your best chinchilla"
      }
      
    } else if temp == "freezing" {
      if (humidityFeel != "dry" && humidityFeel != "comfortable") && (wind != "calm" && wind != "light") {
        realFeel = "It’s bone chilling, layer up"
      } else {
        realFeel = "It’s literally freezing, wear a heavy coat" // BIRDLE
      }
      
    } else if temp == "bitterlycold" {
      if wind != "calm" && wind != "light" {
        realFeel = "It’s bitterly cold, wear a beanie" // BIRDLE // It's colder than a Norwegian well digger's pinky toe // It’s bitterly, wish I lived in Florida cold // wear a heavy coat and beanie
      } else {
        realFeel = "It’s like a wind tunnel in Canada, eh" // , wear your heaviest coat
      }
      
    } else if temp == "subzero" {
      realFeel = "Yikes, stay indoors to avoid frostbite" // So this is what Antartica feels like, huh.
    }
  
    
    
    print("realFeel is: \(realFeel)", terminator: "")
    
    var attributedRealFeel = NSMutableAttributedString(string: realFeel, attributes: attributes as? [String: AnyObject])

    
    //realFeelLabel.text = realFeel
    realFeelLabel.attributedText = attributedRealFeel
    
    setSummary(self.todayPrecipProb, uvIndex: maxUVIndex, temp: temp, wind: wind)
    
    // set the colors for the icons
    setIconColor(temperatureView.backgroundColor!)
    
    print(" \(temp), \(humidityFeel), and \(wind) in the \(timeOfDay) ", terminator: "")

  }
  
  func setIconColor(color: UIColor) { // temp: String
    /*
    windIcon.image = UIImage(named: "wind-icon-\(temp)")
    humidityIcon.image = UIImage(named: "humidity-icon-\(temp)")
    uvIcon.image = UIImage(named: "uv-icon-\(temp)")
    */
    windIcon.image = windIcon.image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
    windIcon.tintColor = color
    humidityIcon.image = humidityIcon.image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
    humidityIcon.tintColor = color
    uvIcon.image = uvIcon.image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
    uvIcon.tintColor = color
    
  }
  
  // TODO: figure out better way to handle wear recs
  func setSummary(precipProb: Double?, uvIndex: Int?, temp: String? = nil, wind: String? = nil) {
   
    var summary = ""
    print(" **setting summary** ", terminator: "")
    print(" current hour is: \(currentHour) ", terminator: "")
    print(" lastUVIndexHour is: \(lastUVIndexHour) ", terminator: "")
    print(" precipProb is: \(precipProb) ", terminator: "")
    
    // switch to hourly summary at 12pm
    if currentHour < 12 {
      summary = todaySummary
    } else {
      summary = hourlySummary
    }
    
    // if precipProb > minPrecipProb
    print(" precipLikely is \(precipLikely) ")
    print(" current precip prob is \(currentPrecipProb) ")
    if !precipLikely.isEmpty || currentPrecipProb > minPrecipProb {
      let grabUmbrella = "Grab an umbrella. "
      // let precipHours = join(", ", precipLikely)
      // summary = "Rain's likely for the \(precipHours) hour. " + summary
      provideRecommendation(grabUmbrella, summary: summary, color: chillyColor)
    } else if (temp == "nice" || temp == "chilly") && (wind == "breezy" || wind == "blustery") {
      provideRecommendation("Wear a windbreaker. ", summary: summary)
    } else if maxUVIndex >= minUVForNotice && currentHour < (lastUVIndexHour + 1) { 
      print(" getting uvIndexNotice ", terminator: "")
      let uvNotice = uvIndexNotice(uvByTime)
      provideRecommendation(uvNotice.recommendation, summary: summary, color: uvNotice.color)
    } else {
      summaryLabel.text = summary
    }
    
  }
  
  
  func getUVIndex(postalCode: String) {
    
      let urlPath = "http://iaspub.epa.gov/enviro/efservice/getEnvirofactsUVHOURLY/ZIP/\(postalCode)/JSON"
      
      guard let url = NSURL(string: urlPath) else { return }
      
      let session = NSURLSession.sharedSession()
    
      let task = session.dataTaskWithURL(url) { (data, response, error) -> Void in
        // print(" response is \(response) ")
        // print(" error on UVindex: \(error) ", terminator: "")
        if error == nil {
          
          do {
            let jsonResult = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as? NSArray
            // print(jsonResult)
            for data in jsonResult! {
              
              let time = data["DATE_TIME"] as! String
              let formattedTime = self.formatMilitaryTime(self.formatTime(time))
              let uvIndex = data["UV_VALUE"] as! Int
              self.uvByTime[formattedTime] = uvIndex
              
            }
            // print(" uvByTime: \(self.uvByTime) ", terminator: "")
            
            for (time, uvIndex) in self.uvByTime {
              if uvIndex > self.maxUVIndex {
                self.maxUVIndex = uvIndex
                self.maxUVTime = time
              }
              // get the last hour where the UV index is over the min threshold
              if uvIndex >= self.minUVForNotice {
                if time > self.lastUVIndexHour {
                  self.lastUVIndexHour = time
                }
              }
            }
            
            print(" maxUVIndex is: \(self.maxUVIndex) ", terminator: "")
            print(" lastUVIndex hour is: \(self.lastUVIndexHour) ", terminator: "")
            
            
            
            
            
            /*
            if let currentConditions = jsonResult["currently"] {
            self.realFeelTemp = Int(round(currentConditions["apparentTemperature"] as! Double))
            print("real feel temp is: \(self.realFeelTemp)")
            
            }
            
            
            
            
            
            let todaySummary = dailyData[0]["summary"] as! String
            self.summary = todaySummary
            
            
            */
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
              if !self.uvByTime.isEmpty {
                self.uvIndexLabel.text = "\(self.uvByTime[self.currentHour]!)"
              }
              if self.animationFinished && self.currentHour < (self.lastUVIndexHour + 1){
                self.setSummary(self.todayPrecipProb, uvIndex: self.maxUVIndex)
              }
            })
          
          } catch {
            // something went wrong with API call to EPA
            print(" uv EPA error: \(error) ", terminator: "")
            self.uvIndexLabel.text = "-"
          }
        }
    }
    task.resume()
    uvChecked = NSDate()
          // print(" data is: \(data) ")
  /* swift 1.2
          if let jsonResult = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)) as? NSArray {
          
          // print(" uv index json: \(jsonResult)")
          
          
            for data in jsonResult {
              
              let time = data["DATE_TIME"] as! String
              let formattedTime = self.formatMilitaryTime(self.formatTime(time))
              let uvIndex = data["UV_VALUE"] as! Int
              self.uvByTime[formattedTime] = uvIndex
              
            }
            print(" uvByTime: \(self.uvByTime) ", terminator: "")
            
            for (time, uvIndex) in self.uvByTime {
              if uvIndex > self.maxUVIndex {
                self.maxUVIndex = uvIndex
                self.maxUVTime = time
              }
              // get the last hour where the UV index is over the min threshold
              if uvIndex >= self.minUVForNotice {
                if time > self.lastUVIndexHour {
                  self.lastUVIndexHour = time
                }
              }
            }
            
            print(" maxUVIndex is: \(self.maxUVIndex) ", terminator: "")
            print(" lastUVIndex hour is: \(self.lastUVIndexHour) ", terminator: "")
            
            
            
            
            
            /*
            if let currentConditions = jsonResult["currently"] {
            self.realFeelTemp = Int(round(currentConditions["apparentTemperature"] as! Double))
            print("real feel temp is: \(self.realFeelTemp)")
            
            }
            
            
            
            
            
            let todaySummary = dailyData[0]["summary"] as! String
            self.summary = todaySummary
            
            
            */
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
              if !self.uvByTime.isEmpty {
                self.uvIndexLabel.text = "\(self.uvByTime[self.currentHour]!)"
              }
              if self.animationFinished {
                self.setSummary(self.todayPrecipProb, uvIndex: self.maxUVIndex)
              }
            })
          }
        } else {
          // something went wrong with API call to EPA
          print(" uv EPA error: \(error) ", terminator: "")
          self.uvIndexLabel.text = "-"
        }
      }
      
      task.resume()

      uvChecked = NSDate()

    //}
    */
  }
  
  func uvIndexNotice(uvByTime: Dictionary<Int, Int>) -> (recommendation: String, color: UIColor) {
    
    print(" **uvIndexNotice called** ", terminator: "")
    
    var uvTimes: [Int] = []
    var uvValues: [Int] = []
    var uvTimesSunburn: [String] = []
    var uvTimesExtreme: [String] = []
    var uvRecommendation = ""
    var colorRecommendation: UIColor
    
    // sort the uvByTime into separate k, v arrays
    for (k, v) in Array(uvByTime).sort({$0.0 < $1.0}) {
      // print("\(k): \(v)")
      uvTimes.append(k)
      uvValues.append(v)
    }
    
    let sorteduvByTime = Array(uvByTime).sort({$0.0 < $1.0})
    
    print(" uvByTime: \(uvByTime) ", terminator: "")
    print(" sorteduvByTime: \(sorteduvByTime) ", terminator: "")
    
    for index in 1..<uvValues.count {
      // print(Int(round((Double(uvValues[index]) + Double(uvValues[index-1]))/2.0)))
      // if Int(round((Double(uvValues[index]) + Double(uvValues[index-1]))/2.0)) >= minUVForExtreme || uvValues[index] >= minUVForExtreme
      if uvValues[index] >= minUVForExtreme || uvValues[index-1] >= minUVForExtreme {
        uvTimesExtreme.append(format12H(uvTimes[index]))
      } else if uvValues[index] >= minUVForNotice || uvValues[index-1] >= minUVForNotice {
        uvTimesSunburn.append(format12H(uvTimes[index]))
      }
    }
    
    print(" uvTimesExtreme: \(uvTimesExtreme) ", terminator: "")
    print(" uvTimesSunburn: \(uvTimesSunburn) ", terminator: "")
    
    if !uvTimesExtreme.isEmpty && currentHour < formatMilitaryTime(uvTimesExtreme.last!) {
      colorRecommendation = scorcherColor
      if uvTimesExtreme.count == 1 {
        uvRecommendation = "Avoid the sun for the \(uvTimesExtreme.first!) hour. "
      } else {
        uvRecommendation = "Avoid the sun between \(uvTimesExtreme.first!) - \(uvTimesExtreme.last!). "
      }
    } else {
      // else if currentHour < formatMilitaryTime(sortedUVTimesSunburn.last!)
      colorRecommendation = hotColor
      uvRecommendation = "Use sunscreen from \(uvTimesSunburn.first!) - \(uvTimesSunburn.last!). "
    }

    /*
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
      colorRecommendation = scorcherColor
      if uvTimesExtreme.count == 1 {
        uvRecommendation = "Avoid the sun for the \(sortedUVTimesExtreme.first!) hour. "
      } else {
      uvRecommendation = "Avoid the sun between \(sortedUVTimesExtreme.first!) - \(sortedUVTimesExtreme.last!). "
      }
    } else {
      // else if currentHour < formatMilitaryTime(sortedUVTimesSunburn.last!)
      colorRecommendation = hotColor
      uvRecommendation = "Use sunscreen from \(sortedUVTimesSunburn.first!) - \(sortedUVTimesSunburn.last!). "
    }
    */
    
    return (uvRecommendation, colorRecommendation)
    
  }
  
  func provideRecommendation(recommendation: String, summary: String, var color: UIColor? = nil) {
    print(" *providing a recommendation* ", terminator: "")
    
    let recommendationAndSummary = recommendation + summary
    var attributedSummary = NSMutableAttributedString(string: summary)
    let styledRecommendationandSummary = NSMutableAttributedString(string: recommendationAndSummary)
    
    // set color to background color if not provided explicitly
    if color == nil {
      color = temperatureView.backgroundColor
    }
    
    styledRecommendationandSummary.addAttribute(NSForegroundColorAttributeName, value: color!, range: NSRange(location: 0, length: recommendation.characters.count))
    
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
    
    return Int(militaryTime)!
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

