//
//  LargeListApp.swift
//  LargeList
//
//  Created by John Knowles on 6/24/24.
//

import SwiftUI

@main
struct LargeListApp: App {
    var body: some Scene {
        WindowGroup {
            LargeList(count: 1000000)
        }
    }
}
