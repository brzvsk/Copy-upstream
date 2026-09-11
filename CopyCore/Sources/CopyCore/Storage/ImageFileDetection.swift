import Foundation
import UniformTypeIdentifiers

/// Clipboard file items store their filenames as newline-separated `plainText`. Keep the
/// platform content-type check in one place so the Image facet can include image files
/// without broadening to every `.file` item or maintaining an extension allow-list.
/// Deliberately uncached. `UTType(filenameExtension:)` measures 2.2 us per call, so even
/// ten thousand file rows cost about 22 ms for a facet the screener asked for. A memo
/// table would have to be locked, because a `DatabasePool` calls this from several reader
/// connections at once, and that contention costs more than the lookup it saves.
enum ImageFileDetection {
    static let sqlFunctionName = "copy_contains_image_file"

    static func containsImageFile(in filenames: String) -> Bool {
        filenames.split(separator: "\n", omittingEmptySubsequences: true).contains { filename in
            let ext = (String(filename) as NSString).pathExtension.lowercased()
            guard !ext.isEmpty, let type = UTType(filenameExtension: ext) else { return false }
            return type.conforms(to: .image)
        }
    }
}
