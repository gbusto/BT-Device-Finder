//
//  Persistence.swift
//  Bluetooth Finder
//
//  Created by Gabriel Busto on 12/24/22.
//
import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        for _ in 0..<10 {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()
        }
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Bluetooth_Finder")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    func getObjectWithId(_ deviceId: UUID) -> NSManagedObject? {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Device")
        fetchRequest.predicate = NSPredicate(format: "id == %@", deviceId as CVarArg)
        
        do {
            let items = try container.viewContext.fetch(fetchRequest)
            return items.first
        } catch let error as NSError {
            print("Could not fetch data: \(error)\n\(error.userInfo)")+
        }
        
        return nil
    }
    
    func createObject(withId deviceId: UUID, withName deviceName: String, favorited favorited: Bool) -> Bool {
        let context = container.viewContext
        
        let newItem = Device(context: context)
        newItem.id = deviceId
        newItem.customName = deviceName
        
        do {
            try context.save()
            return true
        }
        catch {
            let nsError = error as NSError
            print("[!] Error creating device with ID \(deviceId.uuidString) and name \(deviceName) - \(nsError), \(nsError.userInfo)")
            return false
        }
    }
    
    func updateObjectFavoriteStatus(withId deviceId: UUID, withFavoriteStatus status: Bool) -> Bool {
        let context = container.viewContext

        if let item = self.getObjectWithId(deviceId) {
            item.setValue(status, forKey: "favorite")
            
            do {
                try context.save()
                return true
            }
            catch {
                let nsError = error as NSError
                print("[!] Error updating device with ID \(deviceId.uuidString) and status \(status) - \(nsError), \(nsError.userInfo)")
                return false
            }
        }
        
        return false
    }
    
    func updateObjectName(withId deviceId: UUID, withName deviceName: String) -> Bool {
        let context = container.viewContext

        if let item = self.getObjectWithId(deviceId) {
            item.setValue(deviceName, forKey: "customName")
            
            do {
                try context.save()
                return true
            }
            catch {
                let nsError = error as NSError
                print("[!] Error updating device with ID \(deviceId.uuidString) and name \(deviceName) - \(nsError), \(nsError.userInfo)")
                return false
            }
        }
        
        return false
    }
}
