import Foundation

enum AppError: LocalizedError {
    case badDecode(String? = nil)
    case noData(String? = nil)
    case selfNil(String? = nil)
    case noAds(String? = nil)
    
    var errorDescription: String? {
        switch self {
        case let .badDecode(reason):
            return "Unable to decode type. \(reason == nil ? "" : reason!)."
        case let .noData(reason):
            return "No data was returned from request. \(reason == nil ? "" : reason!)."
        case let .selfNil(reason):
            return "Unable to complete the request. \(reason == nil ? "" : reason!)."
        case let .noAds(reason):
            return "Cannot display ad. \(reason == nil ? "" : reason!)."
        }
    }
}

// MARK: - Error Logging

func nserror(_ err: Error, file: String = #file, function: String = #function, line: UInt = #line) {
    nserror(
        err.localizedDescription,
        file: file,
        function: function,
        line: line
    )
}

func nserror(_ msg: String, file: String = #file, function: String = #function, line: UInt = #line) {
    nslog("FlaskError:\nfile:\(file) function:\(function) line:\(line)\n\t\(msg)")
}

func nslog(_ format: String, _ args: CVarArg...) {
    NSLog(format, args)
}
