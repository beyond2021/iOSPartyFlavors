//
//  Breverage.swift
//  iOSPartyFlavors
//
//  Created by KEEVIN MITCHELL on 11/27/20.
// to store the breverages
// note no Content like Vapor - content is a vapor thing that means jSON or not
// Swift thing Codeable means this thing is Codeable - means to decode JSON


import Foundation

struct Breverage: Codable {
    var id: UUID
    var name: String
    var description: String
    var price: Int
    
}
