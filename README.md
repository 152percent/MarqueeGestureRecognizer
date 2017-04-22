# Advanced Gesture Recognisers

The playground demonstrates using a `UIPanGestureRecognizer` to create a marquee selection tool that you can use in any UIView.

## Gestures

`UIGestureRecogniser`'s are a really powerful way of working with touch events in iOS. They allow us to handle taps, pans, pinches and more. Through a simple state-driven API we can easily use them to detect lots of types of interactions in our apps.

<table><tr style="border: none">
<td style="border: none">
<img src="https://static1.squarespace.com/static/58d1c3c1b3db2b27db51464f/58eeb460d2b857e333ce58f2/58eeb460197aea0b0db0963a/1492038781962/noun_718412_cc.png" alt="Pan" />￼
<p style="text-align: center; color: gray">Pan</p>
</td>
<td style="border: none">
<img src="https://static1.squarespace.com/static/58d1c3c1b3db2b27db51464f/58eeb460d2b857e333ce58f2/58eeb4606a4963e429648fc7/1492038813073/noun_718416_cc.png" alt="Zoom" />￼
<p style="text-align: center; color: gray">Zoom</p>
</td>
<td style="border: none">
<img src="https://static1.squarespace.com/static/58d1c3c1b3db2b27db51464f/58eeb460d2b857e333ce58f2/58eeb4601e5b6c955746b48f/1492038792859/noun_718447_cc.png" alt="Tap" /> 
<p style="text-align: center; color: gray">Tap</p>
</td>
<td style="border: none">
<img src="https://static1.squarespace.com/static/58d1c3c1b3db2b27db51464f/58eeb460d2b857e333ce58f2/58eeb460bf629a9dbf4529f4/1492038802032/noun_718449_cc.png" alt="Pinch" />
<p style="text-align: center; color: gray">Pinch</p>
</td>
</tr></table>
￼
## Marquee Selection

<p><img src="https://static1.squarespace.com/static/58d1c3c1b3db2b27db51464f/t/58eeb70486e6c0436ed702e9/1492039434861/" style="width: 25%" /></p>

Recently I came across a feature I needed to build. Basically I needed to provide a marquee selection tool like you might see in Finder for selecting files and folders.

`UIPanGestueRecognizer` seemed like a perfect fit for the job since it provides location data while the you move your finger across the view. So I added one to my view and proceeded to write some code for handling the marquee itself.  

## Typical Solution

So I started off by checking the recognizer state and recording the initial location when state == .began
I then used location(in view:) while the gesture's state == .changed -- finally creating a rectangle between the two points.

<p><img src="https://static1.squarespace.com/static/58d1c3c1b3db2b27db51464f/t/58eeb78db8a79b050d410025/1492039569669/selection.png" alt="selection.png" style="width: 25%" /></p>

At this point I had a working marquee tool but I was drawing the rectangle using draw(rect:) of the gesture.view, which wasn't ideal, especially because it meant I couldn't draw on 'top' of the subviews.

So I decided to add a view instead based on the gesture's state.

`.began` – add the marqueeView to the source view  
`.changed` – set the frame of the selection view  
`.ended` – remove the selection view from the source view

At this point however I realised that this solution wasn't ideal since I was now tied to this specific implementation of UIView. Furthermore, if I wanted to provide selection to something like a UICollectionView then I would have to copy/paste a lof of code.

## Alternative Solution

The solution I came up with was to move the marqueeView into the gesture itself. In hindsight this seemed obvious. The gesture has everything I need to provide a selection rectangle. Its state-driven, provides the location of the touch events during a pan, and even provides me with the source view.

All I had to do was listen for the various state changes and insert/remove my marqueeView appropriately. Lets checkout an example.

```swift
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
```

For the full code, you can download the Playground from this repo.

## Summary

Subclassing a UIGestureRecognizer and adding behaviour to it has a lot of advantages.

1.	You can easily composite this into any view
2.	You can add advanced behaviour to your gesture; e.g.
    - Hold down a second finger to constrain aspect ratio
3.	The marqueeView's lifecycle is bound to the state of the gesture; i.e.
    - no need to manage it from your view controller, etc...
4.	Gesture's are state-driven by default, which makes them great to work with.
