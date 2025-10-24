import Foundation
import FoundationModels
import EventKit


struct AddToShoppingList: Tool {
    let name = "addReminder"
    let description = "Add ingredients to the user's shopping list as a reminder. Use this tool after generating a menu to help the user remember what ingredients to buy."
   
    @Generable
    struct Arguments {
      @Guide(description: "An array of ingredients needed to prepare the meals in the menu")
      var ingredients: [String]
    }

    
    func call(arguments: Arguments) async throws -> String {
        let eventStore = EKEventStore()
        
        do {
            try await eventStore.requestFullAccessToReminders()
        } catch {
            return "Unable to access reminders. Permission denied."
        }
        
        let reminder = EKReminder(eventStore: eventStore)
        reminder.title = "Shopping List for Menu"
        
        let ingredientsList = arguments.ingredients.joined(separator: ", ")
        reminder.notes = ingredientsList
        
        let calendar = eventStore.defaultCalendarForNewReminders()
        reminder.calendar = calendar
        
        let dueDate = Calendar.current.date(byAdding: .day, value: 1, to: Date())
        if let dueDate = dueDate {
            let dueDateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: dueDate)
            reminder.dueDateComponents = dueDateComponents
        }
        
        do {
            try eventStore.save(reminder, commit: true)
            return "Successfully added \(arguments.ingredients.count) ingredients to your shopping list reminder."
        } catch {
            return "Failed to create reminder: \(error.localizedDescription)"
        }
    }
}

