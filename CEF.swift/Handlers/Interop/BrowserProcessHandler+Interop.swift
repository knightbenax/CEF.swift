//
//  BrowserProcessHandler.g.swift
//  CEF.swift
//
//  Created by Tamas Lustyik on 2015. 07. 30..
//  Copyright © 2015. Tamas Lustyik. All rights reserved.
//

import Foundation

func BrowserProcessHandler_on_context_initialized(ptr: UnsafeMutablePointer<cef_browser_process_handler_t>) {
    guard let obj = BrowserProcessHandlerMarshaller.get(ptr) else {
        return
    }
    
    obj.onContextInitialized()
}

func BrowserProcessHandler_on_before_child_process_launch(ptr: UnsafeMutablePointer<cef_browser_process_handler_t>,
                                                          commandLine: UnsafeMutablePointer<cef_command_line_t>) {
    guard let obj = BrowserProcessHandlerMarshaller.get(ptr) else {
        return
    }
    
    obj.onBeforeChildProcessLaunch(CommandLine.fromCEF(commandLine)!)
}

func BrowserProcessHandler_on_render_process_thread_created(ptr: UnsafeMutablePointer<cef_browser_process_handler_t>,
                                                            userInfo: UnsafeMutablePointer<cef_list_value_t>) {
    guard let obj = BrowserProcessHandlerMarshaller.get(ptr) else {
        return
    }
    
    obj.onRenderProcessThreadCreated(ListValue.fromCEF(userInfo)!)
}

func BrowserProcessHandler_get_print_handler(ptr: UnsafeMutablePointer<cef_browser_process_handler_t>) -> UnsafeMutablePointer<cef_print_handler_t> {
    guard let obj = BrowserProcessHandlerMarshaller.get(ptr) else {
        return nil
    }

    if let handler = obj.printHandler {
        return handler.toCEF()
    }
    
    return nil
}
