//
//  MedicalSourcesView.swift
//  ResetNow
//
//  Medical sources and citations for App Store Guideline 1.4.1 compliance
//

import SwiftUI

struct MedicalSourcesView: View {
    let sources = MedicalSourcesData.allSources
    
    var groupedSources: [MedicalSource.SourceCategory: [MedicalSource]] {
        Dictionary(grouping: sources, by: { $0.category })
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: ResetSpacing.lg) {
                // Disclaimer
                disclaimerSection
                
                // Sources by category
                ForEach(MedicalSource.SourceCategory.allCases, id: \.rawValue) { category in
                    if let categorySources = groupedSources[category] {
                        sourceCategorySection(category: category, sources: categorySources)
                    }
                }
            }
            .padding(.horizontal, ResetSpacing.md)
            .padding(.bottom, ResetSpacing.xxl)
        }
        .background(Color(.systemBackground).ignoresSafeArea())
        .navigationTitle("Medical Sources")
        .navigationBarTitleDisplayMode(.large)
    }
    
    private var disclaimerSection: some View {
        VStack(alignment: .leading, spacing: ResetSpacing.sm) {
            HStack(spacing: ResetSpacing.sm) {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(.calmSage)
                Text("Important Disclaimer")
                    .font(ResetTypography.heading(16))
                    .foregroundColor(.primary)
            }
            
            Text("ResetNow provides general wellbeing and educational information only and is not a substitute for professional medical advice, diagnosis, or treatment. Always seek the advice of a qualified health provider with any questions you may have regarding a medical condition.")
                .font(ResetTypography.body(14))
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(ResetSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.calmSage.opacity(0.1))
        )
    }
    
    private func sourceCategorySection(category: MedicalSource.SourceCategory, sources: [MedicalSource]) -> some View {
        VStack(alignment: .leading, spacing: ResetSpacing.md) {
            Text(category.rawValue)
                .font(ResetTypography.heading(18))
                .foregroundColor(.primary)
            
            ForEach(sources) { source in
                SourceCard(source: source)
            }
        }
    }
}

// MARK: - Source Card
struct SourceCard: View {
    let source: MedicalSource
    @Environment(\.openURL) var openURL
    
    var body: some View {
        Button(action: openSource) {
            VStack(alignment: .leading, spacing: ResetSpacing.sm) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(source.title)
                            .font(ResetTypography.heading(15))
                            .foregroundColor(.primary)
                        
                        Text(source.organization)
                            .font(ResetTypography.caption(12))
                            .foregroundColor(.calmSage)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "arrow.up.right.square")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                }
                
                Text(source.description)
                    .font(ResetTypography.body(13))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }
            .padding(ResetSpacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color(.secondarySystemGroupedBackground))
                    .resetShadow(radius: 4, opacity: 0.04)
            )
        }
    }
    
    private func openSource() {
        if let url = URL(string: source.url) {
            openURL(url)
        }
    }
}

// MARK: - Medical Sources Data
struct MedicalSourcesData {
    static let allSources: [MedicalSource] = [
        // Mental Health & Anxiety
        MedicalSource(
            title: "National Institute of Mental Health",
            organization: "NIMH",
            description: "The lead U.S. agency for research on mental disorders, providing science-backed information on anxiety disorders.",
            url: "https://www.nimh.nih.gov/health/topics/anxiety-disorders",
            category: .mentalHealth
        ),
        MedicalSource(
            title: "American Psychological Association",
            organization: "APA",
            description: "The leading scientific and professional organization representing psychology in the United States.",
            url: "https://www.apa.org/topics/anxiety",
            category: .mentalHealth
        ),
        MedicalSource(
            title: "Anxiety and Depression Association of America",
            organization: "ADAA",
            description: "An international nonprofit organization dedicated to the prevention, treatment, and cure of anxiety, depression, OCD, PTSD, and co-occurring disorders.",
            url: "https://adaa.org",
            category: .mentalHealth
        ),
        MedicalSource(
            title: "World Health Organization - Mental Health",
            organization: "WHO",
            description: "Global guidance on mental health conditions, including anxiety disorders and their management.",
            url: "https://www.who.int/health-topics/mental-health",
            category: .mentalHealth
        ),
        
        // Breathing & Relaxation
        MedicalSource(
            title: "Mayo Clinic - Relaxation Techniques",
            organization: "Mayo Clinic",
            description: "Evidence-based information on stress management and relaxation techniques including deep breathing exercises.",
            url: "https://www.mayoclinic.org/healthy-lifestyle/stress-management/in-depth/relaxation-technique/art-20045368",
            category: .breathing
        ),
        MedicalSource(
            title: "Harvard Medical School - Relaxation Response",
            organization: "Harvard Health Publishing",
            description: "Research-backed information on the relaxation response and breathing techniques for stress reduction.",
            url: "https://www.health.harvard.edu/mind-and-mood/relaxation-techniques-breath-control-helps-quell-errant-stress-response",
            category: .breathing
        ),
        MedicalSource(
            title: "Cleveland Clinic - Diaphragmatic Breathing",
            organization: "Cleveland Clinic",
            description: "Medical guidance on deep breathing techniques and their physiological benefits.",
            url: "https://my.clevelandclinic.org/health/articles/9445-diaphragmatic-breathing",
            category: .breathing
        ),
        
        // Sleep & Wellness
        MedicalSource(
            title: "National Sleep Foundation",
            organization: "NSF",
            description: "The leading voice for sleep health and wellness, providing evidence-based sleep guidance.",
            url: "https://www.thensf.org",
            category: .sleep
        ),
        MedicalSource(
            title: "CDC - Sleep and Sleep Disorders",
            organization: "Centers for Disease Control and Prevention",
            description: "Public health information on sleep health, disorders, and evidence-based recommendations.",
            url: "https://www.cdc.gov/sleep/index.html",
            category: .sleep
        ),
        MedicalSource(
            title: "American Academy of Sleep Medicine",
            organization: "AASM",
            description: "The only professional society dedicated exclusively to the medical subspecialty of sleep medicine.",
            url: "https://aasm.org",
            category: .sleep
        ),
        
        // Therapeutic Approaches
        MedicalSource(
            title: "Association for Behavioral and Cognitive Therapies",
            organization: "ABCT",
            description: "Evidence-based resources on cognitive behavioral therapy and its applications for anxiety.",
            url: "https://www.abct.org",
            category: .therapeutic
        ),
        MedicalSource(
            title: "Mindfulness-Based Stress Reduction",
            organization: "UMass Memorial Health",
            description: "The original MBSR program founded by Jon Kabat-Zinn, with research on mindfulness for stress.",
            url: "https://www.umassmed.edu/cfm/mindfulness-based-programs/mbsr-courses/",
            category: .therapeutic
        ),
        MedicalSource(
            title: "American Mindfulness Research Association",
            organization: "AMRA",
            description: "Research resources and publications on mindfulness and its applications in mental health.",
            url: "https://goamra.org",
            category: .therapeutic
        )
    ]
}

// MARK: - Preview
struct MedicalSourcesView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            MedicalSourcesView()
        }
    }
}

