//
//  BezierViewController.swift
//  Bézier Curve Editor
//
//  Created by Cory Knapp on 5/21/19.
//  Copyright © 2019 Cory Knapp. All rights reserved.
//

import Foundation
import AppKit

class BezierView : NSView{
    
    typealias BezierPath = NSBezierPath
    
    // MARK: - member vars
    
    var bezierObjects = Array<BezierPath>()
    
    // keep track of what point is selected
    var pointPickedup = false
    var selectedPoint : NSPoint?
    var selectedCurve : BezierPath?
    var selectedElement : Int?
    var selectedPointIndex : Int?
    
    // keep track of what point is under the mouse location, if any.
    var hoverPoint : NSPoint?

    // create a control point path to resuse
    let controlPointPath = BezierPath(rect: NSRect(x: 0, y: 0, width: Style.controlPointSize, height: Style.controlPointSize))
    
    // MARK: - IBActions
    
    @IBAction func newCurve(sender: Any){
        let newCurve = BezierPath()
        bezierObjects.append(newCurve)
        
        newCurve.move(to: self.center)
        newCurve.line(to: NSPoint(x: 200, y: 200))
        
        self.setNeedsDisplay()
    }
    
    @IBAction func extendCurve(sender: Any){
        if selectedCurve != nil {
            // insure that we've selected a point that can be extended
            if ((selectedCurve?.elementCount)! - 1) != selectedElement{
                // for now, let's just let the user add to the last element
                return
            }
            // for now, we'll only extend with curves.  Easy to add lines if needed later.
            // pick a reasonable place to drop the next point.  How about something 25 pixels
            // to the left of the previous point
            let pArray = NSPointArray.allocate(capacity:1)
            pArray[0] = (selectedCurve?.basePoint(elementIndex: selectedElement!))!
            pArray[0].y += 25
            selectedCurve?.appendPoints(pArray, count:1)
            
            self.setNeedsDisplay()
        }
    }
    
    
    // MARK: - overrides
    
    override var acceptsFirstResponder: Bool {get {return true} }
    
    override func draw(_ dirtyRect: NSRect) {
        // draw background
        let rect = BezierPath(rect: dirtyRect)
        Style.backgroundColor.setFill()
        rect.fill()
        
        // draw curves
        for curve in bezierObjects {
            // draw the base curve
            Style.curveColor.setStroke()
            curve.stroke()
            
            // draw start
            let pArray = NSPointArray.allocate(capacity:3)
            pArray[0] = NSPoint(x: 10.0, y: 10.0)
            curve.element(at: 0, associatedPoints: pArray)


            for i in 0..<(curve.elementCount) {
                curve.element(at: i, associatedPoints: pArray)

                Style.controlPointColor.setFill()
                drawControlPoint(pArray[0])
            }
            
        }
        
        if !pointPickedup{
            // draw a highlight over the selected point
            if selectedPoint != nil {
                Style.selectedControlPointColor.setFill()
                drawControlPoint(selectedPoint!)
            }
    
            // draw a highlight over the hover point
            if hoverPoint != nil {
                Style.hoverControlPointColor.setFill()
                drawControlPoint(hoverPoint!)
            }
        }

    }
    
    override func mouseMoved(with event: NSEvent) {
        if let (_, _, _, point) = curveAndPointForMoseLocation(point: event.locationInWindow){
            hoverPoint = point
            setNeedsDisplay()
            return
        }
        if hoverPoint != nil{
            hoverPoint = nil;
            self.setNeedsDisplay()
        }
    }
    
    override func mouseDown(with event: NSEvent) {
        if let (curve, elementIndex, pointIndex, point) = curveAndPointForMoseLocation(point: event.locationInWindow){
            pointPickedup = true
            selectedCurve = curve
            selectedElement = elementIndex
            selectedPointIndex = pointIndex
            selectedPoint = point
            self.setNeedsDisplay()
        }
    }
    
    override func mouseUp(with event: NSEvent) {
        if pointPickedup{
            pointPickedup = false
            selectedPoint = event.locationInWindow
            self.setNeedsDisplay()
        }
    }
    
    override func mouseDragged(with event: NSEvent) {
        if pointPickedup{
            selectedCurve!.setControlPoint(elementIndex: selectedElement!, pointIndex: selectedPointIndex!, newPoint: event.locationInWindow)
            setNeedsDisplay()
        }
    }
    
    // MARK: - additional methods
    
    func drawControlPoint(_ point: NSPoint) {
        let cppCopy = (controlPointPath.copy() as! BezierPath)
        cppCopy.transform(using: AffineTransform(
            translationByX: point.x - CGFloat(Style.controlPointSize * 0.5),
            byY: point.y - CGFloat(Style.controlPointSize * 0.5)
        ))
        cppCopy.fill()
    }
    
    func curveAndPointForMoseLocation(point: NSPoint) -> (BezierPath, Int, Int, NSPoint)?{
        // iterate through every control point and find one that's close
        for curve in bezierObjects{
            for i in 0...(curve.elementCount-1) {
                let pArray = NSPointArray.allocate(capacity:3)
                let elementType = curve.element(at: i, associatedPoints: pArray)
                
                for j in 0..<BezierPath.pointCountForElementType(elementType){
                    let dist = point.manhattanDistance(pArray[j]);
                    if(dist < 5){
                        return (curve, i, j, pArray[j])
                    }
                }
            }
        }
        return nil
    }
}

// MARK: - extentions

extension NSView{
    var center : NSPoint {
        get {
            return CGPoint(x: NSMidX(self.frame), y: NSMidY(self.frame))
        }
    }
    
    func setNeedsDisplay(){
        self.setNeedsDisplay(self.frame)
    }
}

extension NSPoint{
    func manhattanDistance(_ point: NSPoint) -> CGFloat{
        return abs(self.x - point.x) + abs(self.y - point.y)
    }
}

extension BezierView.BezierPath{
    static func pointCountForElementType(_ type: NSBezierPath.ElementType) -> Int{
        switch type {
        case .closePath:
            return 1
        case .curveTo:
            return 3
        case .lineTo:
            return 1
        case .moveTo:
            return 1
        }
    }
    
    func setControlPoint(elementIndex: Int, pointIndex: Int, newPoint: NSPoint){
        let pArray = NSPointArray.allocate(capacity:3)
        self.element(at: elementIndex, associatedPoints: pArray)
        pArray[pointIndex] = newPoint
        self.setAssociatedPoints(pArray, at: elementIndex)
    }
    
    func basePoint(elementIndex: Int) -> NSPoint{
        let pArray = NSPointArray.allocate(capacity:3)
        self.element(at: elementIndex, associatedPoints: pArray)
        return pArray[0]
    }
}
