//
//  PockMainController.swift
//  Pock
//
//  Created by Pierluigi Galdi on 21/10/2018.
//  Copyright © 2018 Pierluigi Galdi. All rights reserved.
//

import Foundation
import PockKit

/// Custom identifiers
extension NSTouchBar.CustomizationIdentifier {
    static let pockTouchBar = "PockTouchBar"
}
extension NSTouchBarItem.Identifier {
    static let pockSystemIcon = NSTouchBarItem.Identifier("Pock")
    static let dockView       = NSTouchBarItem.Identifier("Dock")
    static let controlCenter  = NSTouchBarItem.Identifier("ControlCenter")
}

class PockMainController: PKTouchBarController {
    
    private var items: [NSTouchBarItem.Identifier: NSTouchBarItem] = [:]
    
    override var systemTrayItem: NSCustomTouchBarItem? {
        let item = NSCustomTouchBarItem(identifier: .pockSystemIcon)
        item.view = NSButton(image: #imageLiteral(resourceName: "pock-inner-icon"), target: self, action: #selector(presentFromSystemTrayItem))
        return item
    }
    override var systemTrayItemIdentifier: NSTouchBarItem.Identifier? { return .pockSystemIcon }
    
    deinit {
        items.removeAll()
        WidgetsDispatcher.default.clearLoadedWidgets()
        if !isProd { print("[PockMainController]: Deinit Pock main controller") }
    }
    
    override func didLoad() {
        WidgetsDispatcher.default.loadInstalledWidget() { [weak self] identifiers in
            self?.touchBar?.customizationIdentifier             = .pockTouchBar
            self?.touchBar?.customizationAllowedItemIdentifiers = [.dockView, .controlCenter]
            self?.touchBar?.customizationAllowedItemIdentifiers.append(contentsOf: identifiers)
            self?.awakeFromNib()
        }
    }
    
    func touchBar(_ touchBar: NSTouchBar, makeItemForIdentifier identifier: NSTouchBarItem.Identifier) -> NSTouchBarItem? {
        
        if let item = items[identifier] {
            return item
        }
        
        var widget: PKWidget?
        switch identifier {
        /// Dock widget
        case .dockView:
            widget = DockWidget()
        /// ControlCenter widget
        case .controlCenter:
            widget = ControlCenterWidget()
        /// 3rd widgets
        default:
            widget = WidgetsDispatcher.default.loadedWidgets[identifier]?.init()
        }
        guard widget != nil else {
            return nil
        }
        
        let item = PKWidgetTouchBarItem(widget: widget!)
        items[identifier] = item
        return item
    }
    
}
