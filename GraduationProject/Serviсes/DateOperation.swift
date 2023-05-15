//
//  DateOperation.swift
//  GraduationProject
//
//  Created by Александр Муклинов on 03.05.2023.
//

import Foundation

//MARK: - класс для преобразования даты в строку и наоборот, а также формирования даты в формате "yyyy-MM-dd HH:mm:ss", "yyyy-MM-dd"
class DateOperation {
    
    static let date:Date = Date()

    static func stringToDateFormat(dateString:String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let date = dateFormatter.date(from: dateString)
        return date
    }
    
    static func dateToStringFormatOne(date:Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateString = dateFormatter.string(from: date)
        return dateString
    }
    
    static func dateToStringFormatTwo(date:Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: date)
        return dateString
    }
}
