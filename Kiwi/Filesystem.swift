//
//  Filesystem.swift
//  Kiwi
//
//  Created by Mark Hudnall on 11/7/16.
//  Copyright © 2016 Mark Hudnall. All rights reserved.
//

import Foundation
import FileKit
import EmitterKit

typealias Path = FileKit.Path


struct Filesystem {
    static let sharedInstance = Filesystem()
    
    let event: Event<FilesystemEvent> = Event();
    let root: Path
    
    init(root: Path = Path.userDocuments) {
        self.root = root
    }
    
    private func fromRoot(_ path: Path) -> Path {
        // If root is the common ancestor, then the path has already been resolved
        if (self.root.commonAncestor(path) == self.root) {
            return path
        }
        return self.root + path
    }
    
    func list(path: Path) -> [Path] {
        let path = fromRoot(path)
        return path.children()
    }
    
    func read<T: ReadableWritable>(path: Path) throws -> File<T> {
        let realFile = FileKit.File<T>(path: fromRoot(path))
        let contents = try realFile.read()
        let absPath = fromRoot(path)
        return File(path: absPath, modifiedDate: absPath.modificationDate, contents: contents)
    }
    
    func mkdir(path: Path) throws {
        print("mkdir \(path)")
        try fromRoot(path).createDirectory()
    }
    
    func exists(path: Path) -> Bool {
        return fromRoot(path).exists
    }
    
    func write<T: ReadableWritable>(file: File<T>, emit: Bool = true) throws {
        print("write \(file.path)")
        let realFile = FileKit.File<T>(path: fromRoot(file.path))
        try realFile.write(file.contents)
        if ((file.modifiedDate) != nil) {
            realFile.path.modificationDate = file.modifiedDate   
        }
        if emit {
            event.emit(.write(path: file.path))
        }
    }
    
    func delete<T: ReadableWritable>(file: File<T>, emit: Bool = true) throws {
        try self.delete(path: file.path, emit: emit)
    }
    
    func delete(path: Path, emit: Bool = true) throws {
        print("delete \(path)")
        try fromRoot(path).deleteFile()
        if emit {
            event.emit(.delete(path: path))
        }
    }
    
    func touch(path: Path, modificationDate: Date = Date()) throws {
        print("touch \(path)")
        try fromRoot(path).touch(modificationDate: modificationDate)
    }
}

struct File<T: ReadableWritable> {
    var path: Path
    var _modifiedDate: Date?
    var modifiedDate: Date? {
        get {
            return _modifiedDate
        }
        set {
            _modifiedDate = newValue
            if (_modifiedDate != nil) {
                path.modificationDate = _modifiedDate
            }
        }
    }
    var contents: T
    
    init(path: Path, modifiedDate: Date? = nil, contents: T) {
        self.path = path
        self.contents = contents
        self.modifiedDate = modifiedDate
    }
}

enum FilesystemEvent {
    case write(path: Path)
    case delete(path: Path)
}

