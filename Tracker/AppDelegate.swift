import UIKit
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    lazy var trackersDataStore: TrackersDataStore = {
        do {
            return try DataStore() as! TrackersDataStore
        } catch {
            return NullStore() as! TrackersDataStore
        }
    }()
    
    lazy var categoriesDataStore: CategoriesDataStore = {
        do {
            return try DataStore() as! CategoriesDataStore
        } catch {
            return NullStore() as! CategoriesDataStore
        }
    }()

    lazy var executionsDataStore: ExecutionsDataStore = {
        do {
            return try DataStore() as! ExecutionsDataStore
        } catch {
            return NullStore() as! ExecutionsDataStore
        }
    }()

    
    lazy var persistentContainer: NSPersistentContainer = {                     // 1
            let container = NSPersistentContainer(name: "Trackers")              // 2
            container.loadPersistentStores(completionHandler: { (storeDescription, error) in // 3
                if let error = error as NSError? {                              // 4
                    fatalError("Unresolved error \(error), \(error.userInfo)")
                }
            })
            return container
        }()
    
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges { // Проверяем если у контекста какие-то изменения
            do {
                try context.save() // Пробуем сохранить изменения
            } catch {
                context.rollback() // Если что-то пошло не так, то мы просто "откатываем" все изменения назад
            }
        }
    }
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    
}

