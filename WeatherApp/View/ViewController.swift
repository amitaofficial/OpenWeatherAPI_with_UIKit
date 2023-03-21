//
//  ViewController.swift
//  WeatherApp
//
//  Created by Amita Ghosh on 3/8/23.
//

import UIKit
import CoreLocation


class ViewController: UIViewController,CLLocationManagerDelegate,UISearchBarDelegate {
    
    //MARK: Variables
    var locationManager : CLLocationManager!
    
    var geoCodingDone : Bool = false
    
    var userLatitude : Double = 33.0198 //default plano,Texas latitude
    var userLongitude : Double = 96.6989 //default plano,Texas longitude

    var response : ResponseModel?
    

    
    
    //MARK: IBOutlets
    @IBOutlet weak var cityName: UILabel!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var temperatureLabel: UILabel!
    
    @IBOutlet weak var activityIndiactor: UIActivityIndicatorView!
    
    @IBOutlet weak var iconImageview: UIImageView!
    
    @IBOutlet weak var stackView: UIStackView!
    
   
    //MARK: view
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self

        checkLocation()
        callWeatherAPI()
        
    }
    
    //MARK:  Location methods
    
//      function checkLocation - No input parameters
//      To check if there was a previous location used by the user from User defaults and if there is , show        that location else get the current location of the user
    func checkLocation(){
        let priorLocationExists = checkDataExistsInUserDefaults()
        if priorLocationExists{
            if (UserDefaults.standard.object(forKey: "city") != nil){
                let city : String = UserDefaults.standard.object(forKey: "city") as! String
                if !city.isEmpty{
                    cityName.text = city
                }
                else{
                    getCurrentLocation()
                }
               
            }
            else{
                print("no city name")
            }
        }
        else{
            getCurrentLocation()
        }
    }
    
//  function callWeatherAPI - No input parameters
//  To call the openWeatherApi for the user's city name
    
    func callWeatherAPI(){
        var cname : String = self.cityName.text ?? ""
        
        //Setting  'Plano' as default location in case user did not accept to authorise location
        if cname.isEmpty{
            cname = "Plano"
            self.cityName.text = cname
        }
        let escapedCityString = cname.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) // to account for spaces in the URL

        // API Key is hard coded here for now so that testing can be done . Will remove in couple of days. Ideally it needs to be added in a config file and secure it.
        let urlString : String = "https://api.openweathermap.org/data/2.5/weather?q=\(escapedCityString!)&appid=&units=imperial" //api key removed since this code base is public
        
        print(urlString) // debug statement
        
        activityIndiactor.startAnimating()

        // calling webservice
        callApI(urlString: urlString,cityName: cname) {
            print("API call completed")
            if let response = self.response{
                DispatchQueue.main.async {
                    self.activityIndiactor.stopAnimating()
                    self.temperatureLabel.text = "\(response.main.temp) °F"
                    if let iconImage = response.weather?[0].icon{ // download appropriate weather icon
                        self.iconImageview.loadImageFromURLString(from: "https://openweathermap.org/img/wn/\(iconImage)@2x.png")
                    }
                    else{
                        self.iconImageview.image = UIImage(systemName: "cloud.fill") // show an icon in case no image was downloaded
                    }
                    
                }
            }
            else{
                DispatchQueue.main.async {
                    // show error in case of any API call error
                    let alertMessage = UIAlertController(title: "Alert!", message:"Webservice Error!", preferredStyle: .alert)
                    let okButton = UIAlertAction(title: "OK", style: .default)
                    alertMessage.addAction(okButton)
                    self.present(alertMessage, animated: true, completion: nil)

                    self.activityIndiactor.stopAnimating()
                }
                
            }
        }
    }
    
//    function getCurrentLocation - No input parameters
//    To get current location of the user
    func getCurrentLocation(){
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()

    }
    
//  function getCurrentLocation - with input parameters latitude:Double and longitude:Double
//  To save the user location to UserDefaults so that we can access on relaunching the app also
    func setUserLocation(latitude:Double,longitude:Double){
        userLatitude = latitude
        userLongitude = longitude
        setUserDefaults()
    }
    
    //MARK: User Defaults
//    function setUserDefaults - No input parameters
//    To save the user location to UserDefaults so that we can access on relaunching the app also
    func setUserDefaults(){
        UserDefaults.standard.set(userLatitude, forKey: "latitude")
        UserDefaults.standard.set(userLongitude, forKey: "longitude")
    }
    
//    function setCityInUserDefaults - No input parameters
//    To save the city name to UserDefaults so that we can access on relaunching the app also
    func setCityInUserDefaults(){
        UserDefaults.standard.set(self.cityName.text, forKey: "city")
    }
    
//  function checkDataExistsInUserDefaults - No input parameters
//  return type: Bool
//  To check if any data is present in UserDefaults
    func checkDataExistsInUserDefaults()->Bool{
        if (UserDefaults.standard.object(forKey: "latitude") != nil) && (UserDefaults.standard.object(forKey: "longitude") != nil){
            setUserLocation(latitude: UserDefaults.standard.double(forKey: "latitude"), longitude: UserDefaults.standard.double(forKey: "longitude"))
            return true
        }
        return false
    }
    
    //MARK: Forward GeoCoder
    
    //  function useGeoCoder_Forward - with input parameters inputString : String
    //  To geo code from city name to lat and llong values and update the weather
    func useGeoCoder_Forward(inputString : String)->Void {
        let geoCoder = CLGeocoder()
        var addressString = ""
        geoCoder.geocodeAddressString(inputString) { placemarks, error in
            if(error == nil){
                if let placemarks = placemarks{
                    let placemark = placemarks[0]
                    let address = "\(placemark.locality ?? "")" // only get city name
                    addressString = "\(address)"
                    if !addressString.isEmpty{
                        DispatchQueue.main.async {
                            self.cityName.text = addressString // update city label
                            self.setCityInUserDefaults() //update user defaults
                            self.setUserLocation(latitude: (placemark.location?.coordinate.latitude)!, longitude: (placemark.location?.coordinate.longitude)!)
                            self.callWeatherAPI() //update weather
                        }
                    }
                }
            }
            else{
                print("error in useGeoCoder_Forward,\(String(describing: error))")
                let alertMessage = UIAlertController(title: "Alert!", message: "Please enter a valid US city name", preferredStyle: .alert)
                let okButton = UIAlertAction(title: "OK", style: .default)
                alertMessage.addAction(okButton)
                self.present(alertMessage, animated: true, completion: nil)

            }
        }
    }
    
    
    
    //MARK: Reverse GeoCoder
    
    //  function useGeoCoder_Reverse - with input parameters lat: Double, longitude : Double
    //  To geo code from lat,long to city name and update the weather
    func useGeoCoder_Reverse(lat: Double, longitude : Double) -> Void{
        let geoCoder = CLGeocoder()
        var addressString = ""
        let inputLocation = CLLocation(latitude: lat, longitude: longitude)
        geoCoder.reverseGeocodeLocation(inputLocation) { placemarks, error in
            if(error == nil){
                if let placemarks = placemarks{
                    let placemark = placemarks[0]
                    let address = "\(placemark.locality ?? "")" // only get city name
                    addressString = "\(address)"
                    DispatchQueue.main.async {
                        self.cityName.text = addressString // update city label
                        self.setCityInUserDefaults() //update user defaults
                        self.callWeatherAPI() //update weather

                    }
                }
            }
        }
    }


    //MARK: CLLocation Delegates
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation : CLLocation = locations[0] as CLLocation
        print(userLocation.coordinate.latitude)
        setUserLocation(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude) // save user location
        useGeoCoder_Reverse(lat: userLatitude, longitude: userLongitude) // reverse geocode
       
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription) // show  error in getting location
    }
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        locationManager.startUpdatingLocation()

    }
    //MARK: UISearchBar Delegates
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        return true
    }
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.becomeFirstResponder()
    }
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        return true
    }
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        if let inputString = searchBar.text{
           useGeoCoder_Forward(inputString: inputString)

        }
        else{
            print("No input entered")
        }
    }

    //MARK: API Call
    
    //  function callApI - with input parameters lat: urlString:String,cityName:String,completion
    //  To call the WebService module to get weather data
    func callApI(urlString:String,cityName:String,completion: @escaping()->Void){
        
        WebService.shared.callWebService(input_url: urlString, completion: { (result : Result<ResponseModel,WebServiceError>) in
            
            switch result {
            case .success(let response):
                self.response = response
                print(response)
            case .failure(let failure):
                switch failure {
                case .noURLError:
                    print("no url provided")
                case .noResponseDataError:
                    print("no response data")
                case .otherError(let errorString):
                    print(errorString)
                }
            }
            completion() // call completion block
        })
    }
}

//MARK: UIImageView extension
var imageCache = NSCache<AnyObject, AnyObject>() // to cache images which are already downloaded

extension UIImageView {
    
//    function download - with input parameters from url: URL, contentMode mode: ContentMode = .scaleAspectFit
//    To download images from remote URL and store in cache
    func download(from url: URL, contentMode mode: ContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            imageCache.setObject(image, forKey: url.absoluteString as AnyObject)
            DispatchQueue.main.async() { [weak self] in
                self?.image = image
            }
        }.resume()
    }
    
    //    function loadImageFromURLString - with input parameters from inputURL: URL, contentMode mode: ContentMode = .scaleAspectFit
    //    To load image from cache/URL to imageview
    func loadImageFromURLString(from inputURL: String, contentMode mode: ContentMode = .scaleAspectFit) {
        // check if image is laready in cache
        if let cacheImage = imageCache.object(forKey: inputURL as AnyObject) as? UIImage {
                   self.image = cacheImage
                   return
               }
        // dowwnload image from url
        guard let url = URL(string: inputURL) else { return }
        download(from: url, contentMode: mode)
    }
}
