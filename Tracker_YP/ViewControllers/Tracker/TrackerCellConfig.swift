import UIKit

struct CellConfig {
    let cellCount: Int
    let leftInset: CGFloat
    let rightInset: CGFloat
    let cellSpacing: CGFloat
    let height: CGFloat
    let paddingWidth: CGFloat
    
    init(cellCount: Int, leftInset: CGFloat, rightInset: CGFloat, cellSpacing: CGFloat, height: CGFloat, paddingWidth: CGFloat) {
        self.cellCount = cellCount
        self.leftInset = leftInset
        self.rightInset = rightInset
        self.cellSpacing = cellSpacing
        self.height = height
        self.paddingWidth =  leftInset + rightInset + CGFloat(cellCount - 1) * cellSpacing
    }
}

func dayWord(for number: Int) -> String {
    let lastDigit = number % 10
    let lastTwoDigits = number % 100
    
    if lastTwoDigits >= 11 && lastTwoDigits <= 19 {
        return "дней"
    }
    
    switch lastDigit {
    case 1:
        return "день"
    case 2, 3, 4:
        return "дня"
    default:
        return "дней"
    }
}
