//
//  CoreDataManager.swift
//  GraduationProject
//
//  Created by Александр Муклинов on 25.04.2023.
//

import UIKit
import CoreData

enum Object:String {
    case income = "Income"
    case incomes = "Incomes"
    case expense = "Expense"
    case expenseCategory = "ExpenseCategory"
    case expenses = "Expenses"
}

public final class CoreDataManager {

    static let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    static var context = {
        return appDelegate.persistentContainer.viewContext
    }()
    
    static func save() {
        appDelegate.saveContext()
    }
    
    static func create(object:Object) -> AnyObject? {
        
        var anyObject:AnyObject?
        
        let entity = NSEntityDescription.entity(forEntityName: object.rawValue, in: context)
        guard let entity = entity else { return nil }
        
        switch object {
        case .income:
            anyObject = Income(entity: entity, insertInto: context)
        case .incomes:
            anyObject = Incomes(entity: entity, insertInto: context)
        case .expense:
            anyObject = Expense(entity: entity, insertInto: context)
        case .expenseCategory:
            anyObject = ExpenseCategory(entity: entity, insertInto: context)
        case .expenses:
            anyObject = Expenses(entity: entity, insertInto: context)
        }

        return anyObject as AnyObject
    }
    
    static func getObjectFromData(object:Object) -> NSManagedObject? {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: object.rawValue)
        
        do {
            let result = try context.fetch(fetchRequest)
            if let object = result.first as? NSManagedObject {
                return object
            }
        } catch {
            print("Failed to fetch object: \(error.localizedDescription)")
        }
        return nil
    }
}
