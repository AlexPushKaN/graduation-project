//
//  ExpenseTableViewCell.swift
//  GraduationProject
//
//  Created by Александр Муклинов on 13.04.2023.
//

import UIKit

final class ExpenseTableViewCell: UITableViewCell {
    
    @IBOutlet weak var nameExpense: UILabel!
    @IBOutlet weak var dateExpense: UILabel!
    @IBOutlet weak var expense: UILabel!
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
