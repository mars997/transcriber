//
//  Record.swift
//  transcriber
//
//  Created by Hamed Ansari on 5/31/20.
//  Copyright © 2020 exoptima. All rights reserved.
//
import Foundation
import RealmSwift

class  Record: Object {
    @objc dynamic var user:String = ""
    @objc dynamic var title:String = ""
    @objc dynamic var url:String = ""
    @objc dynamic var Notes:String = ""
    @objc dynamic var startTime = Date()
    @objc dynamic var duration = 0.0
    @objc dynamic var transcribed = false
    var parentCategory = LinkingObjects(fromType: Category.self, property: "records")
}
