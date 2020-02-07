//
//  ProductStore.swift
//  NFCProductScanner
//
//  Created by Andrew Carvajal on 2/6/20.
//  Copyright © 2020 Alfian Losari. All rights reserved.
//

import UIKit

struct ProductStore {

    static let shared = ProductStore()
    private init() {}

    func product(withID id: String) -> Product? {
        return products.first { $0.id.lowercased() == id.lowercased() }
    }
    
    let products = [
        Product(id: "SKU-RES2-982019",
                name: "RESIDENT EVIL 2",
                description: """
                The action centers around rookie cop Leon Kennedy and college student Claire Redfield as they fight to survive a mysterious viral outbreak within Raccoon City.
                """,
                price: "$60.00",
                inStock: true,
                image: UIImage(named: "res2")),
        Product(id: "SKU-KH3-0119",
                name: "KINGDOM HEARTS 3",
                description: """
                KINGDOM HEARTS III tells the story of the power of friendship as Sora and his friends embark on a perilous adventure.
                """,
                price: "$60.00",
                inStock: true,
                image: UIImage(named: "kh3")),
        Product(id: "SKU-IPXSM-2018",
                name: "iPhone Xs Max",
                description: """
                The smartest, most powerful chip in a smartphone. And a breakthrough dual-camera system.
                """,
                price: "$999.00",
                inStock: false,
                image: UIImage(named: "xsmax"))
    ]
}
