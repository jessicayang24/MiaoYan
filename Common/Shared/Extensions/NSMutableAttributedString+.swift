import Foundation

#if os(iOS)
import UIKit
#else
import Cocoa
#endif

extension NSMutableAttributedString {
    public func unLoadImages(note: Note? = nil) -> NSMutableAttributedString {
        var offset = 0
        let content = self.mutableCopy() as? NSMutableAttributedString

        self.enumerateAttribute(.attachment, in: NSRange(location: 0, length: self.length)) { (value, range, _) in

            if let textAttachment = value as? NSTextAttachment,
                self.attribute(.todo, at: range.location, effectiveRange: nil) == nil {
                var path: String?
                var title: String?

                let filePathKey = NSAttributedString.Key(rawValue: "com.tw93.miaoyan.image.path")
                let titleKey = NSAttributedString.Key(rawValue: "com.tw93.miaoyan.image.title")

                if let filePath = self.attribute(filePathKey, at: range.location, effectiveRange: nil) as? String {

                    path = filePath.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                    title = self.attribute(titleKey, at: range.location, effectiveRange: nil) as? String
                } else if let note = note,
                    let imageData = textAttachment.fileWrapper?.regularFileContents {
                    path = ImagesProcessor.writeFile(data: imageData, note: note)
                } else if let note = note,
                    let imageData = textAttachment.contents {
                    path = ImagesProcessor.writeFile(data: imageData, note: note)
                }

                let newRange = NSRange(location: range.location + offset, length: range.length)

                guard let unwrappedPath = path, unwrappedPath.count > 0 else { return }

                let unrappedTitle = title ?? ""

                content?.removeAttribute(.attachment, range: newRange)
                content?.replaceCharacters(in: newRange, with: "![\(unrappedTitle)](\(unwrappedPath))")
                offset += 4 + unwrappedPath.count + unrappedTitle.count
            }
        }

        return content!
    }

    public func unLoadCheckboxes() -> NSMutableAttributedString {
        var offset = 0
        let content = self.mutableCopy() as? NSMutableAttributedString

        self.enumerateAttribute(.attachment, in: NSRange(location: 0, length: self.length)) { (value, range, _) in
            if value != nil {
                let newRange = NSRange(location: range.location + offset, length: 1)

                guard range.length == 1,
                    let value = self.attribute(.todo, at: range.location, effectiveRange: nil) as? Int
                else { return }

                var gfm = "- [ ]"
                if value == 1 {
                    gfm = "- [x]"
                }
                content?.replaceCharacters(in: newRange, with: gfm)
                offset += 4
            }
        }

        return content!
    }

    public func unLoad() -> NSMutableAttributedString {
        return unLoadCheckboxes().unLoadImages()
    }

    #if os(OSX)
    public func unLoadUnderlines() -> NSMutableAttributedString {
        self.enumerateAttribute(.underlineStyle, in: NSRange(location: 0, length: self.length)) { (value, range, _) in
            if value != nil {
                self.addAttribute(.underlineColor, value: NSColor.black, range: range)
            }
        }

        return self
    }
    #endif

    public func loadUnderlines() {
        self.enumerateAttribute(.underlineStyle, in: NSRange(location: 0, length: self.length)) { (value, range, _) in
            if value != nil {
                self.addAttribute(.underlineColor, value: NotesTextProcessor.underlineColor, range: range)
            }
        }
    }
}
