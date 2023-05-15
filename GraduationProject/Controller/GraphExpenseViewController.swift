//
//  ChartIncomeAndExpenseViewController.swift
//  GraduationProject
//
//  Created by Александр Муклинов on 14.04.2023.
//

import UIKit

final class GraphExpenseViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var timeIntervalStackView: UIStackView!
    @IBOutlet weak var graphFieldScrollView: UIScrollView!
    @IBOutlet weak var valueScaleGraphScrollView: ValueScaleGraphScrollView!
    @IBOutlet weak var dateScaleGraphScrollView: DateScaleGraphScrollView!

    var expenseCategory:ExpenseCategory?
    private var arrayValues:[Int] = []
    private var valueScaleCoefficientInt:Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        graphFieldScrollView.delegate = self
        configureGraphView(timeInterval: .week)
    }

    @IBAction func pressedButtonTimeInterval(_ sender:UIButton) {
        
        for subView in timeIntervalStackView.subviews {
            if let button = subView as? UIButton{
                button.isSelected = false
            }
        }

        if !sender.isSelected {
            sender.isSelected = true
            guard let interval = sender.titleLabel?.text else { return }
            configureGraphView(timeInterval: TimeInterval.init(rawValue: interval) ?? .week)
        }
    }
    
    private func configureGraphView(timeInterval:TimeInterval) {

        // - получаем данные о транзакциях из моделей данных
        guard let expenseCategory = self.expenseCategory else { return }
        var transactionDatesExpense:[Date] = []
        for expense in expenseCategory.quantity!.array as! [Expense] {
            transactionDatesExpense.append(expense.date!)
        }
        
        // - получаем количество дней для вычисления размеров поля графика
        let amountDays = getAmountDays(timeInterval: timeInterval, datesArray: transactionDatesExpense)

        let graphFieldView = GraphFieldView()
        graphFieldView.backgroundColor = .white
        graphFieldView.configurateView(amountDays: CGFloat(amountDays))

        graphFieldScrollView.contentSize = CGSize(width: graphFieldView.frame.width, height: graphFieldView.frame.height)
        graphFieldScrollView.addSubview(graphFieldView)

        // - создаем переменную для хранения размера графика
        let size = graphFieldScrollView.contentSize

        // - получаем массив значений для шкалы значений графика и конфигурируем эту шкалу, valueScaleCoefficientInt - коэффициент мерности шкалы значений
        (arrayValues, valueScaleCoefficientInt) = getArrayValuesScale(incomes: nil, expenses: nil, expenseCategory: expenseCategory)
        valueScaleGraphScrollView.configurateScrollView(graphFieldHeigth: size.height, arrayValues: arrayValues)
        
        // - получаем массив дат для шкалы дат графика и конфигурируем эту шкалу
        let arrayDays = getArrayDaysScale(datesArray: transactionDatesExpense, amountDays: amountDays)
        dateScaleGraphScrollView.configurateScrollView(graphFieldWidth: size.width, arrayDays: arrayDays)

        // - получаем координаты точек на графике
        let pointsGraph = getPoints(incomes: nil, expenses: nil, expenseCategory: expenseCategory, startValueScaleField: valueScaleCoefficientInt)
        graphFieldView.configurateGraph(pointsIncomes: nil, pointsExpenses: pointsGraph)

    }

    //MARK: - UIScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        valueScaleGraphScrollView.contentOffset.y = graphFieldScrollView.contentOffset.y
        dateScaleGraphScrollView.contentOffset.x = graphFieldScrollView.contentOffset.x
    }
}
