//
//  Models.swift
//  GraduationProject
//
//  Created by Александр Муклинов on 07.04.2023.
//

import Foundation
import CoreData

@objc(Income)
public class Income: NSManagedObject {

}

extension Income {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Income> {
        return NSFetchRequest<Income>(entityName: "Income")
    }

    @NSManaged public var income: Int64
    @NSManaged public var date: Date
    @NSManaged public var incomeToIncomes: Incomes?

}

extension Income : Identifiable {

}

@objc(Incomes)
public class Incomes: NSManagedObject {

}

extension Incomes {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Incomes> {
        return NSFetchRequest<Incomes>(entityName: "Incomes")
    }

    @NSManaged public var cashAccount: Int64
    @NSManaged public var quantity: NSOrderedSet?

}

// MARK: Generated accessors for quantity
extension Incomes {

    @objc(insertObject:inQuantityAtIndex:)
    @NSManaged public func insertIntoQuantity(_ value: Income, at idx: Int)

    @objc(removeObjectFromQuantityAtIndex:)
    @NSManaged public func removeFromQuantity(at idx: Int)

    @objc(insertQuantity:atIndexes:)
    @NSManaged public func insertIntoQuantity(_ values: [Income], at indexes: NSIndexSet)

    @objc(removeQuantityAtIndexes:)
    @NSManaged public func removeFromQuantity(at indexes: NSIndexSet)

    @objc(replaceObjectInQuantityAtIndex:withObject:)
    @NSManaged public func replaceQuantity(at idx: Int, with value: Income)

    @objc(replaceQuantityAtIndexes:withQuantity:)
    @NSManaged public func replaceQuantity(at indexes: NSIndexSet, with values: [Income])

    @objc(addQuantityObject:)
    @NSManaged public func addToQuantity(_ value: Income)

    @objc(removeQuantityObject:)
    @NSManaged public func removeFromQuantity(_ value: Income)

    @objc(addQuantity:)
    @NSManaged public func addToQuantity(_ values: NSOrderedSet)

    @objc(removeQuantity:)
    @NSManaged public func removeFromQuantity(_ values: NSOrderedSet)

}

extension Incomes : Identifiable {

}
