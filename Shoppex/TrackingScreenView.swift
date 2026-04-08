import SwiftUI

struct TrackingScreenView: View {
    @Binding var currentScreen: AppScreen
    @EnvironmentObject private var shoppingStore: ShoppingStore

    var subtotal: Double {
        shoppingStore.subtotal()
    }

    var taxAmount: Double {
        shoppingStore.taxAmount()
    }

    var total: Double {
        shoppingStore.total()
    }

    var taxRateText: String {
        shoppingStore.currentTaxRateText()
    }

    var taxAmountText: String {
        String(format: "$%.2f", taxAmount)
    }

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 18) {
                Spacer().frame(height: 40)

                Text("Shopping")
                    .font(.system(size: 28, weight: .regular, design: .serif))
                    .foregroundColor(.white)

                VStack(spacing: 12) {
                    if shoppingStore.draftItems.isEmpty {
                        VStack(spacing: 10) {
                            Text("Shopping list is empty")
                                .font(.system(size: 20, weight: .regular, design: .serif))
                                .foregroundColor(.white.opacity(0.8))

                            Text("Add products from Categories")
                                .font(.system(size: 14))
                                .foregroundColor(.white.opacity(0.5))
                        }
                        .padding(.top, 30)
                    } else {
                        ForEach($shoppingStore.draftItems) { $item in
                            TrackingRow(item: $item) {
                                shoppingStore.removeDraftItem(id: item.id)
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

                    Picker("", selection: $shoppingStore.selectedProvince) {
                        ForEach(ShoppingStore.provinceRates.keys.sorted(), id: \.self) { province in
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

                Button(action: shoppingStore.saveCurrentShopping) {
                    Text("Save Shopping")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(shoppingStore.draftItems.isEmpty ? Color.white.opacity(0.08) : Color(hex: "#0A84FF"))
                        )
                }
                .buttonStyle(.plain)
                .disabled(shoppingStore.draftItems.isEmpty)
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

struct TrackingRow: View {
    @Binding var item: TrackedShoppingItem
    var onDelete: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 8) {
                Text(item.productName)
                    .font(.system(size: 18, design: .serif))
                    .foregroundColor(.white)

                TextField("Item details", text: $item.itemName, prompt: Text("Describe purchase, e.g. Gala Apples 1.5kg").foregroundColor(.white.opacity(0.35)))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .background(Color.white.opacity(0.08))
                    .cornerRadius(8)

                TextField("Brand", text: $item.brand, prompt: Text("Brand").foregroundColor(.white.opacity(0.35)))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .background(Color.white.opacity(0.08))
                    .cornerRadius(8)

                TextField("Unit / size", text: $item.unit, prompt: Text("Unit / size").foregroundColor(.white.opacity(0.35)))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .background(Color.white.opacity(0.08))
                    .cornerRadius(8)

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

                TextField("Notes", text: $item.notes, prompt: Text("Add notes").foregroundColor(.white.opacity(0.35)))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .background(Color.white.opacity(0.08))
                    .cornerRadius(8)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 10) {
                HStack(spacing: 4) {
                    Text("$")
                        .foregroundColor(.white.opacity(0.7))

                    TextField("", text: $item.price)
                        .keyboardType(.decimalPad)
                        .frame(width: 72)
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
            }
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(14)
    }
}

struct SavedShoppingCard: View {
    let shopping: TrackedShopping

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text(shopping.purchasedAt)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)

                    Text(shopping.province)
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.5))
                }

                Spacer()

                Text(String(format: "$%.2f", shopping.total(provinceRates: ShoppingStore.provinceRates)))
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color(hex: "#4A90E2"))
            }

            ForEach(shopping.items) { item in
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(item.productName)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.white.opacity(0.9))

                        if !item.itemName.isEmpty {
                            Text(item.itemName)
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.6))
                        }

                        if !item.notes.isEmpty {
                            Text(item.notes)
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.45))
                        }
                    }

                    Spacer()

                    Text(String(format: "$%.2f", item.priceValue))
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.85))
                }
            }
        }
        .padding(14)
        .background(Color.white.opacity(0.06))
        .cornerRadius(16)
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
