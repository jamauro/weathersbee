//
//  UILabelNonClipping.swift
//  WeatherFeel
//
//  Created by John Mauro on 7/28/15.
//  Copyright (c) 2015 John Mauro. All rights reserved.
//

import UIKit

class UILabelNonClipping: UILabel {
  
  let gutter: CGFloat = 6.0
 
  
  /*
  override func drawTextInRect(rect: CGRect) {
    if font.fontName == "PlayfairDisplay-Italic" {
      print("hello non clipping")
      var newRect: CGRect
      // newRect.origin.x = rect.origin.x + gutter
      // newRect.size.width = rect.size.width - 2 * gutter
      newRect = CGRectMake(rect.origin.x + 2, rect.origin.y, rect.width, rect.height)
      super.drawTextInRect(newRect)
    }
  }
  */
  override func drawRect(rect: CGRect) {
    var newRect = rect
    newRect.origin.x = rect.origin.x + gutter
    newRect.size.width = rect.size.width - 2 * gutter
    self.attributedText!.drawInRect(newRect)
  }
  
  override func alignmentRectInsets() -> UIEdgeInsets {
    return UIEdgeInsetsMake(0, gutter, 0, gutter)
  }
  
  override func intrinsicContentSize() -> CGSize {
    var size: CGSize = super.intrinsicContentSize()
    size.width += 2 * gutter
    return size
  }


    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
