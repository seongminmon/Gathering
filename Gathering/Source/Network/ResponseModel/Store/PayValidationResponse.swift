//
//  PayValidationResponse.swift
//  Gathering
//
//  Created by 김성민 on 11/7/24.
//

import Foundation

struct PayValidationResponse: Decodable {
    let billing_id: String
    let merchant_uid: String
    let buyer_id: String
    let productName: String
    let price: Int
    let sesacCoin: Int
    let paidAt: String
}
