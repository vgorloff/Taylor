import Foundation

extension String {
    /// Components of a path; ignores the leading slash and empty components
    /// e.g. "/foo/bar/baz" -> [foo, bar, baz]
    
    var taylor_pathComponents: [String] {
        return self.componentsSeparatedByString("/").filter { $0 != "" }
    }
    
    var NS: NSString {
        return self as NSString
    }

    func componentsSeparatedByString(_ string: String) -> [String] {
        return (self as NSString).components(separatedBy: string)
    }

    var stringByRemovingPercentEncoding: String? {
        return (self as NSString).removingPercentEncoding
    }

    func stringByReplacingOccurrencesOfString(_ of: String, withString: String, options: NSString.CompareOptions, range: NSRange?) -> String {
        return (self as NSString).replacingOccurrences(of: of, with: withString, options: options, range: range ?? NSRange(location: 0, length: (self as NSString).length))
    }

    func rangeOfString(_ string: String) -> NSRange? {
        let r = (self as NSString).range(of: string)
        if r.location == NSNotFound {
            return nil
        } else {
            return r
        }
    }
}

func + (lhs: NSData, rhs: NSData) -> NSData {
    
    let data = NSMutableData(data: lhs as Data)
    data.append(rhs as Data)
    return data
}
