//
//  ResponseModel.swift
//  MyFirstApp
//
//  Created by Amita Ghosh on 2/23/23.
//

import Foundation

// Data model for the response from openWeather API

struct Coordinate : Codable{
    var lon : Double
    var lat : Double
}
struct Weather : Codable{
    var id : Int
    var main : String
    var description : String?
    var icon : String
}
struct mainData : Codable{
    var temp:Double
    var feels_like:Double?
    var temp_min : Double?
    var temp_max : Double?
    var pressure :Double?
    var humidity : Double?
}
struct Sys:Codable{
    var type : Int?
    var id : Int
    var country : String?
    var sunrise : Int?
    var sunset : Int?
}
struct Clouds:Codable{
    var all : Int?
}
struct Wind: Codable{
    var speed : Double
    var deg : Double
    var gust : Double?
}
struct ResponseModel : Codable {
    var coord : Coordinate
    var weather : [Weather]?
    var base : String?
    var main : mainData
    var visibility : Double?
    var wind : Wind
    var clouds : Clouds
    var dt : Int?
    var sys : Sys?
    var timezone : Int?
    var id : Int
    var name: String
    var cod : Int?
}

