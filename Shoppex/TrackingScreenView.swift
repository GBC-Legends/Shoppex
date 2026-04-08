import SwiftUI

struct TrackingScreenView: View {
    @Binding var currentScreen: AppScreen

    @State private var selectedProvince = "Ontario"

    @State private var summaryItems: [SummaryTrackedItem] = [
        SummaryTrackedItem(name: "Apples", price: "0.00", taxable: false),
        SummaryTrackedItem(name: "Pizza", price: "0.00", taxable: true),
        SummaryTrackedItem(name: "Detergent", price: "0.00", taxable: true)
    ]

    let provinces: [String: Double] = [
        "Alberta": 0.05,
        "British Columbia": 0.12,
        "Manitoba": 0.12,
        "New Brunswick": 0.15,
        "Newfoundland and Labrador": 0.15,
        "Northwest Territories": 0.05,
        "Nova Scotia": 0.14,
        "Nunavut": 0.05,
        "Ontario": 0.13,
        "Prince Edward Island": 0.15,
        "Quebec": 0.14975,
        "Saskatchewan": 0.11,
        "Yukon": 0.05
    ]

    var subtotal: Double {
        summaryItems.reduce(0) { total, item in
            total + (Double(item.price) ?? 0)
        }
    }

    var taxAmount: Double {
        let rate = provinces[selectedProvince] ?? 0
        let taxableTotal = summaryItems
            .filter { $0.taxable }
            .reduce(0) { total, item in
                total + (Double(item.price) ?? 0)
            }
        return taxableTotal * rate
    }

    var total: Double {
        subtotal + taxAmount
    }

    var taxRateText: String {
        String(format: "%.2f%%", (provinces[selectedProvince] ?? 0) * 100)
    }

    var taxAmountText: String {
        String(format: "$%.2f", taxAmount)
    }

    var body: some View {
        VStack(spacing: 0) {

            VStack(spacing: 18) {
                Spacer().frame(height: 40)

                Text("Summary")
                    .font(.system(size: 28, weight: .regular, design: .serif))
                    .foregroundColor(.white)

                    VStack(spacing: 12) {
                        if summaryItems.isEmpty {
                            VStack(spacing: 10) {
                                Text("Cart is empty")
                                    .font(.system(size: 20, weight: .regular, design: .serif))
                                    .foregroundColor(.white.opacity(0.8))

                                Text("Add products using +")
                                    .font(.system(size: 14))
                                    .foregroundColor(.white.opacity(0.5))
                            }
                            .padding(.top, 30)
                        } else {
                            ForEach($summaryItems) { $product in
                                TrackingRow(item: $product) {
                                    summaryItems.removeAll { $0.id == product.id }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 24)

                Divider()
                    .background(Color.white.opacity(0.3))
                    .padding(.horizontal, 24)

                HStack {
                    Text("Province")
                        .foregroundColor(.white.opacity(0.85))

                    Spacer()

                    Picker("", selection: $selectedProvince) {
                        ForEach(provinces.keys.sorted(), id: \.self) { province in
                            Text(province)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                .padding(.horizontal, 24)

                VStack(spacing: 10) {
                    SummaryRow(title: "Subtotal", value: String(format: "$%.2f", subtotal))

                    SummaryRow(
                        title: "Sales Tax",
                        value: "\(taxRateText)   \(taxAmountText)"
                    )
                }
                .padding(.horizontal, 24)

                Spacer()

                HStack {
                    Text("Total")
                        .font(.system(size: 26, weight: .regular, design: .serif))
                        .foregroundColor(.white)

                    Spacer()

                    Text(String(format: "$%.2f", total))
                        .font(.system(size: 26, weight: .regular, design: .serif))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 20)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            BottomBar(
                onHome: { withAnimation(.easeInOut) { currentScreen = .home } },
                onPlus: { withAnimation(.easeInOut) { currentScreen = .supplies } },
                onTracking: { withAnimation(.easeInOut) { currentScreen = .tracking } },
                currentScreen: currentScreen
            )
            .padding(.horizontal, 22)
            .padding(.bottom, 18)
        }
    }
}

struct SummaryTrackedItem: Identifiable {
    let id = UUID()
    let name: String
    var price: String
    var taxable: Bool
}

struct TrackingRow: View {
    @Binding var item: SummaryTrackedItem
    var onDelete: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text(item.name)
                    .font(.system(size: 18, design: .serif))
                    .foregroundColor(.white)

                Button {
                    item.taxable.toggle()
                } label: {
                    Text(item.taxable ? "Taxable" : "Non-taxable")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(
                            Capsule()
                                .fill(item.taxable ? Color.green.opacity(0.35) : Color.gray.opacity(0.35))
                        )
                }
                .buttonStyle(.plain)
            }

            Spacer()

            HStack(spacing: 4) {
                Text("$")
                    .foregroundColor(.white.opacity(0.7))

                TextField("", text: $item.price)
                    .keyboardType(.decimalPad)
                    .frame(width: 60)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.trailing)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color.white.opacity(0.12))
            .cornerRadius(8)

            Button {
                onDelete()
            } label: {
                Image(systemName: "trash.fill")
                    .foregroundColor(.white)
                    .padding(10)
                    .background(Color.red)
                    .clipShape(Circle())
            }
            .padding(.leading, 8)
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(14)
    }
}

struct SummaryRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.white.opacity(0.85))

            Spacer()

            Text(value)
                .foregroundColor(.white.opacity(0.85))
        }
    }
}
