import Cocoa
import AVKit

/* TODO: The `userCanResize` property isn't respected. */

public class ViewController: NSViewController, PIPViewControllerDelegate {

	// Our actual player view.
	@IBOutlet private var player: AVPlayerView!
	
	// Keep track of the window we were previously in, since the view will be
	// relocated to a new window upon display in PIP.
	private var oldWindow: NSWindow? = nil
	
	// Keep track of our PIP state to ensure we're not crashing.
	private var inPip = false
	
	// Our PIP view can be presented by the PIPViewController.
	private lazy var pip: PIPViewController = {
		let pip = PIPViewController()
		pip.delegate = self
		pip.name = "PIP Demo"
		
		// Ensure the user can resize the PIP while keeping it in 16:9.
		pip.userCanResize = true
		pip.aspectRatio = NSSize(width: 16, height: 9)
		return pip
	}()
	
	// When we deinit, don't hold a cyclic reference to ourselves.
	deinit {
		self.pip.delegate = nil
	}
	
	// Present our view as PIP if we're not already doing so.
	public func openPIP() {
		if !self.inPip {
			self.oldWindow = self.view.window
			self.pip.presentAsPicture(inPicture: self)
			self.pip.playing = true
			
			print("Opening PIP!")
			self.inPip = true
		}
	}
	
	// Dismiss our view from PIP if we are in PIP already.
	public func closePIP() {
		if self.inPip {
			
			// If we set the `replacement*` properties, the PIP window should
			// attempt to animate back to the view where it came from.
			self.pip.replacementRect = self.view.frame
			self.pip.replacementWindow = self.oldWindow
			self.pip.dismissViewController(self)
			
			print("Closing PIP!")
			self.inPip = false
			self.oldWindow = nil
		}
	}
	
	// When the view appears, open the PIP and schedule to close it too.
	public override func viewDidAppear() {
		self.openPIP()
		DispatchQueue.main.after(when: .now() + .seconds(5)) {
			self.closePIP()
		}
	}
	
	// This method is called if the PIP needs to determine whether to close.
	public func pipShouldClose(_ pip: PIPViewController) -> Bool {
		print("Can the PIP close?")
		return true
	}
	
	// This method is called when the close button (next to the play/pause) is pressed.
	public func pipDidClose(_ pip: PIPViewController) {
		print("PIP wants to close!")
	}
	
	// This method is called when the play/pause button is pressed.
	public func pipActionPlay(_ pip: PIPViewController) {
		print("Play pressed!")
	}
	
	// This method is called when the play/pause button is pressed.
	public func pipActionPause(_ pip: PIPViewController) {
		print("Pause pressed!")
	}
	
	// This method is called when the top left close (x) button is pressed.
	public func pipActionStop(_ pip: PIPViewController) {
		print("Stop pressed!")
	}
}

@NSApplicationMain // Shh, it ok bby.
class AppDelegate: NSObject, NSApplicationDelegate {}
