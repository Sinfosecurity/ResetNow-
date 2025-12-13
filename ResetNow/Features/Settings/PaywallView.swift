//
//  PaywallView.swift
//  ResetNow
//
//  Premium subscription sales page
//

import SwiftUI
import StoreKit

struct PaywallView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var storeManager = StoreManager.shared
    @State private var selectedProduct: Product?
    @State private var errorMessage: String?
    @State private var showingError = false
    
    #if DEBUG
    @State private var debugSelectedOption = 1 // 0: Monthly, 1: Yearly
    #endif
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Header Image/Video Placeholder
                ZStack(alignment: .bottom) {
                    // Placeholder for video background
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [.calmSage, .breatheColor.opacity(0.3)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(height: 350)
                        
                    // Overlay gradient
                    LinearGradient(
                        colors: [.clear, Color(.systemBackground)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 100)
                    
                    VStack(spacing: ResetSpacing.md) {
                        Image("AppLogo") // Ensure this asset exists or use system image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 80, height: 80)
                            .cornerRadius(20)
                            .shadow(radius: 10)
                        
                        Text("Unlock Inner Calm")
                            .font(ResetTypography.display(32))
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding(.bottom, ResetSpacing.xl)
                }
                
                VStack(spacing: ResetSpacing.xl) {
                    // Value Props
                    VStack(alignment: .leading, spacing: ResetSpacing.lg) {
                        BenefitRow(icon: "map.fill", title: "Unlock All Journeys", subtitle: "Access comprehensive multi-day programs")
                        BenefitRow(icon: "moon.stars.fill", title: "Full Sleep Library", subtitle: "Unlimited sleep sounds and stories")
                        BenefitRow(icon: "sparkles", title: "Advanced Visualizations", subtitle: "Deep guided imagery for healing")
                    }
                    .padding(.horizontal, ResetSpacing.xl)
                    
                    
                    // Products
                    // Products
                    if !storeManager.products.isEmpty {
                        VStack(spacing: ResetSpacing.md) {
                            ForEach(storeManager.products) { product in
                                ProductOptionRow(
                                    product: product,
                                    isSelected: selectedProduct?.id == product.id
                                )
                                .onTapGesture {
                                    withAnimation {
                                        selectedProduct = product
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, ResetSpacing.lg)
                    }
                    #if DEBUG
                    if storeManager.products.isEmpty {
                        // Simulator / Debug Fallback
                        VStack(spacing: ResetSpacing.md) {
                            Text("Preview Mode (No StoreKit Connection)")
                                .font(ResetTypography.caption(10))
                                .foregroundColor(.secondary)
                                .padding(.bottom, 4)
                            
                            // Fake Monthly
                            FakeProductRow(
                                title: "Monthly Plan",
                                desc: "No trial, just testing",
                                price: "$4.99",
                                isSelected: debugSelectedOption == 0
                            )
                            .onTapGesture {
                                debugSelectedOption = 0
                            }
                            
                            // Fake Yearly
                            FakeProductRow(
                                title: "Yearly Plan",
                                desc: "7 days free, then $39.99/year",
                                price: "$39.99",
                                isSelected: debugSelectedOption == 1
                            )
                            .onTapGesture {
                                debugSelectedOption = 1
                            }
                        }
                        .padding(.horizontal, ResetSpacing.lg)
                    }
                    #endif
                    
                    // CTA Button
                    Button(action: purchaseSelected) {
                        VStack(spacing: 2) {
                            Text(ctaButtonText)
                                .font(ResetTypography.heading(18))
                            
                            if let selected = selectedProduct,
                               let intro = selected.subscription?.introductoryOffer {
                                Text("Try \(intro.period.value) \(intro.period.unit.localizedDescription) free")
                                    .font(ResetTypography.caption(12))
                                    .opacity(0.9)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.calmSage)
                        .foregroundColor(.white)
                        .cornerRadius(16)
                        .shadow(color: .calmSage.opacity(0.3), radius: 10, y: 5)
                    }
                    .padding(.horizontal, ResetSpacing.lg)
                    .padding(.top, ResetSpacing.md)
                    .disabled((selectedProduct == nil && !storeManager.products.isEmpty) || storeManager.isLoading)
                    
                    // Footer Links
                    HStack(spacing: ResetSpacing.lg) {
                        Link("Terms of Use", destination: URL(string: AppConstants.termsOfServiceURL)!)
                        Link("Privacy Policy", destination: URL(string: AppConstants.privacyPolicyURL)!)
                        Button("Restore Purchases") {
                            Task {
                                await storeManager.restorePurchases()
                            }
                        }
                    }
                    .font(ResetTypography.caption(11))
                    .foregroundColor(.secondary)
                    .padding(.bottom, ResetSpacing.xxl)
                }
                .padding(.top, ResetSpacing.lg)
            }
        }
        .edgesIgnoringSafeArea(.top)
        .onAppear {
            Task {
                await storeManager.loadProducts()
                // Default to yearly if available (usually the second item if sorted by price)
                if selectedProduct == nil {
                     // Prefer the higher priced one (Yearly) as default or the second one
                     if storeManager.products.count > 1 {
                         selectedProduct = storeManager.products.last
                     } else {
                         selectedProduct = storeManager.products.first
                     }
                } else if !storeManager.products.isEmpty && selectedProduct == nil {
                     // Fallback check
                     selectedProduct = storeManager.products.last
                }
                }
            }

        .onChange(of: storeManager.products) { _, products in
            if selectedProduct == nil, let bestValue = products.last {
                selectedProduct = bestValue
            }
        }
        .onChange(of: selectedProduct) { _, product in
             // Ensure view updates
             print("Selected product: \(product?.id ?? "nil")")
        }
        .alert("Purchase Failed", isPresented: $showingError, actions: {
            Button("OK", role: .cancel) { }
        }, message: {
            Text(errorMessage ?? "Unknown error")
        })
    }
    
    private var ctaButtonText: String {
        if storeManager.products.isEmpty { return "Unlock (Preview)" }
        guard let product = selectedProduct else { return "Select a Plan" }
        if product.subscription?.introductoryOffer != nil {
            return "Start Free Trial"
        }
        return "Subscribe Now"
    }
    
    private func purchaseSelected() {
        #if DEBUG
        if storeManager.products.isEmpty {
            // Simulator Mode
            storeManager.debugUnlock()
            dismiss()
            return
        }
        #endif
        guard let product = selectedProduct else { return }
        
        Task {
            do {
                try await storeManager.purchase(product)
                // If successful, dismiss
                if storeManager.hasPremiumAccess {
                    dismiss()
                }
            } catch {
                errorMessage = error.localizedDescription
                showingError = true
            }
        }
    }
}

struct BenefitRow: View {
    let icon: String
    let title: String
    let subtitle: String
    
    var body: some View {
        HStack(spacing: ResetSpacing.md) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(.calmSage)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(ResetTypography.heading(16))
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(ResetTypography.caption(13))
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct ProductOptionRow: View {
    let product: Product
    let isSelected: Bool
    
    var body: some View {
        HStack {
            // Radio button
            ZStack {
                Circle()
                    .stroke(isSelected ? Color.calmSage : Color.secondary.opacity(0.3), lineWidth: 2)
                    .frame(width: 24, height: 24)
                
                if isSelected {
                    Circle()
                        .fill(Color.calmSage)
                        .frame(width: 14, height: 14)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(product.displayName)
                    .font(ResetTypography.heading(16))
                    .foregroundColor(isSelected ? .primary : .secondary)
                
                if let subscription = product.subscription, 
                   let intro = subscription.introductoryOffer {
                    Text("7 days free, then \(product.displayPrice)/\(subscription.subscriptionPeriod.unit.localizedDescription)")
                        .font(ResetTypography.caption(12))
                        .foregroundColor(.secondary)
                } else {
                    Text(product.description)
                        .font(ResetTypography.caption(12))
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Text(product.displayPrice)
                .font(ResetTypography.heading(18))
                .foregroundColor(isSelected ? .calmSage : .secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemGroupedBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(isSelected ? Color.calmSage : Color.clear, lineWidth: 2)
                )
        )
        .contentShape(Rectangle()) // Better tap target
    }
}

// Extension to format unit description roughly
extension StoreKit.Product.SubscriptionPeriod.Unit {
    var localizedDescription: String {
        switch self {
        case .day: return "day"
        case .week: return "week"
        case .month: return "month"
        case .year: return "year"
        @unknown default: return "period"
        }
    }
}

#if DEBUG
struct FakeProductRow: View {
    let title: String
    let desc: String
    let price: String
    let isSelected: Bool
    
    var body: some View {
        HStack {
            // Radio button
            ZStack {
                Circle()
                    .stroke(isSelected ? Color.calmSage : Color.secondary.opacity(0.3), lineWidth: 2)
                    .frame(width: 24, height: 24)
                
                if isSelected {
                    Circle()
                    .fill(Color.calmSage)
                    .frame(width: 14, height: 14)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(ResetTypography.heading(16))
                    .foregroundColor(isSelected ? .primary : .secondary)
                
                Text(desc)
                    .font(ResetTypography.caption(12))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(price)
                .font(ResetTypography.heading(18))
                .foregroundColor(isSelected ? .calmSage : .secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemGroupedBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(isSelected ? Color.calmSage : Color.clear, lineWidth: 2)
                )
        )
        .contentShape(Rectangle())
    }
}
#endif
