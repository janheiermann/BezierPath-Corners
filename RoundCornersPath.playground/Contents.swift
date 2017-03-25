//: Playground - noun: a place where people can play

import PlaygroundSupport

#if os(iOS) || os(tvOS)
import UIKit
    
public typealias BezierPath = UIBezierPath
public typealias View = UIView
public typealias Color = UIColor

#elseif os(macOS)
import Cocoa
    
public typealias BezierPath = NSBezierPath
public typealias View = NSView
public typealias Color = NSColor
#endif

var str = "Hello, playground"

public struct Corners: OptionSet {
    public let rawValue: Int
    
    public init(rawValue: Corners.RawValue) {
        self.rawValue = rawValue
    }
    
    public static let topLeft = Corners(rawValue: 1 << 0)
    public static let bottomLeft = Corners(rawValue: 1 << 1)
    public static let topRight = Corners(rawValue: 1 << 2)
    public static let bottomRight = Corners(rawValue: 1 << 3)
    
    public func flipped() -> Corners {
        var flippedCorners: Corners = []
        
        if contains(.bottomRight) {
            flippedCorners.insert(.topRight)
        }
        
        if contains(.topRight) {
            flippedCorners.insert(.bottomRight)
        }
        
        if contains(.bottomLeft) {
            flippedCorners.insert(.topLeft)
        }
        
        if contains(.topLeft) {
            flippedCorners.insert(.bottomLeft)
        }
        
        return flippedCorners
    }
}

public extension BezierPath {
    
    // Compatibility bewteen NSBezierPath and UIBezierPath
    
    #if os(iOS) || os(tvOS)
    public func curve(to point: CGPoint, controlPoint1: CGPoint, controlPoint2: CGPoint) {
        addCurve(to: point, controlPoint1: controlPoint1, controlPoint2: controlPoint2)
    }
    
    public func line(to point: CGPoint) {
        addLine(to: point)
    }
    #endif
    
    public convenience init(rect: CGRect, roundedCorners: Corners, cornerRadius: CGFloat) {
        self.init()
        
        // On iOS & tvOS, we need to flip the corners
        #if os(iOS) || os(tvOS)
        let corners = roundedCorners.flipped()
        #elseif os(macOS)
        let corners = roundedCorners
        #endif
        
        let maxX: CGFloat = rect.size.width
        let minX: CGFloat = 0
        let maxY: CGFloat = rect.size.height
        let minY: CGFloat =  0
        
        let bottomRightCorner = CGPoint(x: maxX, y: minY)
        
        move(to: bottomRightCorner)
        
        if corners.contains(.bottomRight) {
            line(to: CGPoint(x: maxX - cornerRadius, y: minY))
            curve(to: CGPoint(x: maxX, y: minY + cornerRadius), controlPoint1: bottomRightCorner, controlPoint2: bottomRightCorner)
        }
        else {
            line(to: bottomRightCorner)
        }
        
        let topRightCorner = CGPoint(x: maxX, y: maxY)
        
        if corners.contains(.topRight) {
            line(to: CGPoint(x: maxX, y: maxY - cornerRadius))
            curve(to: CGPoint(x: maxX - cornerRadius, y: maxY), controlPoint1: topRightCorner, controlPoint2: topRightCorner)
        }
        else {
            line(to: topRightCorner)
        }
        
        let topLeftCorner = CGPoint(x: minX, y: maxY)
        
        if corners.contains(.topLeft) {
            line(to: CGPoint(x: minX + cornerRadius, y: maxY))
            curve(to: CGPoint(x: minX, y: maxY - cornerRadius), controlPoint1: topLeftCorner, controlPoint2: topLeftCorner)
        }
        else {
            line(to: topLeftCorner)
        }
        
        let bottomLeftCorner = CGPoint(x: minX, y: minY)
        
        if corners.contains(.bottomLeft) {
            line(to: CGPoint(x: minX, y: minY + cornerRadius))
            curve(to: CGPoint(x: minX + cornerRadius, y: minY), controlPoint1: bottomLeftCorner, controlPoint2: bottomLeftCorner)
        }
        else {
            line(to: bottomLeftCorner)
        }
    }
}

class ColorView: View {
    
    var fillColor: Color? {
        didSet {
            redraw()
        }
    }
    
    #if os(macOS)
    var backgroundColor: Color? {
        didSet {
            redraw()
        }
    }
    #endif
    
    private func redraw() {
        #if os(iOS) || os(tvOS)
            setNeedsDisplay()
        #elseif os(macOS)
            needsDisplay = true
        #endif
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        #if os(macOS)
        if let backgroundColor = backgroundColor {
            backgroundColor.setFill()
            NSRectFill(bounds)
        }
        #endif
        
        if let fillColor = fillColor {
            let path = BezierPath(rect: bounds, roundedCorners: [.topLeft, .topRight, .bottomRight], cornerRadius: 20)
            
            fillColor.setFill()
            path.fill()
        }
    }
}

let rect = CGRect(x: 0, y: 0, width: 200, height: 200)
var view = ColorView(frame: rect)

view.backgroundColor = .blue

view.fillColor = .red
PlaygroundPage.current.liveView = view
