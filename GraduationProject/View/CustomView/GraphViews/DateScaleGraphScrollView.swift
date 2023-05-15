//
//  DateScaleScrollView.swift
//  GraduationProject
//
//  Created by Александр Муклинов on 16.04.2023.
//

import UIKit

class DateScaleGraphScrollView: UIScrollView {
    
    var graphFieldWidth:CGFloat = 0
    var graphFieldHeigth:CGFloat = 50
    var graphCellHeightAndWidth:CGFloat = 50
    var arrayDays:[String] = []
    var dayScale:Int = 0
    
    func configurateScrollView(graphFieldWidth: CGFloat, arrayDays:[String]) {
        self.graphFieldWidth = graphFieldWidth
        self.arrayDays = arrayDays
        self.contentSize = CGSize(width: graphFieldWidth, height: graphFieldHeigth)
        setNeedsDisplay()
    }

    override func draw(_ rect: CGRect) {

        guard UIGraphicsGetCurrentContext() != nil else { return }
        
        // - удаляем старую информацию перед перерисовкой представления
        dayScale = 0
        for subview in self.subviews {
            if let label = subview as? UILabel {
                label.removeFromSuperview()
            }
        }

        // - ось Y
        for positionX in stride(from: 25, to: graphFieldWidth + 1, by: graphCellHeightAndWidth) {
            let label = UILabel(frame: CGRect(x: positionX, y: 0, width: graphCellHeightAndWidth, height: graphCellHeightAndWidth))
            label.font = UIFont.boldSystemFont(ofSize: 15)
            label.textColor = .black
            label.text = "\(arrayDays[dayScale])"
            dayScale += 1
            self.addSubview(label)
        }
    }
}
