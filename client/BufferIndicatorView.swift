import Foundation
import DottedProgressBar

class BufferIndicatorView: UIView {
    private let DOT_RADIUS = CGFloat(integerLiteral: 8)
    
    private let serialQueue = DispatchQueue(label: "progressQueue")
    
    private var pbNorm: DottedProgressBar?
    private var pbFlip: DottedProgressBar?
    
    private var progress = 3
    private var progressMax = 3
    private var direction = -1
    
    private var timer: Timer?

    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return false
    }
    
    func show() {
        hide()
        pbNorm = createProgressIndicator()
        pbFlip = createProgressIndicator()
        pbFlip?.transform = CGAffineTransform(scaleX: -1, y: 1)
        
        // Cool, make them overlap
        pbFlip?.frame.origin = CGPoint(x: 0, y: 0)
        
        timer = Timer.scheduledTimer(timeInterval: 0.27, target: self, selector: #selector(progressLoop), userInfo: nil, repeats: true)
    }
    
    func hide() {
        timer?.invalidate()
    
        let dur = 0.3
        
        let norm = pbNorm
        let flip = pbFlip
        UIView.animate(withDuration: dur,
                       animations: { norm?.alpha = 0.0; flip?.alpha = 0.0 },
                       completion: { _ in norm?.removeFromSuperview(); flip?.removeFromSuperview() })
        
        serialQueue.sync {
            pbNorm = nil
            pbFlip = nil
            progress = progressMax
            direction = -1
        }
    }
    
    private func createProgressIndicator() -> DottedProgressBar {
        let subFrame = CGRect(x: frame.width/2 - DOT_RADIUS, y: 0, width: frame.width * 0.6, height: frame.height)
        
        let appearance = DottedProgressBar.DottedProgressAppearance(
            dotRadius: DOT_RADIUS,
            dotsColor: UIColor.clear,
            dotsProgressColor: UIColor.white,
            backColor: UIColor.clear
        )
        
        let progressBar = DottedProgressBar(appearance: appearance)
        progressBar.frame = subFrame
        progressBar.setNumberOfDots(progressMax, animated: false)
        progressBar.setProgress(progress, animated: false)
        progressBar.progressChangeAnimationDuration = 0.25
        progressBar.pauseBetweenConsecutiveAnimations = 0.0
        
        addSubview(progressBar)
        
        progressBar.alpha = 0.0
        UIView.animate(withDuration: 0.4, animations: { progressBar.alpha = 1.0 })
        
        return progressBar
    }
    
    @objc private func progressLoop() {
        serialQueue.sync {
            progress += direction
            if (progress == 1 || progress == progressMax) {
                direction = -direction
            }
            
            pbNorm?.setProgress(progress, animated: true)
            pbFlip?.setProgress(progress, animated: true)
        }
    }
}
