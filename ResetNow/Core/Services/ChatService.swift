//
//  ChatService.swift
//  ResetNow
//
//  AI Chat service protocol and mock implementation
//

import Foundation

// MARK: - Chat Service Protocol
protocol ChatService {
    /// Send a message and receive a response
    /// - Parameters:
    ///   - message: The user's message
    ///   - history: Previous messages in the conversation for context
    /// - Returns: Rae's response message
    func send(message: String, history: [ChatMessage]) async throws -> ChatMessage
}

// MARK: - Chat Response
struct ChatResponse {
    let text: String
    let safetyFlag: String?
    let suggestedTool: ResetToolKind?
}

// MARK: - Mock Chat Service
/// Mock implementation that returns supportive canned responses
/// TODO: Replace with real LLM API integration in future version
/// DO NOT hard-code any API keys or external endpoints
final class MockChatService: ChatService {
    
    // Crisis keywords that trigger safety response
    // CRITICAL: This list must be comprehensive - lives depend on it
    private let crisisKeywords = [
        // Direct self-harm/suicide - explicit
        "kill myself", "suicide", "suicidal", "end my life", "want to die",
        "hurt myself", "self harm", "self-harm", "cutting", "overdose",
        "hang myself", "don't want to live", "no reason to live",
        "better off dead", "can't go on", "end it all", "kill me",
        "take my life", "ending it", "give up on life", "asleep forever",
        "pain stop", "way out", "goodbye forever", "never wake up",
        
        // Cutting/self-injury variations - CRITICAL
        "cut myself", "cut my wrist", "cut my arm", "cut my leg", "cut my skin",
        "cut me", "cutting myself", "slit my wrist", "slit my", "slice my",
        "scratch myself", "burn myself", "burning myself", "hurting myself",
        "harm myself", "harming myself", "injure myself", "injuring myself",
        
        // Coded/slang terms users actually use
        "unalive", "unaliving", "kms", "kys", "ctb", "catch the bus",
        "final exit", "peaceful pill", "end myself", "off myself",
        "do it tonight", "won't be here tomorrow", "last day",
        "say goodbye", "writing notes", "goodbye letter", "final letter",
        
        // Specific methods/locations (High Risk) - Use phrases to avoid false positives
        "jump off a", "jump off the", "jump out the", "jump from", "jumping off",
        "off a bridge", "off the bridge", "off a building", "off the roof",
        "take pills", "take all my pills", "swallow pills", "overdose on",
        "use a gun", "shoot myself", "get a gun",
        "use a knife", "with a knife", "stab myself",
        "drink bleach", "drink poison", "poison myself",
        "step into traffic", "walk into traffic", "in front of a train",
        "tie a noose", "hang myself", "with a rope",
        "drown myself", "drown in",
        
        // Severe distress/hopelessness
        "hopeless", "worthless", "nobody cares", "burden", "i'm a burden",
        "everyone better off", "better off without me", "no point", "give up", "can't take it",
        "make it stop", "want it to end", "don't want to be here",
        "can't do this anymore", "can't live like this", "tired of living",
        "no way out", "trapped", "no escape", "suffering too much",
        "no one would care", "no one would miss me", "disappear forever",
        "want to disappear", "wish i was dead", "wish i wasn't born",
        "shouldn't be alive", "don't deserve to live", "hate being alive"
    ]
    
    func send(message: String, history: [ChatMessage]) async throws -> ChatMessage {
        // Simulate network delay
        try await Task.sleep(nanoseconds: UInt64.random(in: 800_000_000...1_500_000_000))
        
        let lowercased = message.lowercased()
        
        // Check for crisis keywords first - SAFETY PRIORITY
        if containsCrisisKeywords(lowercased) {
            return createCrisisResponse(chatSessionId: history.first?.chatSessionId ?? UUID())
        }
        
        // Generate supportive response based on content
        let response = generateResponse(for: lowercased, history: history)
        
        return ChatMessage(
            id: UUID(),
            chatSessionId: history.first?.chatSessionId ?? UUID(),
            sender: .rae,
            createdAt: Date(),
            text: response.text,
            safetyFlag: response.safetyFlag,
            suggestedTool: response.suggestedTool
        )
    }
    
    private func containsCrisisKeywords(_ message: String) -> Bool {
        crisisKeywords.contains { message.contains($0) }
    }
    
    private func createCrisisResponse(chatSessionId: UUID) -> ChatMessage {
        let crisisText = """
        I hear that you're going through something really difficult right now, and I want you to know that what you're feeling matters.
        
        I'm not able to provide the kind of support you need in this moment, but there are people trained to help who are available right now.
        
        Please reach out to:
        • 988 Suicide & Crisis Lifeline (call or text 988)
        • Crisis Text Line (text HOME to 741741)
        • Your local emergency services (911)
        
        You deserve support from people who can truly help. You're not alone in this. 💚
        
        If you're in immediate danger, please call emergency services right away.
        """
        
        return ChatMessage(
            id: UUID(),
            chatSessionId: chatSessionId,
            sender: .rae,
            createdAt: Date(),
            text: crisisText,
            safetyFlag: "crisis_detected"
        )
    }
    
    private func generateResponse(for message: String, history: [ChatMessage]) -> ChatResponse {
        var candidateResponse: ChatResponse
        var attempts = 0
        
        // 1. Get recent Rae messages to avoid repetition
        let recentRaeMessages = history.filter { $0.sender == .rae }.suffix(3).map { $0.text }
        
        repeat {
            candidateResponse = generateCandidateResponse(for: message, history: history)
            attempts += 1
        } while (recentRaeMessages.contains(candidateResponse.text) && attempts < 5)
        
        return candidateResponse
    }
    
    private func generateCandidateResponse(for message: String, history: [ChatMessage]) -> ChatResponse {
        
        // --- PRIORITY 1: MAJOR LIFE EVENTS & SAFETY (Check these first!) ---
        
        // Job Loss / Fired - MAJOR LIFE EVENT
        if message.contains("fired") || message.contains("laid off") || message.contains("lost my job") || message.contains("lost my work") || message.contains("let go") || message.contains("unemployed") || message.contains("got sacked") || message.contains("made redundant") || message.contains("losing my job") || message.contains("job ended") {
            let responses = [
                ChatResponse(
                    text: "I'm so sorry to hear that. Losing a job is a profound moment—it can shake your sense of security, identity, and routine all at once. Whatever you're feeling right now—fear, anger, sadness, or even numbness—is completely valid. How are you holding up?",
                    safetyFlag: nil,
                    suggestedTool: nil
                ),
                ChatResponse(
                    text: "That's really difficult news. I want you to know that your worth as a person has absolutely nothing to do with your employment status. This is a hard chapter, but it doesn't define who you are. What's weighing on you the most right now?",
                    safetyFlag: nil,
                    suggestedTool: nil
                ),
                ChatResponse(
                    text: "I'm so sorry you're going through this. Job loss is one of life's most stressful experiences, and it's okay to feel however you're feeling—scared, angry, relieved, confused, or all of the above. You don't have to have it figured out today. Is there someone you can lean on during this time?",
                    safetyFlag: nil,
                    suggestedTool: nil
                ),
                ChatResponse(
                    text: "That must be incredibly hard. Losing your job can bring up so many emotions and worries at once. I want you to know that this moment doesn't define your future. Right now, just take a breath. What do you need most in this moment—to talk, to vent, or just to be heard?",
                    safetyFlag: nil,
                    suggestedTool: nil
                ),
                ChatResponse(
                    text: "I'm really sorry. That's such a heavy thing to carry. Job loss can feel like the ground shifting beneath you, and it's okay to feel unsteady right now. Be gentle with yourself—you're dealing with a lot. How can I support you right now?",
                    safetyFlag: nil,
                    suggestedTool: nil
                )
            ]
            return responses.randomElement()!
        }
        
        // Breakup/Divorce
        if message.contains("broke up") || message.contains("breakup") || message.contains("break up") || message.contains("divorce") || message.contains("left me") || message.contains("dumped") || message.contains("ended things") || message.contains("relationship ended") {
            let responses = [
                ChatResponse(
                    text: "I'm really sorry. Breakups are painful, and it's okay to feel whatever you're feeling right now—sadness, anger, confusion, all of it. How are you doing?",
                    safetyFlag: nil,
                    suggestedTool: nil
                ),
                ChatResponse(
                    text: "That's heartbreaking. Losing someone you cared about is a real loss, and you're allowed to grieve. Take your time. Is there anything you need right now?",
                    safetyFlag: nil,
                    suggestedTool: nil
                ),
                ChatResponse(
                    text: "I'm so sorry you're going through this. The end of a relationship can shake everything. Whatever you're feeling is valid. Do you want to talk about it?",
                    safetyFlag: nil,
                    suggestedTool: nil
                )
            ]
            return responses.randomElement()!
        }
        
        // Grief/Death
        if message.contains("died") || message.contains("passed away") || message.contains("death") || message.contains("funeral") || message.contains("grieving") || message.contains("miss them") || message.contains("lost my mom") || message.contains("lost my dad") || message.contains("lost my mother") || message.contains("lost my father") || message.contains("lost my brother") || message.contains("lost my sister") || message.contains("lost my wife") || message.contains("lost my husband") || message.contains("lost my friend") || message.contains("lost my baby") || message.contains("lost my child") || message.contains("lost my son") || message.contains("lost my daughter") || message.contains("lost my pet") || message.contains("lost my dog") || message.contains("lost my cat") || message.contains("someone died") || message.contains("they died") || message.contains("he died") || message.contains("she died") {
            let responses = [
                ChatResponse(
                    text: "I'm so sorry for your loss. Grief is one of the hardest things to carry. There's no right way to feel right now. I'm here if you want to talk, or just sit with this.",
                    safetyFlag: nil,
                    suggestedTool: nil
                ),
                ChatResponse(
                    text: "I'm truly sorry. Losing someone is devastating. Please be gentle with yourself. Would you like to tell me about them, or is there something else you need?",
                    safetyFlag: nil,
                    suggestedTool: nil
                )
            ]
            return responses.randomElement()!
        }
        
        // Trauma/Abuse
        if message.contains("abuse") || message.contains("abused") || message.contains("assault") || message.contains("attacked") || message.contains("violence") || message.contains("hit me") || message.contains("hurt me") {
            let responses = [
                ChatResponse(
                    text: "I believe you, and I'm so sorry this happened. What you experienced is serious, and your feelings are valid. You didn't deserve this. Are you safe right now?",
                    safetyFlag: "sensitive_topic",
                    suggestedTool: nil
                ),
                ChatResponse(
                    text: "Thank you for trusting me with this. That took courage. What happened to you was not okay, and it wasn't your fault. Is there support around you—someone you trust or a professional you can talk to?",
                    safetyFlag: "sensitive_topic",
                    suggestedTool: nil
                )
            ]
            return responses.randomElement()!
        }
        
        // Betrayal/Trust
        if message.contains("cheated") || message.contains("betrayed") || message.contains("lied to me") || message.contains("backstab") || message.contains("trust") || message.contains("deceived") {
            let responses = [
                ChatResponse(
                    text: "Being betrayed by someone you trusted is devastating. Your hurt is completely valid. That kind of pain takes time to process. How are you feeling right now?",
                    safetyFlag: nil,
                    suggestedTool: nil
                ),
                ChatResponse(
                    text: "I'm so sorry. When someone breaks your trust, it shakes everything. You have every right to feel angry, hurt, confused—all of it. I'm here to listen.",
                    safetyFlag: nil,
                    suggestedTool: nil
                )
            ]
            return responses.randomElement()!
        }

        // --- PRIORITY 2: CONTEXT-AWARE FOLLOW-UP ---
        
        if let lastRaeMsg = history.last(where: { $0.sender == .rae }) {
            let lastRaeText = lastRaeMsg.text.lowercased()
            
            // If Rae asked "how long" and user gives a time answer
            if lastRaeText.contains("how long") {
                if message.contains("yesterday") || message.contains("today") || message.contains("week") || message.contains("month") || message.contains("year") || message.contains("days") || message.contains("hours") || message.contains("while") || message.contains("long time") || message.contains("recently") || message.contains("since") || message.contains("few") || message.contains("couple") {
                    let timeResponses = [
                        ChatResponse(text: "Thank you for sharing that. Carrying something for even a short time can feel heavy. What's been the hardest part for you?", safetyFlag: nil, suggestedTool: nil),
                        ChatResponse(text: "I appreciate you telling me. That's been weighing on you. How has it been affecting your day-to-day—your sleep, your energy, your mood?", safetyFlag: nil, suggestedTool: nil),
                        ChatResponse(text: "Okay. Sometimes just naming how long we've been struggling helps us see it more clearly. What feels most difficult right now?", safetyFlag: nil, suggestedTool: nil),
                        ChatResponse(text: "I hear you. Let's slow down together for a moment. Place your hand on your chest if it feels right. What do you notice in your body?", safetyFlag: nil, suggestedTool: .breathe),
                        ChatResponse(text: "That's helpful to know. It sounds like you've been carrying this. Would it help to talk more, or would you like to try something grounding?", safetyFlag: nil, suggestedTool: nil)
                    ]
                    return timeResponses.randomElement()!
                }
            }
            
            // If Rae asked a yes/no question
            if lastRaeText.contains("would you like") || lastRaeText.contains("do you want") || lastRaeText.contains("would it help") || lastRaeText.contains("want to try") {
                if message == "yes" || message == "yeah" || message == "sure" || message == "ok" || message == "okay" || message.contains("please") || message == "yea" || message == "yep" {
                    let yesResponses = [
                        ChatResponse(text: "Okay, let's do this together. Place one hand on your chest. Breathe in slowly through your nose... and out through your mouth. How does that feel?", safetyFlag: nil, suggestedTool: .breathe),
                        ChatResponse(text: "I'm glad you're open to that. Let's take three slow breaths together. In... and out. Notice your feet on the ground. You're safe here.", safetyFlag: nil, suggestedTool: .breathe),
                        ChatResponse(text: "Great. Let's start simple—notice five things you can see around you right now. Just name them in your head. This can help bring you back to the present.", safetyFlag: nil, suggestedTool: .visualize)
                    ]
                    return yesResponses.randomElement()!
                }
                if message == "no" || message == "nah" || message == "not really" || message.contains("don't want") || message.contains("not now") || message == "nope" || message.contains("maybe later") {
                    let noResponses = [
                        ChatResponse(text: "That's completely okay. There's no pressure here. What would feel right for you instead? I'm happy to just listen.", safetyFlag: nil, suggestedTool: nil),
                        ChatResponse(text: "No problem. We can just talk, or sit quietly together. What feels best right now?", safetyFlag: nil, suggestedTool: nil),
                        ChatResponse(text: "Understood. You know yourself best. Is there something else on your mind you'd like to share?", safetyFlag: nil, suggestedTool: nil)
                    ]
                    return noResponses.randomElement()!
                }
            }
            
            // If Rae asked about feelings/what's going on
            if lastRaeText.contains("what's going on") || lastRaeText.contains("what happened") || lastRaeText.contains("tell me more") || lastRaeText.contains("what's on your mind") || lastRaeText.contains("how are you feeling") {
                // User is elaborating - acknowledge and go deeper
                let elaborationResponses = [
                     ChatResponse(text: "Thank you for sharing that with me. That sounds really difficult. How are you feeling in your body right now—any tension, heaviness, or tightness?", safetyFlag: nil, suggestedTool: nil),
                     ChatResponse(text: "I appreciate you opening up. That's a lot to carry. What part of this feels the heaviest right now?", safetyFlag: nil, suggestedTool: nil),
                     ChatResponse(text: "I hear you. That's really tough. What do you think you need most in this moment?", safetyFlag: nil, suggestedTool: nil)
                ]
                return elaborationResponses.randomElement()!
            }
            
            // Generic short response after any question from Rae
            // ONLY if it triggers NO other keywords below
            if message.split(separator: " ").count < 6 && lastRaeText.contains("?") {
                // Check if message hits other keywords below. If so, SKIP this.
                let nextKeywords = ["anxious", "anxiety", "worried", "panic", "sleep", "tired", "insomnia", "stress", "overwhelm", "sad", "down", "depressed", "lonely", "alone", "failure", "shame", "angry", "scared", "diagnosed", "money", "debt", "bullied", "drinking", "drugs", "family", "friend"]
                
                let hasKeyword = nextKeywords.contains { message.contains($0) }
                
                if !hasKeyword {
                    let shortFollowUps = [
                        ChatResponse(text: "I understand. Thank you for telling me. How does that settle in your body right now?", safetyFlag: nil, suggestedTool: nil),
                        ChatResponse(text: "Okay. I'm here witnessing this with you. What do you think you need most in this moment?", safetyFlag: nil, suggestedTool: nil),
                        ChatResponse(text: "Thank you for sharing. Take a gentle breath with me. Is there anything else you'd like to explore?", safetyFlag: nil, suggestedTool: .breathe),
                        ChatResponse(text: "I hear you. It's okay to just be where you are. Would a grounding exercise help, or do you want to keep talking?", safetyFlag: nil, suggestedTool: nil),
                        ChatResponse(text: "That makes sense. You're being really open with me, and I appreciate that. What feels most important to address right now?", safetyFlag: nil, suggestedTool: nil)
                    ]
                    return shortFollowUps.randomElement()!
                }
            }
        }
        
        // --- PRIORITY 3: TOPIC-SPECIFIC KEYWORDS ---
        // (Anxiety, Sleep, Stress, etc.)
        
        // Body image / Eating concerns (handle carefully)
        if message.contains("hate my body") || message.contains("fat") || message.contains("ugly") || message.contains("eating") || message.contains("weight") || message.contains("binge") || message.contains("purge") || message.contains("starving myself") || message.contains("don't eat") {
             let responses = [
                 ChatResponse(
                     text: "Thank you for sharing something so personal. How you feel about your body is real and valid, even when those feelings are painful. You deserve kindness—from others and from yourself. Would you like to talk more about what's going on?",
                     safetyFlag: "sensitive_topic",
                     suggestedTool: nil
                 ),
                 ChatResponse(
                     text: "I hear you. Struggling with how we see ourselves or our relationship with food is really hard. You're not alone in this, and there's no shame in what you're feeling. Have you been able to talk to anyone else about this?",
                     safetyFlag: "sensitive_topic",
                     suggestedTool: nil
                 )
             ]
             return responses.randomElement()!
         }
         
        // Anxiety-related keywords
        if message.contains("anxious") || message.contains("anxiety") || message.contains("worried") || message.contains("panic") {
            let responses = [
                ChatResponse(
                    text: "I hear you. Anxiety can feel overwhelming, but you're not alone in this. Would you like to try a quick breathing exercise? It can help calm your nervous system in just a few minutes.",
                    safetyFlag: nil,
                    suggestedTool: .breathe
                ),
                ChatResponse(
                    text: "Thank you for sharing that with me. Anxiety is something many people experience, and it's okay to feel this way. Sometimes grounding yourself helps—try noticing 5 things you can see around you right now. Would you like to try a guided grounding exercise?",
                    safetyFlag: nil,
                    suggestedTool: .visualize
                ),
                ChatResponse(
                    text: "That sounds really tough, and I appreciate you opening up. Remember, this feeling will pass. Would you like me to suggest a calming visualization or a simple breathing technique?",
                    safetyFlag: nil,
                    suggestedTool: .breathe
                )
            ]
            return responses.randomElement()!
        }
        
        // Sleep-related
        if message.contains("sleep") || message.contains("tired") || message.contains("insomnia") || message.contains("can't rest") {
            let responses = [
                ChatResponse(
                    text: "Sleep troubles can be so frustrating. Have you tried our Sleep sounds? Gentle rain or ocean waves can really help. Would you like to try the 4-7-8 breathing technique? It's designed specifically for relaxation and sleep.",
                    safetyFlag: nil,
                    suggestedTool: .sleep
                ),
                ChatResponse(
                    text: "I understand how hard it is when sleep doesn't come easily. Sometimes a body scan before bed can help release tension you didn't know you were holding. Want me to guide you through one?",
                    safetyFlag: nil,
                    suggestedTool: .visualize
                )
            ]
            return responses.randomElement()!
        }
        
        // Stress/overwhelm
        if message.contains("stress") || message.contains("overwhelm") || message.contains("too much") {
            let responses = [
                ChatResponse(
                    text: "When everything feels like too much, sometimes the simplest thing helps most: one deep breath. Let's try together—breathe in slowly for 4 counts, then out for 6. You're doing great just by being here.",
                    safetyFlag: nil,
                    suggestedTool: .breathe
                ),
                ChatResponse(
                    text: "I'm here with you. It's okay to feel overwhelmed—life can be a lot sometimes. Would you like to try a calming game to give your mind a gentle break? Or we could do some breathing together.",
                    safetyFlag: nil,
                    suggestedTool: .games
                )
            ]
            return responses.randomElement()!
        }
        
        // Sad/down (but NOT lonely - that has its own category below)
        if message.contains("sad") || message.contains("down") || message.contains("depressed") || message.contains("feeling low") || message.contains("unhappy") {
            let responses = [
                ChatResponse(
                    text: "I'm sorry you're feeling this way. It takes courage to share that. Would it help to read some gentle affirmations, or would you prefer to just talk? I'm here to listen.",
                    safetyFlag: nil,
                    suggestedTool: .affirm
                ),
                ChatResponse(
                    text: "Thank you for trusting me with how you're feeling. Sadness is a part of being human, and it's okay to feel it. Sometimes writing down our thoughts in a journal can help process difficult feelings. Would you like to try that?",
                    safetyFlag: nil,
                    suggestedTool: .journal
                )
            ]
            return responses.randomElement()!
        }
        
        // Greetings
        if message.contains("hello") || message.contains("hi") || message.contains("hey") {
            return ChatResponse(
                text: "Hello! I'm Rae, your wellbeing companion. How are you feeling today? I'm here to listen and help however I can.",
                safetyFlag: nil,
                suggestedTool: nil
            )
        }
        
        // Gratitude/positive
        if message.contains("thank") || message.contains("grateful") || message.contains("better") {
            return ChatResponse(
                text: "I'm so glad to hear that. Remember, taking time for yourself is important, and you're doing great. Is there anything else on your mind?",
                safetyFlag: nil,
                suggestedTool: nil
            )
        }
        
        // Work/School stress (general, ongoing stress - not job loss)
        // NOTE: Job loss is handled in Priority 1 above
        if message.contains("work") || message.contains("job") || message.contains("school") || message.contains("study") || message.contains("boss") {
            let responses = [
                ChatResponse(
                    text: "It sounds like there's a lot of pressure on you right now. Remember, your worth isn't defined by your productivity. What's weighing on you the most?",
                    safetyFlag: nil,
                    suggestedTool: .breathe
                ),
                ChatResponse(
                    text: "That sounds stressful. Work and responsibilities can really pile up. Would it help to take a moment to breathe, or do you want to talk through what's going on?",
                    safetyFlag: nil,
                    suggestedTool: nil
                )
            ]
            return responses.randomElement()!
        }
        
        // NOTE: Breakup/Divorce is handled in Priority 1 above
        
        // NOTE: Grief/Death is handled in Priority 1 above
        
        // Health diagnosis/illness
        if message.contains("diagnosed") || message.contains("illness") || message.contains("disease") || message.contains("cancer") || message.contains("hospital") || message.contains("doctor said") || message.contains("test results") || message.contains("sick") {
            let responses = [
                ChatResponse(
                    text: "That's a lot to process. Health news can be overwhelming and scary. It's okay to feel however you're feeling about this. Do you have people around you for support?",
                    safetyFlag: nil,
                    suggestedTool: nil
                ),
                ChatResponse(
                    text: "I'm sorry you're dealing with this. Facing health challenges is frightening, and you don't have to be strong all the time. What do you need right now?",
                    safetyFlag: nil,
                    suggestedTool: nil
                )
            ]
            return responses.randomElement()!
        }
        
        // Financial stress
        if message.contains("money") || message.contains("debt") || message.contains("bills") || message.contains("broke") || message.contains("afford") || message.contains("rent") || message.contains("evict") || message.contains("bankrupt") {
            let responses = [
                ChatResponse(
                    text: "Financial stress is so heavy to carry. It affects everything—sleep, relationships, how you feel about yourself. You're not alone in this. What feels most overwhelming right now?",
                    safetyFlag: nil,
                    suggestedTool: nil
                ),
                ChatResponse(
                    text: "I hear you. Money worries can be all-consuming and exhausting. It doesn't make you a failure—life is hard sometimes. How are you holding up?",
                    safetyFlag: nil,
                    suggestedTool: nil
                )
            ]
            return responses.randomElement()!
        }
        
        // Loneliness/Isolation
        if message.contains("lonely") || message.contains("alone") || message.contains("no friends") || message.contains("isolated") || message.contains("no one to talk") || message.contains("nobody understands") || message.contains("don't belong") {
            let responses = [
                ChatResponse(
                    text: "Loneliness is such a painful feeling. I'm glad you're here talking to me. You matter, and your feelings matter. What's making you feel this way?",
                    safetyFlag: nil,
                    suggestedTool: nil
                ),
                ChatResponse(
                    text: "Feeling alone is really hard. It doesn't mean something is wrong with you—connection can be difficult to find. I'm here with you right now. Tell me more about what you're experiencing.",
                    safetyFlag: nil,
                    suggestedTool: nil
                )
            ]
            return responses.randomElement()!
        }
        
        // Failure/Disappointment
        if message.contains("failed") || message.contains("failure") || message.contains("disappointed") || message.contains("let everyone down") || message.contains("messed up") || message.contains("ruined") || message.contains("screwed up") {
            let responses = [
                ChatResponse(
                    text: "That sounds really painful. Feeling like you've failed is one of the hardest feelings. But struggling doesn't make you a failure—it makes you human. What happened?",
                    safetyFlag: nil,
                    suggestedTool: nil
                ),
                ChatResponse(
                    text: "I'm sorry you're feeling this way. Disappointment in ourselves can cut deep. You're being really hard on yourself. Can you tell me more about what's going on?",
                    safetyFlag: nil,
                    suggestedTool: nil
                )
            ]
            return responses.randomElement()!
        }
        
        // Shame/Embarrassment
        if message.contains("ashamed") || message.contains("shame") || message.contains("embarrassed") || message.contains("humiliated") || message.contains("can't show my face") || message.contains("everyone knows") {
            let responses = [
                ChatResponse(
                    text: "Shame is such a heavy feeling to carry. Whatever happened, you don't deserve to suffer alone with this. It takes courage to even talk about it. I'm here.",
                    safetyFlag: nil,
                    suggestedTool: nil
                ),
                ChatResponse(
                    text: "I hear you. Shame can make us want to hide from the world. But you're here, sharing this with me, and that's brave. What's weighing on you?",
                    safetyFlag: nil,
                    suggestedTool: nil
                )
            ]
            return responses.randomElement()!
        }
        
        // NOTE: Betrayal/Trust is handled in Priority 1 above
        
        // Bullying/Harassment
        if message.contains("bullied") || message.contains("bully") || message.contains("harassed") || message.contains("picked on") || message.contains("made fun of") || message.contains("mean to me") {
            let responses = [
                ChatResponse(
                    text: "I'm so sorry you're dealing with this. Being bullied is painful and it's not okay. None of this is your fault. You didn't deserve this treatment. How long has this been going on?",
                    safetyFlag: nil,
                    suggestedTool: nil
                ),
                ChatResponse(
                    text: "That's awful, and I'm sorry. No one deserves to be treated that way. What you're feeling is valid—this is a real thing that's hurting you. Is there somewhere safe you can go?",
                    safetyFlag: nil,
                    suggestedTool: nil
                )
            ]
            return responses.randomElement()!
        }
        
        // Rejection
        if message.contains("rejected") || message.contains("rejection") || message.contains("didn't want me") || message.contains("turned down") || message.contains("not good enough") || message.contains("unwanted") {
            let responses = [
                ChatResponse(
                    text: "Rejection really hurts. It can make you question yourself, but please know—one rejection doesn't define your worth. How are you feeling about it?",
                    safetyFlag: nil,
                    suggestedTool: nil
                ),
                ChatResponse(
                    text: "I'm sorry. Being rejected stings, especially when you put yourself out there. It's okay to feel hurt. That doesn't mean there's anything wrong with you.",
                    safetyFlag: nil,
                    suggestedTool: nil
                )
            ]
            return responses.randomElement()!
        }
        
        // NOTE: Trauma/Abuse is handled in Priority 1 above
        
        // Addiction struggles
        if message.contains("drinking") || message.contains("drunk") || message.contains("drugs") || message.contains("addict") || message.contains("relapsed") || message.contains("can't stop") || message.contains("sober") {
            let responses = [
                ChatResponse(
                    text: "Thank you for being honest about this. Addiction is incredibly hard to deal with, and there's no shame in struggling. The fact that you're talking about it shows strength. How can I support you right now?",
                    safetyFlag: nil,
                    suggestedTool: nil
                ),
                ChatResponse(
                    text: "I hear you. Recovery isn't a straight line, and setbacks don't erase your progress. You're not weak for struggling—this is one of the hardest battles there is. What's going on today?",
                    safetyFlag: nil,
                    suggestedTool: nil
                )
            ]
            return responses.randomElement()!
        }
        
        // Parenting struggles
        if message.contains("bad parent") || message.contains("bad mom") || message.contains("bad dad") || message.contains("kids are") || message.contains("my children") || message.contains("parenting") {
            let responses = [
                ChatResponse(
                    text: "Parenting is one of the hardest jobs there is, and struggling doesn't make you a bad parent. The fact that you care this much shows how much you love them. What's been hardest lately?",
                    safetyFlag: nil,
                    suggestedTool: nil
                ),
                ChatResponse(
                    text: "I hear you. Being a parent is exhausting, and it's okay to admit when it's overwhelming. You're doing better than you think. What do you need right now?",
                    safetyFlag: nil,
                    suggestedTool: nil
                )
            ]
            return responses.randomElement()!
        }
        
        // Caregiver burnout
        if message.contains("taking care of") || message.contains("caregiver") || message.contains("caring for") || message.contains("look after") {
            let responses = [
                ChatResponse(
                    text: "Caring for someone else is exhausting, physically and emotionally. Your needs matter too—you can't pour from an empty cup. How are YOU doing?",
                    safetyFlag: nil,
                    suggestedTool: nil
                ),
                ChatResponse(
                    text: "That's a lot of responsibility to carry. Caregiver burnout is real, and it's okay to feel drained. You're doing something incredibly hard. What support do you have for yourself?",
                    safetyFlag: nil,
                    suggestedTool: nil
                )
            ]
            return responses.randomElement()!
        }
        
        // Anger/Frustration
        if message.contains("angry") || message.contains("furious") || message.contains("rage") || message.contains("pissed") || message.contains("frustrated") || message.contains("mad at") || message.contains("hate") {
            let responses = [
                ChatResponse(
                    text: "It sounds like you're feeling really angry right now. That's a valid emotion—anger often comes up when something feels unfair or when our boundaries have been crossed. What's going on?",
                    safetyFlag: nil,
                    suggestedTool: nil
                ),
                ChatResponse(
                    text: "I hear the frustration in what you're sharing. Anger can be overwhelming. Sometimes it helps to let it out—would you like to vent, or would a breathing exercise help you feel more grounded first?",
                    safetyFlag: nil,
                    suggestedTool: .breathe
                )
            ]
            return responses.randomElement()!
        }
        
        // Fear/Scared
        if message.contains("scared") || message.contains("afraid") || message.contains("terrified") || message.contains("fear") || message.contains("frightened") || message.contains("freaking out") {
            let responses = [
                ChatResponse(
                    text: "It's okay to feel scared. Fear is your mind trying to protect you, even when it feels overwhelming. You're not alone in this. Can you tell me what's frightening you?",
                    safetyFlag: nil,
                    suggestedTool: nil
                ),
                ChatResponse(
                    text: "That sounds really scary. I'm here with you. Sometimes when fear feels big, grounding ourselves in the present moment can help. Would you like to try that, or do you need to talk through what's happening?",
                    safetyFlag: nil,
                    suggestedTool: .breathe
                )
            ]
            return responses.randomElement()!
        }
        
        // Confusion/Overwhelmed/Don't know what to do
        if message.contains("confused") || message.contains("don't know what to do") || message.contains("lost") || message.contains("stuck") || message.contains("don't know how") || message.contains("no idea") || message.contains("overwhelmed") {
            let responses = [
                ChatResponse(
                    text: "Feeling confused or stuck is really uncomfortable. It's okay to not have all the answers right now. Sometimes just pausing and breathing can create a little space. What feels most unclear?",
                    safetyFlag: nil,
                    suggestedTool: nil
                ),
                ChatResponse(
                    text: "That's a hard place to be. When everything feels uncertain, it can help to focus on just one small thing at a time. What's weighing on you the most right now?",
                    safetyFlag: nil,
                    suggestedTool: nil
                )
            ]
            return responses.randomElement()!
        }
        
        // NOTE: Body image / Eating concerns is handled earlier in Priority 3
        
        // Identity / LGBTQ+ struggles
        if message.contains("coming out") || message.contains("gay") || message.contains("lesbian") || message.contains("bisexual") || message.contains("transgender") || message.contains("trans") || message.contains("queer") || message.contains("identity") || message.contains("who i am") || message.contains("don't fit in") || message.contains("different from everyone") {
            let responses = [
                ChatResponse(
                    text: "Thank you for trusting me with this. Exploring or sharing your identity takes courage. However you identify, you are valid and worthy of love and acceptance. How are you feeling about all of this?",
                    safetyFlag: nil,
                    suggestedTool: nil
                ),
                ChatResponse(
                    text: "I'm glad you felt safe enough to share this with me. Figuring out who you are—or sharing that with others—can bring up a lot of emotions. You don't have to have it all figured out. What's on your mind?",
                    safetyFlag: nil,
                    suggestedTool: nil
                )
            ]
            return responses.randomElement()!
        }
        
        // Relationships/Family (general, ongoing issues - not breakups)
        if message.contains("family") || message.contains("friend") || message.contains("partner") || message.contains("fight") || message.contains("argument") {
            let responses = [
                ChatResponse(
                    text: "Relationships can be really complicated. It's okay to feel hurt or confused. I'm here to listen if you want to share more about what happened.",
                    safetyFlag: nil,
                    suggestedTool: nil
                ),
                ChatResponse(
                    text: "That sounds difficult. Connection is important, but so is your peace. What do you think you need most right now?",
                    safetyFlag: nil,
                    suggestedTool: .affirm
                )
            ]
            return responses.randomElement()!
        }

        // Default supportive responses - Empathetic and varied
        // NOTE: These should NOT ask "how long" since we have specific follow-up handling for that
        let defaultResponses = [
            ChatResponse(
                text: "Thank you for sharing that with me. It sounds like something's weighing on you. Can you tell me more about what's going on?",
                safetyFlag: nil,
                suggestedTool: nil
            ),
            ChatResponse(
                text: "I hear you. Whatever you're going through, your feelings are completely valid. What's been on your mind?",
                safetyFlag: nil,
                suggestedTool: nil
            ),
            ChatResponse(
                text: "That sounds difficult. I'm here with you, and I want to understand. What's been the hardest part?",
                safetyFlag: nil,
                suggestedTool: nil
            ),
            ChatResponse(
                text: "I'm here, and I'm listening. Take your time—there's no rush. What feels most important to share right now?",
                safetyFlag: nil,
                suggestedTool: nil
            ),
            ChatResponse(
                text: "It takes courage to open up like this. I appreciate you trusting me. What do you need most right now—to vent, to be heard, or something else?",
                safetyFlag: nil,
                suggestedTool: nil
            ),
            ChatResponse(
                text: "Sometimes just naming what we're feeling helps a little. What's the strongest emotion coming up for you?",
                safetyFlag: nil,
                suggestedTool: nil
            ),
            ChatResponse(
                text: "You're not alone in this. I'm here with you. Is there a specific part of this that's hurting the most?",
                safetyFlag: nil,
                suggestedTool: nil
            ),
            ChatResponse(
                text: "That sounds really hard. You're doing the best you can in a difficult situation, and that matters. What would help you feel a little better right now?",
                safetyFlag: nil,
                suggestedTool: nil
            ),
            ChatResponse(
                text: "I'm glad you reached out. You don't have to figure this out alone. Tell me more about what's happening.",
                safetyFlag: nil,
                suggestedTool: nil
            ),
            ChatResponse(
                text: "Whatever you're feeling right now is okay. There's no wrong way to feel. Would you like to talk more, or would something grounding help?",
                safetyFlag: nil,
                suggestedTool: nil
            ),
            ChatResponse(
                text: "I'm with you. Let's slow down for a moment. What's the first thing that comes to mind when you think about how you're feeling?",
                safetyFlag: nil,
                suggestedTool: nil
            ),
            ChatResponse(
                text: "Thank you for being here. It takes strength to reach out. What brought you to the app today?",
                safetyFlag: nil,
                suggestedTool: nil
            )
        ]
        
        return defaultResponses.randomElement()!
    }
}

// MARK: - Chat Service Error
enum ChatServiceError: Error {
    case networkError
    case invalidResponse
    case rateLimited
}

/*
 TODO: Future LLM Integration
 
 To integrate a real LLM API:
 
 1. Create a new class implementing ChatService (e.g., OpenAIChatService)
 
 2. Store API keys securely:
    - Use Keychain for local storage
    - Or fetch from a secure backend
    - NEVER hard-code API keys in source code
 
 3. Implement the send() method to:
    - Format messages for the API
    - Send request with proper headers
    - Parse response
    - Always check for crisis keywords locally BEFORE sending to API
    - Always include safety instructions in the system prompt
 
 4. System prompt should include:
    - Identity: \"You are Rae, a supportive wellbeing companion... \"
    - Boundaries: \"You are not a doctor, therapist, or emergency service... \"
    - Safety: \"If user mentions self-harm, always respond with crisis resources... \"
    - Never provide: "Instructions on self-harm, suicide, violence, or harmful content"
 
 5. Update the app to use dependency injection to swap implementations
 
 Example skeleton:
 
 class OpenAIChatService: ChatService {
     private let apiKeyProvider: () -> String?
     
     init(apiKeyProvider: @escaping () -> String?) {
         self.apiKeyProvider = apiKeyProvider
     }
     
     func send(message: String, history: [ChatMessage]) async throws -> ChatMessage {
         // Check crisis keywords locally first
         if containsCrisisKeywords(message) {
             return createLocalCrisisResponse()
         }
         
         guard let apiKey = apiKeyProvider() else {
             throw ChatServiceError.networkError
         }
         
         // Make API request...
     }
 }
 */

