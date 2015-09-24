//
//  CookieManager.swift
//  CEF.swift
//
//  Created by Tamas Lustyik on 2015. 08. 02..
//  Copyright © 2015. Tamas Lustyik. All rights reserved.
//

import Foundation

extension cef_cookie_manager_t: CEFObject {
}

/// Class used for managing cookies. The methods of this class may be called on
/// any thread unless otherwise indicated.
public class CookieManager: Proxy<cef_cookie_manager_t> {

    /// Returns the global cookie manager. By default data will be stored at
    /// CefSettings.cache_path if specified or in memory otherwise. If |callback|
    /// is non-NULL it will be executed asnychronously on the IO thread after the
    /// manager's storage has been initialized. Using this method is equivalent to
    /// calling CefRequestContext::GetGlobalContext()->GetDefaultCookieManager().
    public static func globalManager(callback: CompletionCallback? = nil) -> CookieManager? {
        var cefCallbackPtr: UnsafeMutablePointer<cef_completion_callback_t> = nil
        if let callback = callback {
            cefCallbackPtr = callback.toCEF()
        }
        
        let cefCookieMgr = cef_cookie_manager_get_global_manager(cefCallbackPtr)
        return CookieManager.fromCEF(cefCookieMgr)
    }
    
    /// Creates a new cookie manager. If |path| is empty data will be stored in
    /// memory only. Otherwise, data will be stored at the specified |path|. To
    /// persist session cookies (cookies without an expiry date or validity
    /// interval) set |persist_session_cookies| to true. Session cookies are
    /// generally intended to be transient and most Web browsers do not persist
    /// them. If |callback| is non-NULL it will be executed asnychronously on the
    /// IO thread after the manager's storage has been initialized.
    public init?(path: String? = nil,
                 persistSessionCookies: Bool,
                 callback: CompletionCallback? = nil) {
        let cefPathPtr = path != nil ? CEFStringPtrCreateFromSwiftString(path!) : nil
        defer { CEFStringPtrRelease(cefPathPtr) }
                                        
        var cefCallbackPtr: UnsafeMutablePointer<cef_completion_callback_t> = nil
        if let callback = callback {
            cefCallbackPtr = callback.toCEF()
        }
        
        let cefCookieMgr = cef_cookie_manager_create_manager(cefPathPtr, persistSessionCookies ? 1 : 0, cefCallbackPtr)
        super.init(ptr: cefCookieMgr)
    }
    
    /// Set the schemes supported by this manager. By default only "http" and
    /// "https" schemes are supported. If |callback| is non-NULL it will be
    /// executed asnychronously on the IO thread after the change has been applied.
    /// Must be called before any cookies are accessed.
    public func setSupportedSchemes(schemes: [String], callback: CompletionCallback? = nil) {
        let cefSchemes = CEFStringListCreateFromSwiftArray(schemes)
        defer { CEFStringListRelease(cefSchemes) }

        var cefCallbackPtr: UnsafeMutablePointer<cef_completion_callback_t> = nil
        if let callback = callback {
            cefCallbackPtr = callback.toCEF()
        }

        cefObject.set_supported_schemes(cefObjectPtr, cefSchemes, cefCallbackPtr)
    }

    /// Visit all cookies on the IO thread. The returned cookies are ordered by
    /// longest path, then by earliest creation date. Returns false if cookies
    /// cannot be accessed.
    public func enumerateAllCookiesUsingVisitor(visitor: CookieVisitor) -> Bool {
        return cefObject.visit_all_cookies(cefObjectPtr, visitor.toCEF()) != 0
    }

    /// Visit a subset of cookies on the IO thread. The results are filtered by the
    /// given url scheme, host, domain and path. If |includeHttpOnly| is true
    /// HTTP-only cookies will also be included in the results. The returned
    /// cookies are ordered by longest path, then by earliest creation date.
    /// Returns false if cookies cannot be accessed.
    public func enumerateCookiesForURL(url: NSURL, includeHTTPOnly: Bool, usingVisitor visitor: CookieVisitor) -> Bool {
        let cefURLPtr = CEFStringPtrCreateFromSwiftString(url.absoluteString)
        defer { CEFStringPtrRelease(cefURLPtr) }
        return cefObject.visit_url_cookies(cefObjectPtr, cefURLPtr, includeHTTPOnly ? 1 : 0, visitor.toCEF()) != 0
    }
    
    /// Sets a cookie given a valid URL and explicit user-provided cookie
    /// attributes. This function expects each attribute to be well-formed. It will
    /// check for disallowed characters (e.g. the ';' character is disallowed
    /// within the cookie value attribute) and fail without setting the cookie if
    /// such characters are found. If |callback| is non-NULL it will be executed
    /// asnychronously on the IO thread after the cookie has been set. Returns
    /// false if an invalid URL is specified or if cookies cannot be accessed.
    public func setCookie(url: NSURL, cookie: Cookie, callback: SetCookieCallback? = nil) -> Bool {
        let cefURLPtr = CEFStringPtrCreateFromSwiftString(url.absoluteString)
        defer { CEFStringPtrRelease(cefURLPtr) }
        
        var cefCallbackPtr: UnsafeMutablePointer<cef_set_cookie_callback_t> = nil
        if let callback = callback {
            cefCallbackPtr = callback.toCEF()
        }

        var cefCookie = cookie.toCEF()
        defer { cefCookie.clear() }
        
        return cefObject.set_cookie(cefObjectPtr, cefURLPtr, &cefCookie, cefCallbackPtr) != 0
    }
    
    /// Delete all cookies that match the specified parameters. If both |url| and
    /// |cookie_name| values are specified all host and domain cookies matching
    /// both will be deleted. If only |url| is specified all host cookies (but not
    /// domain cookies) irrespective of path will be deleted. If |url| is empty all
    /// cookies for all hosts and domains will be deleted. If |callback| is
    /// non-NULL it will be executed asnychronously on the IO thread after the
    /// cookies have been deleted. Returns false if a non-empty invalid URL is
    /// specified or if cookies cannot be accessed. Cookies can alternately be
    /// deleted using the Visit*Cookies() methods.
    public func deleteCookies(url: NSURL? = nil, name: String? = nil, callback: DeleteCookiesCallback? = nil) -> Bool {
        let cefURLPtr = url != nil ? CEFStringPtrCreateFromSwiftString(url!.absoluteString) : nil
        let cefNamePtr = name != nil ? CEFStringPtrCreateFromSwiftString(name!) : nil
        defer {
            CEFStringPtrRelease(cefURLPtr)
            CEFStringPtrRelease(cefNamePtr)
        }

        var cefCallbackPtr: UnsafeMutablePointer<cef_delete_cookies_callback_t> = nil
        if let callback = callback {
            cefCallbackPtr = callback.toCEF()
        }
        
        return cefObject.delete_cookies(cefObjectPtr, cefURLPtr, cefNamePtr, cefCallbackPtr) != 0
    }
    
    /// Sets the directory path that will be used for storing cookie data. If
    /// |path| is empty data will be stored in memory only. Otherwise, data will be
    /// stored at the specified |path|. To persist session cookies (cookies without
    /// an expiry date or validity interval) set |persist_session_cookies| to true.
    /// Session cookies are generally intended to be transient and most Web
    /// browsers do not persist them. If |callback| is non-NULL it will be executed
    /// asnychronously on the IO thread after the manager's storage has been
    /// initialized. Returns false if cookies cannot be accessed.
    public func setStoragePath(path: String? = nil, persistSessionCookies: Bool, callback: CompletionCallback? = nil) -> Bool {
        let cefPathPtr = path != nil ? CEFStringPtrCreateFromSwiftString(path!) : nil
        defer { CEFStringPtrRelease(cefPathPtr) }
        
        var cefCallbackPtr: UnsafeMutablePointer<cef_completion_callback_t> = nil
        if let callback = callback {
            cefCallbackPtr = callback.toCEF()
        }
        
        return cefObject.set_storage_path(cefObjectPtr, cefPathPtr, persistSessionCookies ? 1 : 0, cefCallbackPtr) != 0
    }
    
    /// Flush the backing store (if any) to disk. If |callback| is non-NULL it will
    /// be executed asnychronously on the IO thread after the flush is complete.
    /// Returns false if cookies cannot be accessed.
    public func flushStore(callback: CompletionCallback? = nil) -> Bool {
        var cefCallbackPtr: UnsafeMutablePointer<cef_completion_callback_t> = nil
        if let callback = callback {
            cefCallbackPtr = callback.toCEF()
        }
        
        return cefObject.flush_store(cefObjectPtr, cefCallbackPtr) != 0
    }
    
    // private
    
    override init?(ptr: ObjectPtrType) {
        super.init(ptr: ptr)
    }
    
    static func fromCEF(ptr: ObjectPtrType) -> CookieManager? {
        return CookieManager(ptr: ptr)
    }
}


public extension CookieManager {

    /// Returns the global cookie manager. By default data will be stored at
    /// CefSettings.cache_path if specified or in memory otherwise. If |callback|
    /// is non-NULL it will be executed asnychronously on the IO thread after the
    /// manager's storage has been initialized. Using this method is equivalent to
    /// calling CefRequestContext::GetGlobalContext()->GetDefaultCookieManager().
    public static func globalManager(block: CompletionCallbackOnCompleteBlock) -> CookieManager? {
        return CookieManager.globalManager(CompletionCallbackBridge(block: block))
    }

    /// Creates a new cookie manager. If |path| is empty data will be stored in
    /// memory only. Otherwise, data will be stored at the specified |path|. To
    /// persist session cookies (cookies without an expiry date or validity
    /// interval) set |persist_session_cookies| to true. Session cookies are
    /// generally intended to be transient and most Web browsers do not persist
    /// them. If |callback| is non-NULL it will be executed asnychronously on the
    /// IO thread after the manager's storage has been initialized.
    public convenience init?(path: String? = nil,
                             persistSessionCookies: Bool,
                             block: CompletionCallbackOnCompleteBlock) {
        self.init(path: path,
                  persistSessionCookies: persistSessionCookies,
                  callback: CompletionCallbackBridge(block: block))
    }

    /// Set the schemes supported by this manager. By default only "http" and
    /// "https" schemes are supported. If |callback| is non-NULL it will be
    /// executed asnychronously on the IO thread after the change has been applied.
    /// Must be called before any cookies are accessed.
    public func setSupportedSchemes(schemes: [String], block: CompletionCallbackOnCompleteBlock) {
        return setSupportedSchemes(schemes, callback: CompletionCallbackBridge(block: block))
    }

    /// Visit all cookies on the IO thread. The returned cookies are ordered by
    /// longest path, then by earliest creation date. Returns false if cookies
    /// cannot be accessed.
    public func enumerateAllCookies(block: CookieVisitorVisitBlock) -> Bool {
        return enumerateAllCookiesUsingVisitor(CookieVisitorBridge(block: block))
    }
    
    /// Visit a subset of cookies on the IO thread. The results are filtered by the
    /// given url scheme, host, domain and path. If |includeHttpOnly| is true
    /// HTTP-only cookies will also be included in the results. The returned
    /// cookies are ordered by longest path, then by earliest creation date.
    /// Returns false if cookies cannot be accessed.
    public func enumerateCookiesForURL(url: NSURL, includeHTTPOnly: Bool, block: CookieVisitorVisitBlock) -> Bool {
        return enumerateCookiesForURL(url, includeHTTPOnly: includeHTTPOnly, usingVisitor: CookieVisitorBridge(block: block))
    }

    /// Sets a cookie given a valid URL and explicit user-provided cookie
    /// attributes. This function expects each attribute to be well-formed. It will
    /// check for disallowed characters (e.g. the ';' character is disallowed
    /// within the cookie value attribute) and fail without setting the cookie if
    /// such characters are found. If |callback| is non-NULL it will be executed
    /// asnychronously on the IO thread after the cookie has been set. Returns
    /// false if an invalid URL is specified or if cookies cannot be accessed.
    public func setCookie(url: NSURL, cookie: Cookie, block: SetCookieCallbackOnCompleteBlock) -> Bool {
        return setCookie(url, cookie: cookie, callback: SetCookieCallbackBridge(block: block))
    }
    
    /// Delete all cookies that match the specified parameters. If both |url| and
    /// |cookie_name| values are specified all host and domain cookies matching
    /// both will be deleted. If only |url| is specified all host cookies (but not
    /// domain cookies) irrespective of path will be deleted. If |url| is empty all
    /// cookies for all hosts and domains will be deleted. If |callback| is
    /// non-NULL it will be executed asnychronously on the IO thread after the
    /// cookies have been deleted. Returns false if a non-empty invalid URL is
    /// specified or if cookies cannot be accessed. Cookies can alternately be
    /// deleted using the Visit*Cookies() methods.
    public func deleteCookies(url: NSURL? = nil, name: String? = nil, block: DeleteCookiesCallbackOnCompleteBlock) -> Bool {
        return deleteCookies(url,
                             name: name,
                             callback: DeleteCookiesCallbackBridge(block: block))
    }

    /// Sets the directory path that will be used for storing cookie data. If
    /// |path| is empty data will be stored in memory only. Otherwise, data will be
    /// stored at the specified |path|. To persist session cookies (cookies without
    /// an expiry date or validity interval) set |persist_session_cookies| to true.
    /// Session cookies are generally intended to be transient and most Web
    /// browsers do not persist them. If |callback| is non-NULL it will be executed
    /// asnychronously on the IO thread after the manager's storage has been
    /// initialized. Returns false if cookies cannot be accessed.
    public func setStoragePath(path: String? = nil, persistSessionCookies: Bool, block: CompletionCallbackOnCompleteBlock) -> Bool {
        return setStoragePath(path,
                              persistSessionCookies: persistSessionCookies,
                              callback: CompletionCallbackBridge(block: block))
    }

    /// Flush the backing store (if any) to disk. If |callback| is non-NULL it will
    /// be executed asnychronously on the IO thread after the flush is complete.
    /// Returns false if cookies cannot be accessed.
    public func flushStore(block: CompletionCallbackOnCompleteBlock) -> Bool {
        return flushStore(CompletionCallbackBridge(block: block))
    }

}
