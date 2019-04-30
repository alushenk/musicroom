//
//  DataConvertible.swift
//  MusicRoom
//
//  Created by Heorhii Shakula on 4/14/19.
//  Copyright © 2019 Heorhii Shakula. All rights reserved.
//

protocol DataConvertible {
    init?(data: Data)
    var data: Data { get }
}

extension DataConvertible {

    init?(data: Data) {
        guard data.count == MemoryLayout<Self>.size else { return nil }
        self = data.withUnsafeBytes { $0.pointee }
    }

    var data: Data {
        var value = self
        return Data(buffer: UnsafeBufferPointer(start: &value, count: 1))
    }
}

extension String: DataConvertible {
    init?(data: Data) {
        self.init(data: data, encoding: .utf8)
    }

    var data: Data {
        // Note: a conversion to UTF-8 cannot fail.
        return self.data(using: .utf8)!
    }
}

extension Int32: DataConvertible {
    init?(data: Data) {
        guard let str = String.init(data: data),
            let value = Int32(str) else {
            return nil
        }
        self = value
    }

    var data: Data {
        return String(self).data
    }
}

extension Double: DataConvertible {}
extension Int: DataConvertible {}
extension Date: DataConvertible {}

