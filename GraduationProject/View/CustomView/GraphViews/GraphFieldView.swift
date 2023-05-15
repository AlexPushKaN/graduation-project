//
//  GraphExpenseScrollView.swift
//  GraduationProject
//
//  Created by Александр Муклинов on 16.04.2023.
//

import UIKit

class GraphFieldView: UIView {

    let graphCellWidthAndHeight:CGFloat = 50
    var graphFieldWidth:CGFloat = 0
    let graphFieldHeigth:CGFloat = 350
    var pointsIncomes:Points?
    var pointsExpenses:Points?
    
    func configurateView(amountDays: CGFloat) {
        self.graphFieldWidth = graphCellWidthAndHeight * amountDays
        self.frame = CGRect(origin: .zero, size: CGSize(width: graphFieldWidth, height: graphFieldHeigth)) 
        setNeedsDisplay()
    }
    
    func configurateGraph(pointsIncomes: Points?, pointsExpenses: Points?) {
        self.pointsIncomes = pointsIncomes
        self.pointsExpenses = pointsExpenses
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {

        guard let context = UIGraphicsGetCurrentContext() else { return }

        //MARK: - Рисуем поле графика
        UIColor.systemGray2.withAlphaComponent(0.1).setStroke()

        let pathLineGraph = UIBezierPath()
        pathLineGraph.lineWidth = 1.0
        
        // - ось X
        for i in stride(from: 0, to: graphFieldHeigth + 1, by: graphCellWidthAndHeight) {
            pathLineGraph.move(to: CGPoint(x: 0, y: i))
            pathLineGraph.addLine(to: CGPoint(x: graphFieldWidth, y: CGFloat(i)))
        }

        // - ось Y
        for i in stride(from: 0, to: graphFieldWidth + 1, by: graphCellWidthAndHeight) {
            pathLineGraph.move(to: CGPoint(x: i, y: 0))
            pathLineGraph.addLine(to: CGPoint(x: CGFloat(i), y:graphFieldHeigth ))
        }
        
        pathLineGraph.stroke()

        //MARK: - Рисуем точки и линии графика
        
        // - для доходов
        if let points = pointsIncomes {

            // - проставляем точки
            for point in points.quantity {

                let pointRect = CGRect(x: point.x - 2.5, y: point.y - 2.5, width: 5, height: 5)
                context.setFillColor(UIColor.green.cgColor)
                context.fillEllipse(in: pointRect)
            }
            
            // - проводим линии
            let pathGraph = UIBezierPath()
            pathGraph.lineWidth = 2.5

            for (index, _ ) in points.quantity.enumerated() {
                if index == points.quantity.count - 1 { break }
                pathGraph.move(to: CGPoint(x: points.quantity[index].x, y: points.quantity[index].y))
                pathGraph.addLine(to: CGPoint(x:  points.quantity[index + 1].x, y: points.quantity[index + 1].y))
            }
            
            UIColor.green.setStroke()
            pathGraph.stroke()
        }
        
        // - для расходов
        if let points = pointsExpenses {

            // - проставляем точки
            for point in points.quantity {

                let pointRect = CGRect(x: point.x - 2.5, y: point.y - 2.5, width: 5, height: 5)
                context.setFillColor(UIColor.red.cgColor)
                context.fillEllipse(in: pointRect)
            }
            
            // - проводим линии
            let pathGraph = UIBezierPath()
            pathGraph.lineWidth = 2.5

            for (index, _ ) in points.quantity.enumerated() {
                if index == points.quantity.count - 1 { break }
                pathGraph.move(to: CGPoint(x: points.quantity[index].x, y: points.quantity[index].y))
                pathGraph.addLine(to: CGPoint(x:  points.quantity[index + 1].x, y: points.quantity[index + 1].y))
            }
            
            UIColor.red.setStroke()
            pathGraph.stroke()
        }
    }
}
