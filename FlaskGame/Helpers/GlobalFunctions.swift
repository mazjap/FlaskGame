import Foundation

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
    NSLog("FlaskError:\nfile:\(file) function:\(function) line:\(line)\n\t\(msg)")
}

// MARK: - Math

func minmax<C>(_ lowerBound: C, _ upperBound: C, _ value: C) -> C where C: Comparable {
    min(upperBound, max(lowerBound, value))
}
