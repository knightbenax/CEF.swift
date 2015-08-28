//
//  CEFRequestHandler+Interop.g.swift
//  CEF.swift
//
//  This file was generated automatically from cef_request_handler.h.
//

import Foundation

extension cef_request_handler_t: CEFObject {}

typealias CEFRequestHandlerMarshaller = CEFMarshaller<CEFRequestHandler, cef_request_handler_t>

extension cef_request_handler_t {
    func toCEF() -> UnsafeMutablePointer<cef_request_handler_t> {
        return CEFRequestHandlerMarshaller.pass(self)
    }
}

extension cef_request_handler_t: CEFCallbackMarshalling {
    mutating func marshalCallbacks() {
        on_before_browse = CEFRequestHandler_on_before_browse
        on_open_urlfrom_tab = CEFRequestHandler_on_open_urlfrom_tab
        on_before_resource_load = CEFRequestHandler_on_before_resource_load
        get_resource_handler = CEFRequestHandler_get_resource_handler
        on_resource_redirect = CEFRequestHandler_on_resource_redirect
        on_resource_response = CEFRequestHandler_on_resource_response
        get_auth_credentials = CEFRequestHandler_get_auth_credentials
        on_quota_request = CEFRequestHandler_on_quota_request
        on_protocol_execution = CEFRequestHandler_on_protocol_execution
        on_certificate_error = CEFRequestHandler_on_certificate_error
        on_before_plugin_load = CEFRequestHandler_on_before_plugin_load
        on_plugin_crashed = CEFRequestHandler_on_plugin_crashed
        on_render_view_ready = CEFRequestHandler_on_render_view_ready
        on_render_process_terminated = CEFRequestHandler_on_render_process_terminated
    }
}
