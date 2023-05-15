//
//  ValueScaleScrollView.swift
//  GraduationProject
//
//  Created by Александр Муклинов on 16.04.2023.
//

import UIKit

class ValueScaleGraphScrollView: UIScrollView {

    var graphFieldWidth:CGFloat = 50
    var graphFieldHeigth:CGFloat = 0
    var graphCellHeightAndWidth:CGFloat = 50
    var arrayValues:[Int] = []
    let sizeValueScaleGraph:Int = 7 // - размерность графика по шкале значений равна 7-ми ячейкам (graphCell)
    var indexValueScaleInArray:Int = 0 // - должен быть меньше 7 (arrayValues 0...6)
    
    func configurateScrollView(graphFieldHeigth: CGFloat, arrayValues:[Int]) {
        self.graphFieldHeigth = graphFieldHeigth
        self.arrayValues = arrayValues.sorted(by: <)
        self.contentSize = CGSize(width: graphFieldWidth, height: graphFieldHeigth)
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        
        guard UIGraphicsGetCurrentContext() != nil else { return }
        
        // - удаляем старую информацию перед перерисовкой представления
        indexValueScaleInArray = 0
        for subview in self.subviews {
            if let label = subview as? UILabel {
                label.removeFromSuperview()
            }
        }
        
        // - ось X
        for positionY in stride(from: 0, to: graphFieldHeigth + 1, by: graphCellHeightAndWidth) {
            let label = UILabel(frame: CGRect(x: 0, y: positionY - 25, width: graphCellHeightAndWidth, height: graphCellHeightAndWidth))
            label.font = UIFont.boldSystemFont(ofSize: 13)
            label.textColor = .black
            arrayValues.sort(by: > )
            if !arrayValues.isEmpty && indexValueScaleInArray < sizeValueScaleGraph {
                label.text = "\(arrayValues[indexValueScaleInArray])"
                indexValueScaleInArray += 1
            }
            
            self.addSubview(label)
        }
    }
}
