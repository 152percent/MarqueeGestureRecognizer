import UIKit
import PlaygroundSupport

struct CGRectReversible {
    fileprivate static func rect(from: CGPoint, to: CGPoint) -> CGRect {
        var rect = CGRect.zero
        
        if from.x < to.x {
            rect.origin.x = from.x
            rect.size.width = to.x - from.x
        } else {
            rect.origin.x = to.x
            rect.size.width = from.x - to.x
        }
        
        if from.y < to.y {
            rect.origin.y = from.y
            rect.size.height = to.y - from.y
        } else {
            rect.origin.y = to.y
            rect.size.height = from.y - to.y
        }
        
        return rect
    }
}

import UIKit.UIGestureRecognizerSubclass

public final class MarqueeGestureRecognizer: UIPanGestureRecognizer {
    
    public private(set) var initialLocation: CGPoint = .zero
    public private(set) var selectionRect: CGRect = .zero
    public var tintColor: UIColor = .yellow
    public var zPosition: Int = 0
    
    public override init(target: Any?, action: Selector?) {
        super.init(target: target, action: action)
        addTarget(self, action: #selector(handleGesture(gesture:)))
    }
    
    private var marqueeView: UIView? {
        didSet {
            marqueeView?.backgroundColor = tintColor.withAlphaComponent(0.1)
            marqueeView?.layer.borderColor = tintColor.cgColor
            marqueeView?.layer.borderWidth = 1
            marqueeView?.layer.zPosition = CGFloat(zPosition)
        }
    }
    
    @objc private func handleGesture(gesture: MarqueeGestureRecognizer) {
        guard let view = gesture.view else { return }
        
        let currentLocation = gesture.location(in: view)
        selectionRect = CGRectReversible.rect(from: initialLocation, to: currentLocation)
        
        switch gesture.state {
        case .began:
            let marqueeView = UIView()
            view.insertSubview(marqueeView, at: zPosition)
            self.marqueeView = marqueeView
            initialLocation = currentLocation
        case .changed:
            marqueeView?.frame = selectionRect
        default:
            initialLocation = .zero
            selectionRect = .zero
            
            marqueeView?.removeFromSuperview()
            marqueeView = nil
        }
    }
    
}

let view = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 320))
view.backgroundColor = .white

let gesture = MarqueeGestureRecognizer(target: nil, action: nil)
gesture.tintColor = UIColor(red: 52/255, green: 119/255, blue: 154/255, alpha: 1.0)
view.addGestureRecognizer(gesture)

PlaygroundPage.current.liveView = view
PlaygroundPage.current.needsIndefiniteExecution = true
