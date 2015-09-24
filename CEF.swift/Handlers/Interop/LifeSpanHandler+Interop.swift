//
//  LifeSpanHandler.g.swift
//  CEF.swift
//
//  Created by Tamas Lustyik on 2015. 07. 30..
//  Copyright © 2015. Tamas Lustyik. All rights reserved.
//

import Foundation

func LifeSpanHandler_on_before_popup(ptr: UnsafeMutablePointer<cef_life_span_handler_t>,
                                     browser: UnsafeMutablePointer<cef_browser_t>,
                                     frame: UnsafeMutablePointer<cef_frame_t>,
                                     url: UnsafePointer<cef_string_t>,
                                     frameName: UnsafePointer<cef_string_t>,
                                     disposition: cef_window_open_disposition_t,
                                     userGesture: Int32,
                                     features: UnsafePointer<cef_popup_features_t>,
                                     windowInfo: UnsafeMutablePointer<cef_window_info_t>,
                                     cefClient: UnsafeMutablePointer<UnsafeMutablePointer<cef_client_t>>,
                                     cefSettings: UnsafeMutablePointer<cef_browser_settings_t>,
                                     noJSAccess: UnsafeMutablePointer<Int32>) -> Int32 {
    guard let obj = LifeSpanHandlerMarshaller.get(ptr) else {
        return 0
    }
    
    var winInfo = WindowInfo.fromCEF(windowInfo.memory)
    var client = ClientMarshaller.take(cefClient.memory)!
    var settings = BrowserSettings.fromCEF(cefSettings.memory)
    var jsAccess = !(noJSAccess.memory != 0)
    
    let retval = obj.onBeforePopup(Browser.fromCEF(browser)!,
        frame: Frame.fromCEF(frame)!,
        targetURL: url != nil ? NSURL(string: CEFStringToSwiftString(url.memory)) : nil,
        targetFrameName: frameName != nil ? CEFStringToSwiftString(frameName.memory) : nil,
        targetDisposition: WindowOpenDisposition.fromCEF(disposition),
        userGesture: userGesture != 0,
        popupFeatures: PopupFeatures.fromCEF(features.memory),
        windowInfo: &winInfo,
        client: &client,
        settings: &settings,
        jsAccess: &jsAccess)

    windowInfo.memory = winInfo.toCEF()
    cefClient.memory = ClientMarshaller.pass(client)
    cefSettings.memory = settings.toCEF()
    noJSAccess.memory = jsAccess ? 0 : 1
    
    return retval ? 1 : 0
}


func LifeSpanHandler_on_after_created(ptr: UnsafeMutablePointer<cef_life_span_handler_t>,
                                      browser: UnsafeMutablePointer<cef_browser_t>) {
    guard let obj = LifeSpanHandlerMarshaller.get(ptr) else {
        return
    }
    
    obj.onAfterCreated(Browser.fromCEF(browser)!)
}

func LifeSpanHandler_run_modal(ptr: UnsafeMutablePointer<cef_life_span_handler_t>,
                               browser: UnsafeMutablePointer<cef_browser_t>) -> Int32 {
    guard let obj = LifeSpanHandlerMarshaller.get(ptr) else {
        return 0
    }
    
    return obj.onRunModal(Browser.fromCEF(browser)!) ? 1 : 0
}

func LifeSpanHandler_do_close(ptr: UnsafeMutablePointer<cef_life_span_handler_t>,
                              browser: UnsafeMutablePointer<cef_browser_t>) -> Int32 {
    guard let obj = LifeSpanHandlerMarshaller.get(ptr) else {
        return 0
    }
    
    return obj.onDoClose(Browser.fromCEF(browser)!) ? 1 : 0
}

func LifeSpanHandler_on_before_close(ptr: UnsafeMutablePointer<cef_life_span_handler_t>,
                                     browser: UnsafeMutablePointer<cef_browser_t>) {
    guard let obj = LifeSpanHandlerMarshaller.get(ptr) else {
        return
    }
    
    obj.onBeforeClose(Browser.fromCEF(browser)!)
}
