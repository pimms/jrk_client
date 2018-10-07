import Foundation
import UIKit

class SplitSplashView: UIView {    
    private var leftImage: UIImageView?
    private var rightImage: UIImageView?
    
    required init?(coder aDecoder: NSCoder) {
        assert(false, "Don't use this constructor")
        return nil
    }
    
    init() {
        super.init(frame: UIScreen.main.bounds)
        initImageViews()
    }
    
    private func initImageViews() {
        self.leftImage = createImageView(withImageFile: "roi-splash-split-l")
        self.rightImage = createImageView(withImageFile: "roi-splash-split-r")
    }
    
    private func createImageView(withImageFile file: String) -> UIImageView? {
        guard let path = Bundle.main.path(forResource: file, ofType: "png") else {
            return nil
        }
        
        let image = UIImage(contentsOfFile: path)
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFill
    
        let frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        imageView.frame = frame
        
        addSubview(imageView)
        return imageView
    }

    
    public func startAnimation(completionHandler: (()->Void)?) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            UIView.animate(withDuration: 1.0, animations: {
                let dist = max(UIScreen.main.bounds.height, UIScreen.main.bounds.width)
                self.leftImage?.frame.origin = CGPoint(x: 0, y: dist)
                self.rightImage?.frame.origin = CGPoint(x: 0, y: -dist)
            }, completion: { _ in
                self.removeFromSuperview()
                if let handler = completionHandler {
                    handler()
                }
            })
        })
    }

}
