//
//  JournalView.swift
//  ResetNow
//
//  Lightweight journaling with gentle prompts
//

import SwiftUI

struct JournalView: View {
    @State private var showNewEntry = false
    @State private var journalEntries: [JournalEntryData] = []
    @State private var selectedPrompt: String?
    
    struct JournalEntryData: Identifiable {
        let id = UUID()
        let date: Date
        let prompt: String?
        let text: String
        let moodTag: String?
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: ResetSpacing.lg) {
                // Header
                headerSection
                
                // Quick journal button
                quickJournalButton
                
                // Prompts section
                promptsSection
                
                // Recent entries
                recentEntriesSection
            }
            .padding(.horizontal, ResetSpacing.md)
            .padding(.bottom, ResetSpacing.xxl)
        }
        .background(backgroundGradient.ignoresSafeArea())
        .navigationTitle("Journal")
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $showNewEntry) {
            JournalEntryEditor(prompt: selectedPrompt) { entry in
                journalEntries.insert(entry, at: 0)
            }
        }
        .onAppear {
            loadEntries()
        }
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: ResetSpacing.sm) {
            Text("Express yourself freely")
                .font(ResetTypography.body(16))
                .foregroundColor(.secondary)
            
            Text("Writing helps process emotions and clear your mind.")
                .font(ResetTypography.body(14))
                .foregroundColor(.warmGray.opacity(0.8))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, ResetSpacing.sm)
    }
    
    private var quickJournalButton: some View {
        Button(action: {
            selectedPrompt = nil
            showNewEntry = true
        }) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Quick Journal")
                        .font(ResetTypography.heading(16))
                        .foregroundColor(.primary)
                    
                    Text("Free write whatever's on your mind")
                        .font(ResetTypography.caption(13))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "pencil.circle.fill")
                    .font(.system(size: 36))
                    .foregroundColor(.journalColor)
            }
            .padding(ResetSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color(.secondarySystemGroupedBackground))
                    .resetShadow(radius: 8, opacity: 0.08)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(Color.journalColor.opacity(0.3), lineWidth: 1)
            )
        }
    }
    
    private var promptsSection: some View {
        VStack(alignment: .leading, spacing: ResetSpacing.md) {
            Text("Writing Prompts")
                .font(ResetTypography.heading(18))
                .foregroundColor(.primary)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: ResetSpacing.md) {
                    ForEach(JournalEntry.prompts.prefix(5), id: \.self) { prompt in
                        PromptCard(prompt: prompt) {
                            selectedPrompt = prompt
                            showNewEntry = true
                        }
                    }
                }
            }
        }
    }
    
    private var recentEntriesSection: some View {
        VStack(alignment: .leading, spacing: ResetSpacing.md) {
            Text("Recent Entries")
                .font(ResetTypography.heading(18))
                .foregroundColor(.primary)
            
            if journalEntries.isEmpty {
                EmptyJournalView()
            } else {
                ForEach(journalEntries) { entry in
                    JournalEntryRow(entry: entry)
                }
            }
        }
    }
    
    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                Color.creamWhite,
                Color.journalColor.opacity(0.1)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    private func loadEntries() {
        let persistence = PersistenceController.shared
        let cdEntries = persistence.getJournalEntries()
        journalEntries = cdEntries.map { entry in
            JournalEntryData(
                date: entry.createdAt,
                prompt: entry.promptText,
                text: entry.entryText,
                moodTag: entry.moodTag
            )
        }
    }
}

// MARK: - Prompt Card
struct PromptCard: View {
    let prompt: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: ResetSpacing.sm) {
                Image(systemName: "quote.opening")
                    .font(.system(size: 16))
                    .foregroundColor(.journalColor)
                
                Text(prompt)
                    .font(ResetTypography.body(14))
                    .foregroundColor(.primary)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                Text("Tap to write")
                    .font(ResetTypography.caption(11))
                    .foregroundColor(.journalColor)
            }
            .frame(width: 160, height: 130, alignment: .topLeading)
            .padding(ResetSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.journalColor.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.journalColor.opacity(0.2), lineWidth: 1)
                    )
            )
        }
    }
}

// MARK: - Journal Entry Row
struct JournalEntryRow: View {
    let entry: JournalView.JournalEntryData
    
    var body: some View {
        VStack(alignment: .leading, spacing: ResetSpacing.sm) {
            HStack {
                Text(entry.date.formatted(date: .abbreviated, time: .shortened))
                    .font(ResetTypography.caption(12))
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if let mood = entry.moodTag {
                    Text(mood)
                        .font(ResetTypography.caption(11))
                        .foregroundColor(.journalColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(
                            Capsule()
                                .fill(Color.journalColor.opacity(0.15))
                        )
                }
            }
            
            if let prompt = entry.prompt {
                Text(prompt)
                    .font(ResetTypography.caption(12))
                    .foregroundColor(.journalColor)
                    .italic()
            }
            
            Text(entry.text)
                .font(ResetTypography.body(14))
                .foregroundColor(.primary)
                .lineLimit(3)
        }
        .padding(ResetSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(.secondarySystemGroupedBackground))
                .resetShadow(radius: 4, opacity: 0.04)
        )
    }
}

// MARK: - Empty Journal View
struct EmptyJournalView: View {
    var body: some View {
        VStack(spacing: ResetSpacing.md) {
            Image(systemName: "book.closed")
                .font(.system(size: 40))
                .foregroundColor(.warmGray.opacity(0.5))
            
            Text("Your journal is empty")
                .font(ResetTypography.body(16))
                .foregroundColor(.secondary)
            
            Text("Start writing to express your thoughts")
                .font(ResetTypography.caption(13))
                .foregroundColor(.warmGray.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, ResetSpacing.xxl)
    }
}

// MARK: - Journal Entry Editor
struct JournalEntryEditor: View {
    let prompt: String?
    let onSave: (JournalView.JournalEntryData) -> Void
    
    @Environment(\.dismiss) var dismiss
    @State private var entryText = ""
    @State private var selectedMood: String?
    @FocusState private var isFocused: Bool
    
    let moods = ["😌 Calm", "😊 Hopeful", "😔 Sad", "😰 Anxious", "😠 Frustrated", "😴 Tired"]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: ResetSpacing.lg) {
                    // Prompt if provided
                    if let prompt = prompt {
                        VStack(alignment: .leading, spacing: ResetSpacing.sm) {
                            Text("Prompt")
                                .font(ResetTypography.caption(12))
                                .foregroundColor(.secondary)
                            
                            Text(prompt)
                                .font(ResetTypography.body(16))
                                .foregroundColor(.journalColor)
                                .italic()
                        }
                        .padding(ResetSpacing.md)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.journalColor.opacity(0.1))
                        )
                    }
                    
                    // Text editor
                    VStack(alignment: .leading, spacing: ResetSpacing.sm) {
                        Text("Your thoughts")
                            .font(ResetTypography.caption(12))
                            .foregroundColor(.secondary)
                        
                        TextEditor(text: $entryText)
                            .font(ResetTypography.body(16))
                            .frame(minHeight: 200)
                            .padding(ResetSpacing.sm)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Color.warmGray.opacity(0.2), lineWidth: 1)
                            )
                            .focused($isFocused)
                    }
                    
                    // Mood selector
                    VStack(alignment: .leading, spacing: ResetSpacing.sm) {
                        Text("How are you feeling?")
                            .font(ResetTypography.caption(12))
                            .foregroundColor(.secondary)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: ResetSpacing.sm) {
                                ForEach(moods, id: \.self) { mood in
                                    MoodChip(
                                        mood: mood,
                                        isSelected: selectedMood == mood
                                    ) {
                                        selectedMood = mood
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, ResetSpacing.md)
                .padding(.top, ResetSpacing.md)
            }
            .background(Color(.systemBackground).ignoresSafeArea())
            .navigationTitle("New Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.secondary)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        saveEntry()
                    }
                    .foregroundColor(.calmSage)
                    .fontWeight(.semibold)
                    .disabled(entryText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .onAppear {
                isFocused = true
            }
        }
    }
    
    private func saveEntry() {
        let persistence = PersistenceController.shared
        persistence.createJournalEntry(
            prompt: prompt,
            text: entryText,
            moodTag: selectedMood
        )
        
        let entry = JournalView.JournalEntryData(
            date: Date(),
            prompt: prompt,
            text: entryText,
            moodTag: selectedMood
        )
        onSave(entry)
        dismiss()
    }
}

// MARK: - Mood Chip
struct MoodChip: View {
    let mood: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(mood)
                .font(ResetTypography.caption(13))
                .foregroundColor(isSelected ? .white : .deepSlate)
                .padding(.horizontal, ResetSpacing.md)
                .padding(.vertical, ResetSpacing.sm)
                .background(
                    Capsule()
                        .fill(isSelected ? Color.journalColor : Color.white)
                        .overlay(
                            Capsule()
                                .stroke(Color.journalColor.opacity(0.3), lineWidth: 1)
                        )
                )
        }
    }
}

// MARK: - Preview
struct JournalView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            JournalView()
        }
    }
}

