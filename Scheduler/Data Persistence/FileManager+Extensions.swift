//
//  FileManager+Extensions.swift
//  Scheduler
//
//  Created by Alex Paul on 1/23/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import Foundation


public enum Directory {
  case documentsDirectory
  case cachesDirectory
}

extension FileManager {
  // returns a URL to the documents directory for the app
  public static func getDocumentsDirectory() -> URL  {
    return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
  }
  
  public static func getCachesDirectory() -> URL  {
    return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
  }
  
  // function takes a filename as a parameter, appends to the document directory's URL and returns that path
  // this path will be used to write (save) date or read (retrieve) data
  public static func getPath(with filename: String, for directory: Directory) -> URL {
    switch directory {
    case .cachesDirectory:
      return getCachesDirectory().appendingPathComponent(filename)
    case .documentsDirectory:
      return getDocumentsDirectory().appendingPathComponent(filename)
    }
  }
}
