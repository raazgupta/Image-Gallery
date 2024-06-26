import UIKit

class SlotMachineView: UIView {
    private var reels: [UIImageView] = []
    private var masks: [UIView] = []
    private var timer: Timer?
    
    private let reelCount = 3
    private let symbolCount = 3
    private let symbolHeight: CGFloat = 100
    private let reelRows = 9
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        backgroundColor = .black
        
        let reelWidth = frame.width / CGFloat(reelCount) // Divide total width by reel count
        
        var numStars = 3
        for i in 0..<reelRows {
            let reel = UIImageView(frame: CGRect(x: CGFloat(i) * reelWidth, y: CGFloat(i) * symbolHeight, width: reelWidth, height: symbolHeight))
            reel.contentMode = .top
            reel.image = createReelImage(numStars: numStars % 3 + 1)
            addSubview(reel)
            reels.append(reel)
            numStars = numStars + 1
        }
        for i in 0..<reelCount {
            let mask = UIView(frame: CGRect(x: CGFloat(i) * reelWidth, y: (frame.height - symbolHeight) / 2, width: reelWidth, height: symbolHeight))
            mask.backgroundColor = .clear
            mask.layer.borderColor = UIColor.gold.cgColor
            mask.layer.borderWidth = 3
            addSubview(mask)
            masks.append(mask)
        }
    }
    
    private func createReelImage(numStars: Int) -> UIImage {
        let star = "⭐️"
        let totalHeight = symbolHeight
        let reelWidth = frame.width
        let reelCellWidth = frame.width / CGFloat(reelCount)
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: reelWidth, height: totalHeight), false, 0)
        let context = UIGraphicsGetCurrentContext()!
        
        // Fill background with black
        context.setFillColor(UIColor.black.cgColor)
        context.fill(CGRect(x: 0, y: 0, width: reelWidth, height: totalHeight))
        
        for i in 0..<numStars {

            let fontSize = symbolHeight * 0.6 // Adjust this value to change emoji size
            
            // Create attributed string with the emoji
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: fontSize),
                .foregroundColor: UIColor.white
            ]
            let attributedStar = NSAttributedString(string: star, attributes: attributes)
            
            // Calculate star size and position
            let starSize = attributedStar.size()
            let x = ((reelCellWidth - starSize.width) / 2.0) * CGFloat(i)
            let y = (symbolHeight - starSize.height) / 2
            
            // Draw star
            attributedStar.draw(at: CGPoint(x: x, y: y))
        }
        
        let reelImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return reelImage ?? UIImage()
    }
    
    func startAnimation(finalStars: Int, completion: @escaping () -> Void) {
        let totalDuration: TimeInterval = 3.0
        let speedUpDuration: TimeInterval = 1.0
        let slowDownDuration: TimeInterval = 1.0
        let middleDuration: TimeInterval = totalDuration - speedUpDuration - slowDownDuration
        
        var speeds: [CGFloat] = [20, 25, 30]
        let finalPositions: [CGFloat] = [CGFloat(finalStars - 1) * symbolHeight,
                                         CGFloat(finalStars - 1) * symbolHeight,
                                         CGFloat(finalStars - 1) * symbolHeight]
        
        let startTime = Date()
        
        timer = Timer.scheduledTimer(withTimeInterval: 1/60, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            
            let elapsedTime = Date().timeIntervalSince(startTime)
            
            if elapsedTime >= totalDuration {
                timer.invalidate()
                for (index, reel) in self.reels.enumerated() {
                    reel.frame.origin.y = -finalPositions[index % 3]
                }
                completion()
                return
            }
            
            for (index, reel) in self.reels.enumerated() {
                if elapsedTime < speedUpDuration {
                    speeds[index % 3] = min(speeds[index % 3] * 1.1, 100)
                } else if elapsedTime < speedUpDuration + middleDuration {
                    // maintain speed
                } else {
                    speeds[index % 3] = max(speeds[index % 3] * 0.95, 5)
                    
                    let targetPosition = finalPositions[index % 3]
                    let currentPosition = reel.frame.origin.y.truncatingRemainder(dividingBy: self.symbolHeight * CGFloat(self.symbolCount))
                    
                    if abs(currentPosition - targetPosition) < speeds[index % 3] / 60 {
                        reel.frame.origin.y = -targetPosition
                        continue
                    }
                }
                
                reel.frame.origin.y -= speeds[index % 3] / 60
                if reel.frame.origin.y <= -self.symbolHeight * CGFloat(self.symbolCount) {
                    reel.frame.origin.y += self.symbolHeight * CGFloat(self.symbolCount)
                }
            }
        }
    }
}

extension UIColor {
    static let gold = UIColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 1.0)
}
