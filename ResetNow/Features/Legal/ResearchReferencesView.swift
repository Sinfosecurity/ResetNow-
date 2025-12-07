//
//  ResearchReferencesView.swift
//  ResetNow
//
//  Academic research references supporting app techniques
//

import SwiftUI

struct ResearchReferencesView: View {
    let references = ResearchData.allReferences
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: ResetSpacing.lg) {
                // Header
                headerSection
                
                // References list
                ForEach(references) { reference in
                    ReferenceCard(reference: reference)
                }
                
                // Disclaimer
                disclaimerSection
            }
            .padding(.horizontal, ResetSpacing.md)
            .padding(.bottom, ResetSpacing.xxl)
        }
        .background(Color(.systemBackground).ignoresSafeArea())
        .navigationTitle("Research References")
        .navigationBarTitleDisplayMode(.large)
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: ResetSpacing.sm) {
            Text("Evidence-Based Techniques")
                .font(ResetTypography.heading(18))
                .foregroundColor(.primary)
            
            Text("ResetNow's techniques are based on peer-reviewed research. Below are key academic references that support the methods used in this app.")
                .font(ResetTypography.body(14))
                .foregroundColor(.secondary)
        }
    }
    
    private var disclaimerSection: some View {
        VStack(alignment: .leading, spacing: ResetSpacing.sm) {
            Text("Note")
                .font(ResetTypography.heading(14))
                .foregroundColor(.secondary)
            
            Text("These references are provided for educational purposes. This list is not exhaustive, and ResetNow is not a substitute for professional medical advice. Consult a qualified healthcare provider for personalized guidance.")
                .font(ResetTypography.caption(12))
                .foregroundColor(.warmGray.opacity(0.8))
        }
        .padding(ResetSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.warmGray.opacity(0.1))
        )
    }
}

// MARK: - Reference Card
struct ReferenceCard: View {
    let reference: ResearchReference
    @Environment(\.openURL) var openURL
    
    var body: some View {
        VStack(alignment: .leading, spacing: ResetSpacing.sm) {
            // Title
            Text(reference.title)
                .font(ResetTypography.heading(14))
                .foregroundColor(.primary)
            
            // Authors and year
            Text("\(reference.authors) (\(reference.year))")
                .font(ResetTypography.caption(12))
                .foregroundColor(.calmSage)
            
            // Journal
            Text(reference.journal)
                .font(ResetTypography.caption(12))
                .foregroundColor(.secondary)
                .italic()
            
            // Link if available
            if let urlString = reference.url, let url = URL(string: urlString) {
                Button(action: { openURL(url) }) {
                    HStack(spacing: 4) {
                        Text("View Abstract")
                            .font(ResetTypography.caption(12))
                        Image(systemName: "arrow.up.right")
                            .font(.system(size: 10))
                    }
                    .foregroundColor(.calmSage)
                }
            }
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

// MARK: - Research Data
struct ResearchData {
    static let allReferences: [ResearchReference] = [
        ResearchReference(
            authors: "Brown, R.P. & Gerbarg, P.L.",
            year: "2005",
            title: "Sudarshan Kriya yogic breathing in the treatment of stress, anxiety, and depression",
            journal: "Journal of Alternative and Complementary Medicine, 11(4), 711-717",
            url: "https://pubmed.ncbi.nlm.nih.gov/16131297/"
        ),
        ResearchReference(
            authors: "Ma, X., Yue, Z.Q., Gong, Z.Q., et al.",
            year: "2017",
            title: "The effect of diaphragmatic breathing on attention, negative affect and stress in healthy adults",
            journal: "Frontiers in Psychology, 8, 874",
            url: "https://pubmed.ncbi.nlm.nih.gov/28626434/"
        ),
        ResearchReference(
            authors: "Hofmann, S.G., Sawyer, A.T., Witt, A.A., & Oh, D.",
            year: "2010",
            title: "The effect of mindfulness-based therapy on anxiety and depression: A meta-analytic review",
            journal: "Journal of Consulting and Clinical Psychology, 78(2), 169-183",
            url: "https://pubmed.ncbi.nlm.nih.gov/20350028/"
        ),
        ResearchReference(
            authors: "Kabat-Zinn, J.",
            year: "1990",
            title: "Full Catastrophe Living: Using the Wisdom of Your Body and Mind to Face Stress, Pain, and Illness",
            journal: "Delacorte Press (Book)",
            url: nil
        ),
        ResearchReference(
            authors: "Goyal, M., Singh, S., Sibinga, E.M., et al.",
            year: "2014",
            title: "Meditation programs for psychological stress and well-being: A systematic review and meta-analysis",
            journal: "JAMA Internal Medicine, 174(3), 357-368",
            url: "https://pubmed.ncbi.nlm.nih.gov/24395196/"
        ),
        ResearchReference(
            authors: "Khoury, B., Lecomte, T., Fortin, G., et al.",
            year: "2013",
            title: "Mindfulness-based therapy: A comprehensive meta-analysis",
            journal: "Clinical Psychology Review, 33(6), 763-771",
            url: "https://pubmed.ncbi.nlm.nih.gov/23796855/"
        ),
        ResearchReference(
            authors: "Jerath, R., Edry, J.W., Barnes, V.A., & Jerath, V.",
            year: "2006",
            title: "Physiology of long pranayamic breathing: Neural respiratory elements may provide a mechanism that explains how slow deep breathing shifts the autonomic nervous system",
            journal: "Medical Hypotheses, 67(3), 566-571",
            url: "https://pubmed.ncbi.nlm.nih.gov/16624497/"
        ),
        ResearchReference(
            authors: "Arch, J.J. & Craske, M.G.",
            year: "2006",
            title: "Mechanisms of mindfulness: Emotion regulation following a focused breathing induction",
            journal: "Behaviour Research and Therapy, 44(12), 1849-1858",
            url: "https://pubmed.ncbi.nlm.nih.gov/16460668/"
        ),
        ResearchReference(
            authors: "Zeidan, F., Johnson, S.K., Diamond, B.J., David, Z., & Goolkasian, P.",
            year: "2010",
            title: "Mindfulness meditation improves cognition: Evidence of brief mental training",
            journal: "Consciousness and Cognition, 19(2), 597-605",
            url: "https://pubmed.ncbi.nlm.nih.gov/20363650/"
        ),
        ResearchReference(
            authors: "Hoge, E.A., Bui, E., Marques, L., et al.",
            year: "2013",
            title: "Randomized controlled trial of mindfulness meditation for generalized anxiety disorder: Effects on anxiety and stress reactivity",
            journal: "Journal of Clinical Psychiatry, 74(8), 786-792",
            url: "https://pubmed.ncbi.nlm.nih.gov/23541163/"
        )
    ]
}

// MARK: - Preview
struct ResearchReferencesView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ResearchReferencesView()
        }
    }
}

