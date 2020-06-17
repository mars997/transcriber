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
    @objc dynamic var id:String = ""
    @objc dynamic var user:String = ""
    @objc dynamic var title:String = ""
    @objc dynamic var url:String = ""
    @objc dynamic var Notes:String = ""
    @objc dynamic var startTime = ""
    @objc dynamic var duration = ""
    @objc dynamic var transcribed = false
    var parentCategory = LinkingObjects(fromType: Category.self, property: "records")
}
