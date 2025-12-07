//
//  CoreDataModels.swift
//  ResetNow
//
//  Core Data NSManagedObject subclasses
//

import Foundation
import CoreData

// MARK: - User Entity
@objc(CDUser)
public class CDUser: NSManagedObject {
    @NSManaged public var id: UUID?
    @NSManaged public var createdAt: Date?
    @NSManaged public var timezone: String?
    @NSManaged public var preferredReminderTime: Date?
    @NSManaged public var dailyAffirmationEnabled: Bool
    @NSManaged public var resetsReminderEnabled: Bool
    @NSManaged public var acceptedDisclaimerAt: Date?
    
    // Relationships
    @NSManaged public var sessions: NSSet?
    @NSManaged public var journalEntries: NSSet?
    @NSManaged public var moodCheckins: NSSet?
    @NSManaged public var chatSessions: NSSet?
    @NSManaged public var affirmationFavorites: NSSet?
}

extension CDUser {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDUser> {
        return NSFetchRequest<CDUser>(entityName: "CDUser")
    }
}

// MARK: - Session Entity
@objc(CDSession)
public class CDSession: NSManagedObject {
    @NSManaged public var id: UUID?
    @NSManaged public var startedAt: Date?
    @NSManaged public var endedAt: Date?
    @NSManaged public var sourceToolId: String?
    @NSManaged public var subtypeId: UUID?
    @NSManaged public var sessionType: String?
    @NSManaged public var notes: String?
    
    // Relationships
    @NSManaged public var user: CDUser?
    @NSManaged public var moodCheckins: NSSet?
}

extension CDSession {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDSession> {
        return NSFetchRequest<CDSession>(entityName: "CDSession")
    }
}

// MARK: - Mood Check-in Entity
@objc(CDMoodCheckin)
public class CDMoodCheckin: NSManagedObject {
    @NSManaged public var id: UUID?
    @NSManaged public var createdAt: Date?
    @NSManaged public var moodType: String?
    @NSManaged public var valueBefore: Int16
    @NSManaged public var valueAfter: Int16
    
    // Relationships
    @NSManaged public var session: CDSession?
    @NSManaged public var user: CDUser?
}

extension CDMoodCheckin {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDMoodCheckin> {
        return NSFetchRequest<CDMoodCheckin>(entityName: "CDMoodCheckin")
    }
}

// MARK: - Journal Entry Entity
@objc(CDJournalEntry)
public class CDJournalEntry: NSManagedObject {
    @NSManaged public var id: UUID?
    @NSManaged public var createdAt: Date?
    @NSManaged public var promptText: String?
    @NSManaged public var entryText: String?
    @NSManaged public var moodTag: String?
    
    // Relationships
    @NSManaged public var user: CDUser?
}

extension CDJournalEntry {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDJournalEntry> {
        return NSFetchRequest<CDJournalEntry>(entityName: "CDJournalEntry")
    }
}

// MARK: - Affirmation Favorite Entity
@objc(CDAffirmationFavorite)
public class CDAffirmationFavorite: NSManagedObject {
    @NSManaged public var id: UUID?
    @NSManaged public var affirmationId: UUID?
    @NSManaged public var createdAt: Date?
    
    // Relationships
    @NSManaged public var user: CDUser?
}

extension CDAffirmationFavorite {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDAffirmationFavorite> {
        return NSFetchRequest<CDAffirmationFavorite>(entityName: "CDAffirmationFavorite")
    }
}

// MARK: - Chat Session Entity
@objc(CDChatSession)
public class CDChatSession: NSManagedObject {
    @NSManaged public var id: UUID?
    @NSManaged public var startedAt: Date?
    @NSManaged public var endedAt: Date?
    @NSManaged public var isCrisisFlagged: Bool
    @NSManaged public var crisisFlagReason: String?
    
    // Relationships
    @NSManaged public var user: CDUser?
    @NSManaged public var messages: NSSet?
}

extension CDChatSession {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDChatSession> {
        return NSFetchRequest<CDChatSession>(entityName: "CDChatSession")
    }
    
    public var orderedMessages: [CDChatMessage] {
        let set = messages as? Set<CDChatMessage> ?? []
        return set.sorted { ($0.createdAt ?? Date.distantPast) < ($1.createdAt ?? Date.distantPast) }
    }
}

// MARK: - Chat Message Entity
@objc(CDChatMessage)
public class CDChatMessage: NSManagedObject {
    @NSManaged public var id: UUID?
    @NSManaged public var createdAt: Date?
    @NSManaged public var sender: String?
    @NSManaged public var text: String?
    @NSManaged public var safetyFlag: String?
    
    // Relationships
    @NSManaged public var chatSession: CDChatSession?
}

extension CDChatMessage {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDChatMessage> {
        return NSFetchRequest<CDChatMessage>(entityName: "CDChatMessage")
    }
}

// MARK: - Journey Progress Entity
@objc(CDJourneyProgress)
public class CDJourneyProgress: NSManagedObject {
    @NSManaged public var id: UUID?
    @NSManaged public var journeyId: UUID?
    @NSManaged public var currentStepIndex: Int16
    @NSManaged public var startedAt: Date?
    @NSManaged public var completedAt: Date?
    
    // Relationships
    @NSManaged public var user: CDUser?
}

extension CDJourneyProgress {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDJourneyProgress> {
        return NSFetchRequest<CDJourneyProgress>(entityName: "CDJourneyProgress")
    }
}

// MARK: - Lesson Progress Entity
@objc(CDLessonProgress)
public class CDLessonProgress: NSManagedObject {
    @NSManaged public var id: UUID?
    @NSManaged public var lessonId: UUID?
    @NSManaged public var completedAt: Date?
    
    // Relationships
    @NSManaged public var user: CDUser?
}

extension CDLessonProgress {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDLessonProgress> {
        return NSFetchRequest<CDLessonProgress>(entityName: "CDLessonProgress")
    }
}

// MARK: - Daily Affirmation Log Entity
@objc(CDDailyAffirmationLog)
public class CDDailyAffirmationLog: NSManagedObject {
    @NSManaged public var id: UUID?
    @NSManaged public var affirmationId: UUID?
    @NSManaged public var shownDate: Date?
    
    // Relationships
    @NSManaged public var user: CDUser?
}

extension CDDailyAffirmationLog {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDDailyAffirmationLog> {
        return NSFetchRequest<CDDailyAffirmationLog>(entityName: "CDDailyAffirmationLog")
    }
}

