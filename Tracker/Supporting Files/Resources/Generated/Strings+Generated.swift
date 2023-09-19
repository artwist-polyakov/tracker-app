// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return prefer_self_in_static_references

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
internal enum L10n {
  /// Cancel
  internal static let cancel = L10n.tr("Localizable", "cancel", fallback: "Cancel")
  /// Create
  internal static let create = L10n.tr("Localizable", "create", fallback: "Create")
  /// Plural format key: "%#@days@"
  internal static func daysStrike(_ p1: Int) -> String {
    return L10n.tr("Localizable", "daysStrike", p1, fallback: "Plural format key: \"%#@days@\"")
  }
  /// Delete
  internal static let delete = L10n.tr("Localizable", "delete", fallback: "Delete")
  /// Edit
  internal static let edit = L10n.tr("Localizable", "edit", fallback: "Edit")
  /// Filter
  internal static let filter = L10n.tr("Localizable", "filter", fallback: "Filter")
  /// Friday
  internal static let friday = L10n.tr("Localizable", "friday", fallback: "Friday")
  /// Monday
  internal static let monday = L10n.tr("Localizable", "monday", fallback: "Monday")
  /// Pin
  internal static let pin = L10n.tr("Localizable", "pin", fallback: "Pin")
  /// Pinned
  internal static let pinned = L10n.tr("Localizable", "pinned", fallback: "Pinned")
  /// Ready
  internal static let ready = L10n.tr("Localizable", "ready", fallback: "Ready")
  /// Saturday
  internal static let saturday = L10n.tr("Localizable", "saturday", fallback: "Saturday")
  /// Save
  internal static let save = L10n.tr("Localizable", "save", fallback: "Save")
  /// Search
  internal static let search = L10n.tr("Localizable", "search", fallback: "Search")
  /// Sorry!
  internal static let sorry = L10n.tr("Localizable", "sorry", fallback: "Sorry!")
  /// Statistics
  internal static let stats = L10n.tr("Localizable", "stats", fallback: "Statistics")
  /// Sunday
  internal static let sunday = L10n.tr("Localizable", "sunday", fallback: "Sunday")
  /// Thursday
  internal static let thursday = L10n.tr("Localizable", "thursday", fallback: "Thursday")
  /// Trackers
  internal static let trackers = L10n.tr("Localizable", "trackers", fallback: "Trackers")
  /// Tuesday
  internal static let tuesday = L10n.tr("Localizable", "tuesday", fallback: "Tuesday")
  /// Unpin
  internal static let unpin = L10n.tr("Localizable", "unpin", fallback: "Unpin")
  /// Wednesday
  internal static let wednesday = L10n.tr("Localizable", "wednesday", fallback: "Wednesday")
  internal enum Clear {
    /// Clear data
    internal static let data = L10n.tr("Localizable", "clear.data", fallback: "Clear data")
    internal enum Data {
      /// Are you sure you want to clear all data?
      internal static let agreement = L10n.tr("Localizable", "clear.data.agreement", fallback: "Are you sure you want to clear all data?")
    }
  }
  internal enum Delete {
    /// Are you sure you want to delete the tracker?
    internal static let confirmation = L10n.tr("Localizable", "delete.confirmation", fallback: "Are you sure you want to delete the tracker?")
    /// Deleting
    internal static let this = L10n.tr("Localizable", "delete.this", fallback: "Deleting")
  }
  internal enum Dont {
    /// Don't lie!
    internal static let lie = L10n.tr("Localizable", "dont.lie", fallback: "Don't lie!")
    internal enum Lie {
      /// You can't mark a future tracker as completed
      internal static let message = L10n.tr("Localizable", "dont.lie.message", fallback: "You can't mark a future tracker as completed")
    }
  }
  internal enum EmptyState {
    /// What will we track?
    internal static let title = L10n.tr("Localizable", "emptyState.title", fallback: "What will we track?")
  }
  internal enum Every {
    /// Every day
    internal static let day = L10n.tr("Localizable", "every.day", fallback: "Every day")
  }
  internal enum Filter {
    /// All trackers
    internal static let allTrackers = L10n.tr("Localizable", "filter.allTrackers", fallback: "All trackers")
    /// Completed
    internal static let completed = L10n.tr("Localizable", "filter.completed", fallback: "Completed")
    /// Today trackers
    internal static let todayTrackers = L10n.tr("Localizable", "filter.todayTrackers", fallback: "Today trackers")
    /// Uncompleted
    internal static let uncompleted = L10n.tr("Localizable", "filter.uncompleted", fallback: "Uncompleted")
  }
  internal enum Friday {
    /// Fri
    internal static let short = L10n.tr("Localizable", "friday.short", fallback: "Fri")
  }
  internal enum Habit {
    /// Habit editing
    internal static let editing = L10n.tr("Localizable", "habit.editing", fallback: "Habit editing")
  }
  internal enum Monday {
    /// Mon
    internal static let short = L10n.tr("Localizable", "monday.short", fallback: "Mon")
  }
  internal enum Nothing {
    /// Nothing found
    internal static let found = L10n.tr("Localizable", "nothing.found", fallback: "Nothing found")
  }
  internal enum Onboarding {
    /// That's technology!
    internal static let button = L10n.tr("Localizable", "onboarding.button", fallback: "That's technology!")
    internal enum Title {
      /// Track only what you want
      internal static let first = L10n.tr("Localizable", "onboarding.title.first", fallback: "Track only what you want")
      /// Even if it's not liters of water and yoga
      internal static let second = L10n.tr("Localizable", "onboarding.title.second", fallback: "Even if it's not liters of water and yoga")
    }
  }
  internal enum Saturday {
    /// Sat
    internal static let short = L10n.tr("Localizable", "saturday.short", fallback: "Sat")
  }
  internal enum Stats {
    /// Completed trackers
    internal static let completedTrackers = L10n.tr("Localizable", "stats.completedTrackers", fallback: "Completed trackers")
    /// Here is nothing to analize
    internal static let nothingShow = L10n.tr("Localizable", "stats.nothingShow", fallback: "Here is nothing to analize")
  }
  internal enum Sunday {
    /// Sun
    internal static let short = L10n.tr("Localizable", "sunday.short", fallback: "Sun")
  }
  internal enum Thursday {
    /// Thu
    internal static let short = L10n.tr("Localizable", "thursday.short", fallback: "Thu")
  }
  internal enum Trackers {
    /// Category
    internal static let category = L10n.tr("Localizable", "trackers.category", fallback: "Category")
    /// Schedule
    internal static let shedule = L10n.tr("Localizable", "trackers.shedule", fallback: "Schedule")
    /// Creating a tracker
    internal static let title = L10n.tr("Localizable", "trackers.title", fallback: "Creating a tracker")
    internal enum Category {
      /// Add category
      internal static let addButton = L10n.tr("Localizable", "trackers.category.addButton", fallback: "Add category")
      /// Edit category
      internal static let editCategory = L10n.tr("Localizable", "trackers.category.editCategory", fallback: "Edit category")
      /// Habits and events can be
      /// combined by meaning
      internal static let emptyState = L10n.tr("Localizable", "trackers.category.emptyState", fallback: "Habits and events can be\ncombined by meaning")
      /// Enter category name
      internal static let enterName = L10n.tr("Localizable", "trackers.category.enterName", fallback: "Enter category name")
      /// Habit
      internal static let habit = L10n.tr("Localizable", "trackers.category.habit", fallback: "Habit")
      /// Irregular event
      internal static let irregular = L10n.tr("Localizable", "trackers.category.irregular", fallback: "Irregular event")
      /// New category
      internal static let newCategory = L10n.tr("Localizable", "trackers.category.newCategory", fallback: "New category")
      /// New habit
      internal static let newHabit = L10n.tr("Localizable", "trackers.category.newHabit", fallback: "New habit")
      /// New irregular event
      internal static let newIrregular = L10n.tr("Localizable", "trackers.category.newIrregular", fallback: "New irregular event")
      /// Unknown label
      internal static let newUnknown = L10n.tr("Localizable", "trackers.category.newUnknown", fallback: "Unknown label")
      /// 27 characters limit
      internal static let warning = L10n.tr("Localizable", "trackers.category.warning", fallback: "27 characters limit")
    }
    internal enum Create {
      /// Choose a category
      internal static let chooseCategory = L10n.tr("Localizable", "trackers.create.chooseCategory", fallback: "Choose a category")
      /// Category
      internal static let choosenCategory = L10n.tr("Localizable", "trackers.create.choosenCategory", fallback: "Category")
      /// Schedule
      internal static let choosenShedule = L10n.tr("Localizable", "trackers.create.choosenShedule", fallback: "Schedule")
      /// Create a schedule
      internal static let chooseShedule = L10n.tr("Localizable", "trackers.create.chooseShedule", fallback: "Create a schedule")
      /// Color
      internal static let colors = L10n.tr("Localizable", "trackers.create.colors", fallback: "Color")
      /// Emoji
      internal static let emoji = L10n.tr("Localizable", "trackers.create.emoji", fallback: "Emoji")
      /// Tracker name
      internal static let inputName = L10n.tr("Localizable", "trackers.create.inputName", fallback: "Tracker name")
      /// Enter tracker name
      internal static let inputPlaceholder = L10n.tr("Localizable", "trackers.create.inputPlaceholder", fallback: "Enter tracker name")
    }
    internal enum Search {
      /// 38 characters limit
      internal static let warning = L10n.tr("Localizable", "trackers.search.warning", fallback: "38 characters limit")
    }
  }
  internal enum Tuesday {
    /// Tue
    internal static let short = L10n.tr("Localizable", "tuesday.short", fallback: "Tue")
  }
  internal enum Wednesday {
    /// Wed
    internal static let short = L10n.tr("Localizable", "wednesday.short", fallback: "Wed")
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg..., fallback value: String) -> String {
    let format = BundleToken.bundle.localizedString(forKey: key, value: value, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
