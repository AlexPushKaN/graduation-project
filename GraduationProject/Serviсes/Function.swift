//
//  Helpers.swift
//  GraduationProject
//
//  Created by Александр Муклинов on 07.04.2023.
//

import Foundation

//MARK: - функции для получения и обновления бегущей строки на IncomeViewController
func getCurrencyRuningLine(currencies: Currencies) -> String {
    var currencyRuningLine:String = ""
    let list:[String:String] = [
        "btc": "Bitcoin",
        "cake": "PancakeSwap",
        "dash": "Dash",
        "doge": "Dogecoin",
        "dot": "Dotcoin",
        "eos": "EOS",
        "eur": "Euro",
        "gel": "Georgian lari",
        "hkd": "Hong Kong dollar",
        "jpy": "Japanese yen",
        "ksm": "Kusama",
        "matic": "Polygon",
        "near": "NEAR Protocol",
        "neo": "NEO",
        "rub": "Russian ruble",
        "trx": "TRON",
        "try": "Turkish lira",
        "usdt": "Tether",
        "waves": "Waves",
        "xlm": "Stellar",
        "xrp": "XRP",
    ]
    
    for currency in currencies.usd {
        if list.keys.contains(currency.key) {
            let index = list.firstIndex { (key: String, value: String) in
                return currency.key == key
            }
            let currencyName = list[index!].value + ": "
            let currencyValue = String(currency.value) + "   "
            currencyRuningLine = currencyRuningLine + currencyName + currencyValue
        }
    }
    return currencyRuningLine
}

func updateCurrencyRuning(line:String) -> String {
    var line = Array(line)
    if line.count > 0 {
        let firstSimbol = line.removeFirst()
        line.append(firstSimbol)
    }
    return String(line)
}
//MARK: - перечисление и функции для получения временных и шкал значений графика
enum TimeInterval:String {
    case week = "Неделя"
    case month = "Месяц"
    case quarter = "Квартал"
    case all = "Все"
}

// - функция получения количества дней в зависимости от выбора пользователя
func getAmountDays(timeInterval:TimeInterval, datesArray: [Date]) -> Int {
    
    var amount:Int = 0
    let week:Int = 7
    
    switch timeInterval {
        case .week: amount = week + 1
        case .month: amount = 30
        case .quarter: amount = 90
        case .all:
        
        if datesArray.count < week {
            amount = week + 1
        } else if datesArray.count >= week {
            amount = datesArray.count + 1
        }
    }
    return amount
}

// - функция генерации шкалы дат графика
func getArrayDaysScale(datesArray: [Date], amountDays: Int) -> [String] {
    
    var arrayDays = [String]()
    var firstDay:Date = DateOperation.date
    
    if let date = datesArray.sorted(by: <).first {
        firstDay = date
    }

    let calendar = Calendar.current
    for day in 0..<amountDays {
        if let newDate = calendar.date(byAdding: .day, value: day, to: firstDay) {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd.MM"
            let dateString = dateFormatter.string(from: newDate)
            arrayDays.append(dateString)
        }
    }
    
    return arrayDays
}

// - функция генерации шкалы значений графика в зависимости от valueScaleCoefficientInt
func getArrayValuesScale(incomes:Incomes?, expenses: Expenses?, expenseCategory: ExpenseCategory?) -> ([Int], Int) {
    
    var arrayValues:[Int] = []
    let sizeValueScaleGraph:Int = 7 //размерность графика по шкале значений равна 7-ми ячейкам (graphCell)

    // - извлекаем значения доходов в общий массив
    if incomes != nil {
        for income in incomes!.quantity!.array as! [Income] {
            arrayValues.append(Int(income.income))
        }
    }
    
    // - извлекаем значения расходов в общий массив если они есть
    if expenses != nil {
        for expenseCategory in expenses!.quantity!.array as! [ExpenseCategory] {
            for expense in expenseCategory.quantity!.array as! [Expense] {
                arrayValues.append(Int(expense.expense))
            }
        }
    }

    // - извлекаем значения расходов в общий массив если они есть
    if expenseCategory != nil {
        for expense in expenseCategory!.quantity!.array as! [Expense] {
            arrayValues.append(Int(expense.expense))
        }
    }
    
    // - сортируем массив по убыванию, чтоб извлечь первое самое большое значение
    arrayValues.sort(by: >)
    
    var value:Int = 2000 // - если массив arrayValues.count = 0, то берем value по умолчанию
    
    if let valueMax = arrayValues.first { // - если массив arrayValues.count > 0, то берем самое большое значение
        value = valueMax
    }
    
    arrayValues.removeAll() // - очищаем массив для новых данных
    
    let valueScaleCoefficientArray:[Double] = [2,5,10] // - массив значений для вычисления размерности шкалы значений
    var valueScaleCoefficientInt:Int = 0
    
    // - вычисляем размерность шкалы значений графика
    for coefficient in valueScaleCoefficientArray {
        var allValueScale:Double = 0
        for degree in 1...10 {
            let valueScaleConst = coefficient * pow(Double(10), Double(degree))
            for _ in 1...sizeValueScaleGraph {
                allValueScale += valueScaleConst
                if value - Int(allValueScale) < 0 {
                    valueScaleCoefficientInt = Int(valueScaleConst)
                    break
                }
            }
            
            if valueScaleCoefficientInt != 0 {
                break
            }
            
        }
        
        if valueScaleCoefficientInt != 0 {
            break
        }
    }
    
    // - конфигурируем шкалу значений графика
    var valueScale:Int = 0
    for _ in 0...sizeValueScaleGraph {
        arrayValues.append(valueScale)
        valueScale += valueScaleCoefficientInt
    }

    return (arrayValues, valueScaleCoefficientInt)
}

//MARK: - функция для получения координат графика

func getPoints(incomes:Incomes?, expenses: Expenses?, expenseCategory: ExpenseCategory?, startValueScaleField: Int) -> Points {
    
    let points = Points()
    var widthGraphField = 0 // - длина поля графика
    let widthCell = 50 // - длина ячейки
    let calendar = Calendar.current
    
    /* - если запись значения в хранилище произошло в один день переходить на клетку вперед по оси х не нужно.
    Для учета дат записей заводим журнал регистрации */
    var registerOfAddDates:[Date] = []
    
    // - ИЗВЛЕКАЕМ ИНФОРМАЦИЮ ИХ ХРАНИЛИЩА и сортируем полученный массив данных в порядке возрастания по полю дата
    
    // - для доходов
    if incomes != nil {
        var objects:[Income] = []
        for income in incomes!.quantity!.array as! [Income] {
            objects.append(income)
        }
        objects.sort { $0.date < $1.date }
        for object in objects {
            let point = getPoint(value:Int(object.income), date:object.date)
            points.quantity.append(point)
        }
        
    }
    // - для расходов
    if expenses != nil {
        var objects:[Expense] = []
        for expenseCategory in expenses!.quantity!.array as! [ExpenseCategory] {
            for expense in expenseCategory.quantity!.array as! [Expense] {
                    objects.append(expense)
            }
        }
        objects.sort { $0.date! < $1.date! }
        for object in objects {
            let point = getPoint(value:Int(object.expense), date:object.date!)
            points.quantity.append(point)
        }
        
    }
    // - для категорий расходов
    if expenseCategory != nil {
        var objects:[Expense] = []
        for expense in expenseCategory!.quantity?.array as! [Expense] {
            objects.append(expense)
        }
        objects.sort { $0.date! < $1.date! }
        for object in objects {
            let point = getPoint(value:Int(object.expense), date:object.date!)
            points.quantity.append(point)
        }
    }
    
    // - функция для получения координаты точки на графике в зависимости от значения и даты
    func getPoint(value:Int, date:Date) -> Point {
        
        // - вычисляем длину поля графика, в границах котрого будет отрисованы линии и точки графика
        if !registerOfAddDates.isEmpty && calendar.component(.day, from: registerOfAddDates.last!) != calendar.component(.day, from: date) {
            let startDate = calendar.startOfDay(for: registerOfAddDates.last!)
            let endDate = date
            let components = calendar.dateComponents([.day], from: startDate, to: endDate)
            let differenceInDays = components.day!
            widthGraphField += widthCell * differenceInDays
        }
        
        registerOfAddDates.append(date)
        
        // - шкала дат это ось X
        let pointX = toXcoordinate(date: date, startDateScaleField: widthGraphField)
        // - шкала значений это ось Y
        let pointY = toYCoordinate(value: value, startValueScaleField: startValueScaleField)
        // - после необходимых преобразований создаем Point и добавляем ее в массив Points
        let point = Point(x: pointX, y: pointY)
        
        return point
    }

    return points
}

// - функция для вычисления координаты по оси X
func toXcoordinate(date:Date, startDateScaleField: Int) -> CGFloat {
    
    var xCoordinate:CGFloat = 0
    let calendar = Calendar.current
    let hour = calendar.component(.hour, from: date)

    xCoordinate = CGFloat(startDateScaleField) + CGFloat(50) * CGFloat(hour - 4) / CGFloat(24)
    return xCoordinate
}

// - функция для вычисления координаты по оси Y
func toYCoordinate(value:Int, startValueScaleField: Int) -> CGFloat {
    var yCoordinate:CGFloat = 0
    var scaleValue:Int = 0
    let sizeValueScaleGraph:Int = 7 // - размерность графика по шкале значений равна 7-ми ячейкам (graphCell)
    //let scaleValueCellHeight:Int = 50 // - высота ячейки равна 50 поинтам по оси у
    let sizeValueScaleField:Int = 350 // - sizeValueScaleField = sizeValueScaleGraph * scaleValueCellHeight максимум 350 поинтов по оси у, scaleValueCellHeight в 50 поинтов по оси у будет соответствовать startValueScaleField в стоимостной величине
    
    for _ in 0...sizeValueScaleGraph {
        
        scaleValue += startValueScaleField
        
        if value - scaleValue < 0 {
            yCoordinate = CGFloat(sizeValueScaleField) - CGFloat(sizeValueScaleField) * (CGFloat(value) / CGFloat(sizeValueScaleGraph * startValueScaleField))
            break
        }
    }
    return yCoordinate
}



