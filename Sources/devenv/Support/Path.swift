/**
 * Copyright 2020 Saleem Abdulrasool <compnerd@compnerd.org>
 * All Rights Reserved.
 *
 * SPDX-License-Identifier: BSD-3-Clause
 **/

import WinSDK

internal enum Path {
  static func join(_ arcs: String...) -> String {
    guard arcs.count > 1 else { return "" }

    let dwFlags: DWORD = DWORD(PATHCCH_ALLOW_LONG_PATHS.rawValue)
                       | DWORD(PATHCCH_FORCE_ENABLE_LONG_NAME_PROCESS.rawValue)

    var result: String = arcs.first!
    var pszPathOut: PWSTR?
    for arc in arcs.dropFirst() {
      result.withCString(encodedAs: UTF16.self) { pszPathIn in
        arc.withCString(encodedAs: UTF16.self) { pszMore in
          _ = PathAllocCombine(pszPathIn, pszMore, dwFlags, &pszPathOut)
        }
      }
      result = String(decodingCString: pszPathOut!, as: UTF16.self)
      _ = LocalFree(pszPathOut)
    }

    return result
  }

  static func dirname(_ path: String) throws -> String {
    var buffer: [WCHAR] = path.wide
    let hr: HRESULT = buffer.withUnsafeMutableBufferPointer {
      PathCchRemoveFileSpec($0.baseAddress, $0.count)
    }
    guard hr == S_OK else { throw Error(hr: hr) }

    return String(from: buffer)
  }

  static func basename(_ path: String) -> String {
    var buffer: [WCHAR] = path.wide
    return String(decodingCString: PathFindFileNameW(buffer), as: UTF16.self)
  }
}
