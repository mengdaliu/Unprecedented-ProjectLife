//
//  project.swift
//  ProjectLife
//
//  Created by liumengda on 2019/8/6.
//  Copyright © 2019 Unprecedented. All rights reserved.
//

import Foundation
import Cocoa

class project {
    
    static var appDelegate = NSApp.delegate as! AppDelegate
    static var container = appDelegate.persistentContainer
    static var defaultUrl = NSPersistentContainer.defaultDirectoryURL()
    static var context = dalGlobal.context
    
    static func setUpProjectLife(){
        let req = NSFetchRequest<NSFetchRequestResult>.init(entityName: "Project")
        req.affectedStores = [dalGlobal.userStore!]
        do {
            let gotData = try context!.fetch(req)
            if gotData.count < 1 {
                createProjectLifeObject()
            } else {
                dalGlobal.projectLife = gotData[0] as? Project
            }
        } catch {
            fatalError("Failure to fetch from context: \(error)")
        }
    }
    
    
    
    static func createProjectLifeObject(){
        let projectLife = NSEntityDescription.insertNewObject(forEntityName: "Project", into: context!) as! Project
        context!.assign(projectLife, to: dalGlobal.userStore!)
        //projectLife.title = dalGlobal.userInfo!.nickname! + "' " + "Project Life"
        dalGlobal.projectLife = projectLife
        let today = Date.init()
        let todayHistory = projectHistory.createHistory(for : projectLife, on: today)
        let action = NSEntityDescription.insertNewObject(forEntityName: "Action", into: context!) as! Action
        action.type = "Create"
        context!.assign(action, to: dalGlobal.userStore!)
        todayHistory.addToAction(action)
        do {
            try context!.save()
        } catch {
            fatalError("Failure to save context: \(error)")
        }
    }
    
    static func newProject(for parentProject : Project, title : String) -> Project {
        let project =  NSEntityDescription.insertNewObject(forEntityName: "Project", into: context!) as! Project
        context!.assign(project, to: dalGlobal.userStore!)
        project.title = title
        project.parent = parentProject
        parentProject.addToSubProjects(project)
        let today = Date.init()
        let todayHistory = projectHistory.createHistory(for : project, on: today)
        let action = NSEntityDescription.insertNewObject(forEntityName: "Action", into: context!) as! Action
        action.type = "Create"
        context!.assign(action, to: dalGlobal.userStore!)
        todayHistory.addToAction(action)
        do {
            try context!.save()
        } catch {
            fatalError("Failure to save context: \(error)")
        }
        return project
    }
    
    static func setTitle(for proj: Project, title : String) {
        proj.title = title
        
        do {
            try context!.save()
        } catch {
            fatalError("Failure to save context: \(error)")
        }
    }
    
    
    
    
    static func setOverview(for proj: Project, overview : String) {
        proj.overview = overview
        
        do {
            try context!.save()
        } catch {
            //fatalError("Failure to save context: \(error)")
        }
    }
    
    
    static func delete(proj : Project) {
        context!.delete(proj)
        proj.parent!.removeFromSubProjects(proj)
        proj.parent!.removeFromArchivedSubProjects(proj)
        do {
            try context!.save()
        } catch {
            fatalError("Failure to save context: \(error)")
        }
    }
    
    static func getParent(for proj: Project) -> Project {
        return proj.parent!
    }
    
    static func getChildren(for proj : Project) -> [Project]? {
        if proj.subProjects != nil {
            return Array(proj.subProjects!) as? [Project]
        } else {
            return nil
        }
        
    }
    
    static func getDescription(for proj : Project) -> String? {
        return proj.description
    }
    
    static func setState(for proj : Project, state : String) {
        proj.state = state
    }
    
    static func getState(for proj: Project) -> String? {
        return proj.state
    }
    
    static func moveUp(proj : Project) {
        var front : [Project] = []
        var tail : [Project] = []
        var found = false
        for p in (Array(proj.parent!.subProjects ?? []) as! [Project]) {
            if found { //found之后
                 tail.append(p)
            } else if p != proj { //found之前
                 front.append(p)
            } else { //found当时
                if front.count >= 1 {
                    let last = front[front.count - 1]
                    front.remove(at: front.count - 1)
                    tail.append(last)
                    front.append(p)
                    found = true
                } else {
                    front.append(p)
                    found = true
                }
            }
        }
        front.append(contentsOf: tail)
        proj.parent!.subProjects = NSOrderedSet.init(array: front)
        do {
            try context!.save()
        } catch {
            fatalError("Failure to save context: \(error)")
        }
    }
    
    static func moveDown(proj : Project) {
        if proj.state == nil {
            var new : [Project] = []
            var flip = false
            for p in (Array(proj.parent!.subProjects ?? []) as! [Project]) {
                if flip {
                    flip = false
                    new.remove(at: new.count - 1)
                    new.append(p)
                    new.append(proj)
                } else if proj != p {
                    new.append(p)
                } else {
                    new.append(p)
                    flip = true
                }
            }
            
            proj.parent!.subProjects = NSOrderedSet.init(array: new)
            
            do {
                try context!.save()
            } catch {
                fatalError("Failure to save context: \(error)")
            }
        } else {
            var new : [Project] = []
            var flip = false
            for p in (Array(proj.parent!.archivedSubProjects ?? []) as! [Project]) {
                if flip {
                    flip = false
                    new.remove(at: new.count - 1)
                    new.append(p)
                    new.append(proj)
                } else if proj != p {
                    new.append(p)
                } else {
                    new.append(p)
                    flip = true
                }
            }
            
            proj.parent!.archivedSubProjects = NSOrderedSet.init(array: new)
            
            do {
                try context!.save()
            } catch {
                fatalError("Failure to save context: \(error)")
            }
        }
    }
    
    static func deactivate(proj : Project) {
        
        
       
        proj.parent?.removeFromSubProjects(proj)
        proj.parent?.addToArchivedSubProjects(proj)
        proj.state = "Archived"
        
        
        
        for item in Array(proj.subProjects ?? []) {
            deactivate(proj: item as! Project)
        }
        
        
        let today = Date.init()
        let history = projectHistory.getHistory(for: proj, on: today)
    
        
        var found = false
        for act in Array(history.action ?? []) {
            if (act as! Action).type == "Reactivate" {
                history.removeFromAction(act as! Action)
                context?.delete(act as! NSManagedObject)
                found = true
                break
            }
        }
        
        if !found {
            let action = NSEntityDescription.insertNewObject(forEntityName: "Action", into: context!) as! Action
            action.type = "Archive"
            context!.assign(action, to: dalGlobal.userStore!)
            history.addToAction(action)
        }
        
        
        do {
            try context!.save()
        } catch {
            fatalError("Failure to save context: \(error)")
        }
    }
    
    static func reactivate(proj : Project) {
        proj.parent?.removeFromArchivedSubProjects(proj)
        proj.parent?.addToSubProjects(proj)
        proj.state = nil
        
        let today = Date.init()
        let history = projectHistory.getHistory(for: proj, on: today)
        
        var found = false
        for act in Array(history.action ?? []) {
            if (act as! Action).type == "Archive" {
                history.removeFromAction(act as! Action)
                context?.delete(act as! NSManagedObject)
                found = true
                break
            }
        }
        
        if !found {
            let action = NSEntityDescription.insertNewObject(forEntityName: "Action", into: context!) as! Action
            action.type = "Reactivate"
            context!.assign(action, to: dalGlobal.userStore!)
            history.addToAction(action)
        }
        
        do {
            try context!.save()
        } catch {
            fatalError("Failure to save context: \(error)")
        }
    }
    
    static func moveToParentLevel(proj : Project) {
        let parent = proj.parent
        
        let grandParent = parent!.parent
        if proj.state == nil {
            parent!.removeFromSubProjects(proj)
            grandParent?.addToSubProjects(proj)
        } else {
            parent!.removeFromArchivedSubProjects(proj)
            grandParent?.addToArchivedSubProjects(proj)
        }
       
        proj.parent = grandParent
        
        do {
            try context!.save()
        } catch {
            fatalError("Failure to save context: \(error)")
        }
        
    }
    
    static func move(proj : Project, toChildLevelOf newParent: Project) {
        let parent = proj.parent
        parent!.removeFromSubProjects(proj)
        newParent.addToSubProjects(proj)
        proj.parent = newParent
        
        
        do {
            try context!.save()
        } catch {
            fatalError("Failure to save context: \(error)")
        }
    }
}


class projectHistory {
    
    static var appDelegate = NSApp.delegate as! AppDelegate
    static var container = appDelegate.persistentContainer
    static var defaultUrl = NSPersistentContainer.defaultDirectoryURL()
    static var context = dalGlobal.context
    
    static func getHistory(for proj : Project, on day : Date) -> ProjectHistory {

        // Get the current calendar with local time zone
        var calendar = Calendar.current
        calendar.timeZone = NSTimeZone.local
        
        // Get today's beginning & end
        let dateFrom = calendar.startOfDay(for: day) // eg. 2016-10-10 00:00:00
        
        let dateTo = calendar.date(byAdding: .day, value: 1, to: dateFrom)
        // Note: Times are printed in UTC. Depending on where you live it won't print 00:00:00 but it will work with UTC times which can be converted to local time
        
        // Set predicate as date being today's date
        let fromPredicate = NSPredicate(format: "date >= %@", dateFrom as NSDate)
        let toPredicate = NSPredicate(format: "date < %@", dateTo! as NSDate)
        let datePredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [fromPredicate, toPredicate])
        let history = Array(proj.history ?? []) as! [ProjectHistory]
        var result : [ProjectHistory] = []
        if history != nil {
            for hist in history {
                if dateUtils.equal(dayA: hist.date!, dayB: day) {
                    result.append(hist)
                }
            }
        }
        
        if result.count > 0 {
            return result[0] as! ProjectHistory
        } else {
            return createHistory(for: proj, on: day)
        }
    }
    
    static func createHistory(for proj : Project, on day : Date) -> ProjectHistory {
        let history = NSEntityDescription.insertNewObject(forEntityName: "ProjectHistory", into: context!) as! ProjectHistory
        history.date = day
        proj.addToHistory(history)
        context!.assign(history, to: dalGlobal.userStore!)
        do {
            try context!.save()
        } catch {
            fatalError("Failure to save context: \(error)")
        }
        return history
    }
    
    static func set(action : Action, for history : ProjectHistory) {
        history.addToAction(action)
        do {
            try context!.save()
        } catch {
            fatalError("Failure to save context: \(error)")
        }
    }
    
    
    static func createAction(type : String, plan : Plan?, done : Done?) -> Action {
        let act = NSEntityDescription.insertNewObject(forEntityName: "Action", into: context!) as! Action
        act.type = type
        if act.type == "Plan" {
            act.plan = plan
        } else if act.type == "Done" {
            act.done = done
        }
        context!.assign(act, to: dalGlobal.userStore!)
        do {
            try context!.save()
        } catch {
            fatalError("Failure to save context: \(error)")
        }
        return act
    }
    
    static func delete(action : Action) {
        context!.delete(action)
    }
    
    static func loadHistory(for proj : Project) -> [ProjectHistory]? {

        let sort = NSSortDescriptor(key: #keyPath(ProjectHistory.date), ascending: true)
        let histories = proj.history
        let sortedHistories = histories?.sortedArray(using: [sort])
        
        return sortedHistories as? [ProjectHistory]
    }
}


