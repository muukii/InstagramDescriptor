import Foundation
import AppKit
import CoreImage

guard let imagePath = CommandLine.arguments.dropFirst().first as NSString? else {
  fatalError("Missing path to image")
}

let imageURL = URL(fileURLWithPath: imagePath.standardizingPath)

let data = try Data(contentsOf: imageURL)

guard let image = CIImage(data: data) else {
  fatalError("The file is invalid")
}

final class Storage {
  
  var current: String = ""
  
  init() {
    
  }
  
  func append(_ string: String) {
    current += string
  }
  
  func insertSeparator() {
    current += "———————————————"
    insertNewline()
  }
  
  func insertNewline() {
    current += "\n"
  }
  
}

final class Descriptor {
  
  private let image: CIImage
  
  init(image: CIImage) {
    self.image = image
  }
  
  func render() -> String {
    
    let storage = Storage()
    
    storage.insertSeparator()
    
    if let tiff = image.properties["{TIFF}"] as? [String : Any] {
      tiff["Model"]
        .flatMap { $0 as? String }
        .map {
          storage.append($0)
          storage.insertNewline()
      }
      
      storage.insertSeparator()

    }
    
    if let exif = image.properties["{Exif}"] as? [String : Any] {
      
      exif["LensModel"]
        .flatMap { $0 as? String }
        .map {
          storage.append($0)
          storage.insertNewline()
      }
      
      exif["ISOSpeedRatings"]
        .flatMap { $0 as? Array<Int> }
        .flatMap { $0.first }
        .map {
          storage.append("ISO \($0)")
          storage.insertNewline()
      }
      
//      exif["FocalLength"]
//        .flatMap { $0 as? Double }
//        .map {
//          storage.append("\($0)mm")
//          storage.insertNewline()
//      }
      
      exif["FNumber"]
        .flatMap { $0 as? Double }
        .map {
          storage.append("ƒ/\($0)")
          storage.insertNewline()
      }
      
      exif["ExposureTime"]
        .flatMap { $0 as? Double }
        .map { 1 / $0 }
        .map {
          storage.append("1/\(String.init(format: "%.f", $0))")
          storage.insertNewline()
      }
      
      storage.insertSeparator()
      
    }
    
    return storage.current
  }
  
  func writeToPasteboard() {
    
    let result = d.render()
    
    let item = NSPasteboardItem.init()
    
    item.setString(
      result,
      forType: .string
    )
    
    NSPasteboard.general.declareTypes([.string], owner: self)
    let r = NSPasteboard.general.writeObjects([item])
    
    if r {
      print("📋 Sent to Pasteboard!")
    } else {
      fatalError("❌ Failed to write Pasteboard")
    }
    
  }
  
}

let d = Descriptor(image: image)

let result = d.render()

print("""
  
===Result===

\(result)

============
  
""")

d.writeToPasteboard()


