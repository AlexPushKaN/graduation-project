//
//  GraphExpenseAndIncomeViewController.swift
//  GraduationProject
//
//  Created by Александр Муклинов on 23.04.2023.
//

import UIKit

final class GraphExpenseAndIncomeViewController: UIViewController, UIScrollViewDelegate {

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent
    }
    
    @IBOutlet weak var timeIntervalStackView: UIStackView!
    @IBOutlet weak var graphFieldScrollView: UIScrollView!
    @IBOutlet weak var valueScaleGraphScrollView: ValueScaleGraphScrollView!
    @IBOutlet weak var dateScaleGraphScrollView: DateScaleGraphScrollView!

    private lazy var coreDataManager = {
        return CoreDataManager.self
    }()
    
    private var incomes:Incomes?
    private var expenses:Expenses?
    private var arrayValues:[Int] = []
    private var valueScaleCoefficientInt:Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        getInfoFromData()
        graphFieldScrollView.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        getInfoFromData()
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
        var allTransactionDates:Set<Date> = Set()
        var transactionDatesIncomes:[Date] = []
        var transactionDatesExpense:[Date] = []
        
        guard let incomes = self.incomes else { return }
        for income in incomes.quantity!.array as! [Income] {
            transactionDatesIncomes.append(income.date)
        }

        guard let expenses = self.expenses else { return }
        for expenseCategory in expenses.quantity!.array as! [ExpenseCategory] {
            for expense in expenseCategory.quantity!.array as! [Expense] {
                transactionDatesExpense.append(expense.date!)
            }
        }

        allTransactionDates = Set(transactionDatesIncomes).union(Set(transactionDatesExpense))

        // - получаем количество дней для вычисления размеров поля графика
        let amountDays = getAmountDays(timeInterval: timeInterval, datesArray: Array(allTransactionDates))
        
        // - формируем поле графика
        let graphFieldView = GraphFieldView()
        graphFieldView.backgroundColor = .white
        graphFieldView.configurateView(amountDays: CGFloat(amountDays))

        // - задаем размер graphFieldScrollView, и добавляем на graphFieldScrollView поле графика
        graphFieldScrollView.contentSize = CGSize(width: graphFieldView.frame.width, height: graphFieldView.frame.height)
        graphFieldScrollView.addSubview(graphFieldView)

        // - создаем переменную для хранения размера графика
        let size = graphFieldScrollView.contentSize

        // - получаем массив значений для шкалы значений графика и конфигурируем эту шкалу, valueScaleCoefficientInt - коэффициент мерности шкалы значений
        (arrayValues, valueScaleCoefficientInt) = getArrayValuesScale(incomes: incomes, expenses: expenses, expenseCategory: nil)
        valueScaleGraphScrollView.configurateScrollView(graphFieldHeigth: size.height, arrayValues: arrayValues)
        
        // - получаем массив дат для шкалы дат графика и конфигурируем эту шкалу
        let arrayDays = getArrayDaysScale(datesArray: Array(allTransactionDates), amountDays: amountDays)
        dateScaleGraphScrollView.configurateScrollView(graphFieldWidth: size.width, arrayDays: arrayDays)

        // - получаем координаты точек на графике
        let pointsGraphIncomes = getPoints(incomes: incomes, expenses: nil, expenseCategory: nil, startValueScaleField: valueScaleCoefficientInt)
        let pointsGraphExpenses = getPoints(incomes: nil, expenses: expenses, expenseCategory: nil, startValueScaleField: valueScaleCoefficientInt)
        graphFieldView.configurateGraph(pointsIncomes: pointsGraphIncomes, pointsExpenses: pointsGraphExpenses)
    }

    //MARK: - UIScrollViewDelegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        valueScaleGraphScrollView.contentOffset.y = graphFieldScrollView.contentOffset.y
        dateScaleGraphScrollView.contentOffset.x = graphFieldScrollView.contentOffset.x
    }
    
    //MARK: - Взаимодействие с СoreDataManager, создание Expenses и Incomes и/или получение этих данных из Core Data
    
    private func getInfoFromData() {
        if let object = coreDataManager.getObjectFromData(object: .incomes) as? Incomes {
            self.incomes = object
        } else {
            let object = coreDataManager.create(object: .incomes) as? Incomes
            self.incomes = object
        }
        
        if let object = coreDataManager.getObjectFromData(object: .expenses) as? Expenses {
            self.expenses = object
        } else {
            let object = coreDataManager.create(object: .expenses) as? Expenses
            self.expenses = object
        }
    }
}
