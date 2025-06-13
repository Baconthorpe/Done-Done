//
//  Date.swift
//  Done Done
//
//  Created by Ezekiel Abuhoff on 6/11/25.
//

import Foundation

extension Date {
    public var deadlineFormat: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        return dateFormatter.string(from: self)
    }
}
