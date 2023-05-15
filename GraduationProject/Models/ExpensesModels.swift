//
//  Expenses.swift
//  GraduationProject
//
//  Created by Александр Муклинов on 26.04.2023.
//

import Foundation
import CoreData


@objc(Expense)
public class Expense: NSManagedObject {

}

extension Expense {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Expense> {
        return NSFetchRequest<Expense>(entityName: "Expense")
    }

    @NSManaged public var date: Date?
    @NSManaged public var expense: Int64
    @NSManaged public var name: String?
    @NSManaged public var expeseToExpenseCategory: ExpenseCategory?

}

extension Expense : Identifiable {

}


@objc(ExpenseCategory)
public class ExpenseCategory: NSManagedObject {

}

extension ExpenseCategory {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ExpenseCategory> {
        return NSFetchRequest<ExpenseCategory>(entityName: "ExpenseCategory")
    }

    @NSManaged public var name: String?
    @NSManaged public var expenseCategoryToExpenses: Expenses?
    @NSManaged public var quantity: NSOrderedSet?

}

// MARK: Generated accessors for quantity
extension ExpenseCategory {

    @objc(insertObject:inQuantityAtIndex:)
    @NSManaged public func insertIntoQuantity(_ value: Expense, at idx: Int)

    @objc(removeObjectFromQuantityAtIndex:)
    @NSManaged public func removeFromQuantity(at idx: Int)

    @objc(insertQuantity:atIndexes:)
    @NSManaged public func insertIntoQuantity(_ values: [Expense], at indexes: NSIndexSet)

    @objc(removeQuantityAtIndexes:)
    @NSManaged public func removeFromQuantity(at indexes: NSIndexSet)

    @objc(replaceObjectInQuantityAtIndex:withObject:)
    @NSManaged public func replaceQuantity(at idx: Int, with value: Expense)

    @objc(replaceQuantityAtIndexes:withQuantity:)
    @NSManaged public func replaceQuantity(at indexes: NSIndexSet, with values: [Expense])

    @objc(addQuantityObject:)
    @NSManaged public func addToQuantity(_ value: Expense)

    @objc(removeQuantityObject:)
    @NSManaged public func removeFromQuantity(_ value: Expense)

    @objc(addQuantity:)
    @NSManaged public func addToQuantity(_ values: NSOrderedSet)

    @objc(removeQuantity:)
    @NSManaged public func removeFromQuantity(_ values: NSOrderedSet)

}

extension ExpenseCategory : Identifiable {

}


@objc(Expenses)
public class Expenses: NSManagedObject {

}

extension Expenses {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Expenses> {
        return NSFetchRequest<Expenses>(entityName: "Expenses")
    }

    @NSManaged public var quantity: NSOrderedSet?

}

// MARK: Generated accessors for quantity
extension Expenses {

    @objc(insertObject:inQuantityAtIndex:)
    @NSManaged public func insertIntoQuantity(_ value: ExpenseCategory, at idx: Int)

    @objc(removeObjectFromQuantityAtIndex:)
    @NSManaged public func removeFromQuantity(at idx: Int)

    @objc(insertQuantity:atIndexes:)
    @NSManaged public func insertIntoQuantity(_ values: [ExpenseCategory], at indexes: NSIndexSet)

    @objc(removeQuantityAtIndexes:)
    @NSManaged public func removeFromQuantity(at indexes: NSIndexSet)

    @objc(replaceObjectInQuantityAtIndex:withObject:)
    @NSManaged public func replaceQuantity(at idx: Int, with value: ExpenseCategory)

    @objc(replaceQuantityAtIndexes:withQuantity:)
    @NSManaged public func replaceQuantity(at indexes: NSIndexSet, with values: [ExpenseCategory])

    @objc(addQuantityObject:)
    @NSManaged public func addToQuantity(_ value: ExpenseCategory)

    @objc(removeQuantityObject:)
    @NSManaged public func removeFromQuantity(_ value: ExpenseCategory)

    @objc(addQuantity:)
    @NSManaged public func addToQuantity(_ values: NSOrderedSet)

    @objc(removeQuantity:)
    @NSManaged public func removeFromQuantity(_ values: NSOrderedSet)

}

extension Expenses : Identifiable {

}
