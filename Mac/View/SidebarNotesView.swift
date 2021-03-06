import Cocoa

class SidebarNotesView: NSView {
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        if UserDefaultsManagement.appearanceType != AppearanceType.Custom, #available(OSX 10.13, *) {
            NSColor(named: "mainBackground")!.setFill()
            __NSRectFill(dirtyRect)
        } else {
            layer?.backgroundColor = NSColor.white.cgColor
        }
    }
    override func awakeFromNib() {
        var f = self.frame;
        f.size.width = 280;
        self.frame = f;
        self.setFrameSize(f.size)
        self.setBoundsSize(f.size)
    }
}
