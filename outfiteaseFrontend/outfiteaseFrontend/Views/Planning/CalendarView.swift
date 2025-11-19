import SwiftUI

struct CalendarView: View {
    @StateObject private var planningViewModel = PlanningViewModel()
    @State private var selectedDate = Date()
    @State private var currentMonth = Date()
    @State private var showAddPlan = false
    @State private var showYearPicker = false
    
    private var plansForSelectedDate: [OutfitPlan] {
        let plans = planningViewModel.outfitPlans.filter { plan in
            // Filter plans for the selected date
            let planDate = plan.plannedDate
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let selectedDateString = formatter.string(from: selectedDate)
            
            print("🔍 Checking plan: \(plan.outfitName ?? "Unknown")")
            print("🔍 Plan date: \(planDate)")
            print("🔍 Selected date string: \(selectedDateString)")
            
            // Handle both ISO date format and simple date format
            if planDate.contains("T") {
                let planDateString = String(planDate.prefix(10))
                    let matches = planDateString == selectedDateString
                print("📅 Comparing ISO: \(planDateString) == \(selectedDateString) = \(matches)")
                return matches
            }
            
            let matches = planDate == selectedDateString
            print("📅 Comparing simple: \(planDate) == \(selectedDateString) = \(matches)")
            return matches
        }
        
        print("📅 Total plans available: \(planningViewModel.outfitPlans.count)")
        print("📅 Selected date: \(selectedDate)")
        print("📅 Plans for selected date: \(plans.count)")
        
        return plans
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Calendar Header
                VStack(spacing: 16) {
                    Text("Outfit Planning")
                        .font(.appHeadline2)
                    
                    // Month Navigation
                    HStack {
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                currentMonth = Calendar.current.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
                            }
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.title2)
                                .foregroundColor(.blue)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            showYearPicker = true
                        }) {
                            Text(currentMonth.formatted(.dateTime.month(.wide).year()))
                                .font(.appHeadline3)
                                .foregroundColor(.blue)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                currentMonth = Calendar.current.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
                            }
                        }) {
                            Image(systemName: "chevron.right")
                                .font(.title2)
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Quick Navigation
                    HStack(spacing: 12) {
                        Button("Today") {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                currentMonth = Date()
                                selectedDate = Date()
                            }
                        }
                        .font(.appButtonSmall)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        
                        Button("1 Year Ago") {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                currentMonth = Calendar.current.date(byAdding: .year, value: -1, to: Date()) ?? Date()
                            }
                        }
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.gray.opacity(0.2))
                        .foregroundColor(.primary)
                        .cornerRadius(8)
                        
                        Button("6 Months Ago") {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                currentMonth = Calendar.current.date(byAdding: .month, value: -6, to: Date()) ?? Date()
                            }
                        }
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.gray.opacity(0.2))
                        .foregroundColor(.primary)
                        .cornerRadius(8)
                        
                        Button("3 Years Ago") {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                currentMonth = Calendar.current.date(byAdding: .year, value: -3, to: Date()) ?? Date()
                            }
                        }
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.gray.opacity(0.2))
                        .foregroundColor(.primary)
                        .cornerRadius(8)
                    }
                    .padding(.horizontal)
                    
                    // Simple Calendar View
                    CalendarGridView(selectedDate: $selectedDate, currentMonth: $currentMonth, planningViewModel: planningViewModel)
                }
                .padding()
                
                // Planned Outfits for Selected Date
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Planned for \(selectedDate.formatted(date: .abbreviated, time: .omitted))")
                            .font(.headline)
                        
                        Spacer()
                        
                        Button("Add Plan") {
                            showAddPlan = true
                        }
                        .font(.caption)
                        .foregroundColor(.blue)
                    }
                    
                    if planningViewModel.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity, maxHeight: 100)
                    } else {
                        if plansForSelectedDate.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "calendar.badge.plus")
                                    .font(.system(size: 40))
                                    .foregroundColor(.gray)
                                
                                Text("No outfits planned")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                Text("Tap 'Add Plan' to schedule an outfit")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity, maxHeight: 150)
                        } else {
                            ScrollView {
                                LazyVStack(spacing: 16) {
                                    ForEach(plansForSelectedDate) { plan in
                                        PlannedOutfitCard(plan: plan, planningViewModel: planningViewModel)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                }
                .padding()
                
                Spacer()
            }
            .navigationTitleFont("Planning")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: WeatherView()) {
                        Image(systemName: "cloud.sun.fill")
                            .foregroundColor(.blue)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showAddPlan) {
                AddPlanView(selectedDate: selectedDate, planningViewModel: planningViewModel)
            }
            .sheet(isPresented: $showYearPicker) {
                YearPickerView(currentMonth: $currentMonth)
            }
            .task {
                await planningViewModel.loadOutfitPlans()
            }
        }

    }
}

struct CalendarGridView: View {
    @Binding var selectedDate: Date
    @Binding var currentMonth: Date
    let planningViewModel: PlanningViewModel
    
    private let calendar = Calendar.current
    private let daysInWeek = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    
    var body: some View {
        VStack(spacing: 8) {
            // Day headers
            HStack {
                ForEach(daysInWeek, id: \.self) { day in
                    Text(day)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                }
            }
            
            // Calendar grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                ForEach(getDaysInMonth(), id: \.self) { date in
                    if let date = date {
                        DayCell(
                            date: date,
                            isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                            hasEvents: hasPlannedOutfits(for: date)
                        )
                        .onTapGesture {
                            selectedDate = date
                        }
                    } else {
                        Color.clear
                            .frame(height: 40)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private func getDaysInMonth() -> [Date?] {
        let startOfMonth = calendar.dateInterval(of: .month, for: currentMonth)?.start ?? currentMonth
        let firstWeekday = calendar.component(.weekday, from: startOfMonth)
        let daysInMonth = calendar.range(of: .day, in: .month, for: currentMonth)?.count ?? 30
        
        var days: [Date?] = []
        
        // Add empty cells for days before the first day of the month
        for _ in 1..<firstWeekday {
            days.append(nil)
        }
        
        // Add all days in the month
        for day in 1...daysInMonth {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: startOfMonth) {
                days.append(date)
            }
        }
        
        return days
    }
    
    private func hasPlannedOutfits(for date: Date) -> Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: date)

        return planningViewModel.outfitPlans.contains { plan in
            let planDate = plan.plannedDate
            if planDate.contains("T") {
                return String(planDate.prefix(10)) == dateString
            }
            return planDate == dateString
        }
    }
}

struct DayCell: View {
    let date: Date
    let isSelected: Bool
    let hasEvents: Bool
    
    private let calendar = Calendar.current
    
    var body: some View {
        VStack {
            Text("\(calendar.component(.day, from: date))")
                .font(.caption)
                .fontWeight(isSelected ? .bold : .medium)
                .foregroundColor(isSelected ? .white : .primary)
                .frame(width: 30, height: 30)
                .background(
                    Circle()
                        .fill(isSelected ? Color.blue : Color.clear)
                )
                .overlay(
                    Circle()
                        .stroke(hasEvents ? Color.orange : Color.clear, lineWidth: 2)
                )
        }
    }
}

struct PlannedOutfitCard: View {
    let plan: OutfitPlan
    let planningViewModel: PlanningViewModel
    
    var body: some View {
        NavigationLink(destination: OutfitDetailView(outfit: createOutfitFromPlan(plan), outfitViewModel: OutfitViewModel())) {
            HStack {
            // Outfit image or placeholder
            if let imageURL = plan.outfitImageURL, !imageURL.isEmpty {
                AsyncImage(url: URL(string: imageURL)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 60, height: 60)
                        .clipped()
                } placeholder: {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 60, height: 60)
                        .overlay(
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                                .scaleEffect(0.7)
                        )
                }
                .cornerRadius(8)
                .onAppear {
                    print("🖼️ Loading image for plan: \(plan.outfitName ?? "Unknown")")
                    print("🖼️ Image URL: \(imageURL)")
                }
            } else {
                // Placeholder for outfit image
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 60, height: 60)
                    .overlay(
                        Image(systemName: "person.2.fill")
                            .foregroundColor(.gray)
                    )
                    .onAppear {
                        print("❌ No image URL for plan: \(plan.outfitName ?? "Unknown")")
                        print("❌ outfitImageURL: \(plan.outfitImageURL ?? "nil")")
                    }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(plan.title ?? plan.outfitName ?? "Untitled Outfit")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                if let description = plan.outfitDescription {
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                if let style = plan.outfitStyle, !style.isEmpty {
                    Text(style.joined(separator: ", "))
                        .font(.caption2)
                        .foregroundColor(.blue)
                }
                
                if let totalPrice = plan.outfitTotalPrice {
                    Text("$\(totalPrice, specifier: "%.2f")")
                        .font(.caption2)
                        .foregroundColor(.green)
                        .fontWeight(.medium)
                }
            }
            
            Spacer()
            
            Button("Remove") {
                Task {
                    await planningViewModel.deleteOutfitPlan(id: plan.id)
                }
            }
            .font(.caption)
            .foregroundColor(.red)
            .simultaneousGesture(TapGesture().onEnded { _ in
                // This prevents the NavigationLink from being triggered
            })
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func createOutfitFromPlan(_ plan: OutfitPlan) -> Outfit {
        return Outfit(
            id: UUID(uuidString: plan.outfitId) ?? UUID(),
            userId: UUID(uuidString: plan.userId) ?? UUID(),
            name: plan.outfitName ?? "Untitled Outfit",
            description: plan.outfitDescription,
            totalPrice: plan.outfitTotalPrice,
            style: plan.outfitStyle ?? [],
            color: plan.outfitColor ?? [],
            brand: plan.outfitBrand ?? [],
            season: plan.outfitSeason ?? [],
            occasion: plan.outfitOccasion ?? [],
            imageURL: plan.outfitImageURL,
            createdAt: ""
        )
    }
}

struct AddPlanView: View {
    let selectedDate: Date
    @ObservedObject var planningViewModel: PlanningViewModel
    @Environment(\.dismiss) private var dismiss
    @StateObject private var outfitViewModel = OutfitViewModel()
    @State private var selectedOutfitId: UUID?
    @State private var eventTitle = ""
    @State private var isLoading = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Add outfit plan for \(selectedDate.formatted(date: .abbreviated, time: .omitted))")
                    .font(.headline)
                    .padding(.top)
                
                // Event Title
                VStack(alignment: .leading, spacing: 8) {
                    Text("Event Title")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    TextField("e.g., Brunch with Ella, Work Meeting, Date Night", text: $eventTitle)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                }
                .padding(.horizontal)
                
                outfitListView
                
                Spacer()
            }
            .navigationTitle("Add Plan")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        savePlan()
                    }
                    .disabled(selectedOutfitId == nil || isLoading)
                }
            }
        }
        .task {
            await outfitViewModel.loadOutfits()
        }
        .alert("Error", isPresented: .constant(planningViewModel.errorMessage != nil)) {
            Button("OK") {
                planningViewModel.errorMessage = nil
            }
        } message: {
            Text(planningViewModel.errorMessage ?? "")
        }
    }
    
    @ViewBuilder
    private var outfitListView: some View {
        if outfitViewModel.isLoading {
            ProgressView("Loading outfits...")
                .frame(maxWidth: .infinity, maxHeight: 200)
        } else if outfitViewModel.outfits.isEmpty {
            VStack(spacing: 16) {
                Image(systemName: "person.2.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.gray)
                
                Text("No Outfits Available")
                    .font(.title3)
                    .fontWeight(.semibold)
                
                Text("Create some outfits first to plan them")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity, maxHeight: 200)
        } else {
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(outfitViewModel.outfits) { outfit in
                        OutfitPlanSelectionCard(
                            outfit: outfit,
                            isSelected: selectedOutfitId == outfit.id,
                            onSelect: {
                                selectedOutfitId = outfit.id
                            }
                        )
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    private func savePlan() {
        guard let outfitId = selectedOutfitId else { return }
        
        isLoading = true
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: selectedDate)
        
        let plan = CreateOutfitPlanRequest(
            outfitId: outfitId.uuidString,
            plannedDate: dateString,
            title: eventTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : eventTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        
        print("📅 Calendar AddPlan creating request:")
        print("  - outfitId: \(outfitId.uuidString)")
        print("  - plannedDate: \(dateString)")
        print("  - eventTitle: '\(eventTitle)'")
        print("  - title: \(eventTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "nil" : "'\(eventTitle.trimmingCharacters(in: .whitespacesAndNewlines))'")")
        
        Task {
            await planningViewModel.addOutfitPlan(plan)
            if planningViewModel.errorMessage == nil {
                dismiss()
            }
            isLoading = false
        }
    }
}

struct OutfitPlanSelectionCard: View {
    let outfit: Outfit
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack {
                // Outfit image
                if let imageURL = outfit.imageURL, !imageURL.isEmpty {
                    AsyncImage(url: URL(string: imageURL)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 60, height: 60)
                            .clipped()
                            .cornerRadius(8)
                    } placeholder: {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 60, height: 60)
                            .overlay(
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                                    .scaleEffect(0.7)
                            )
                    }
                    .onAppear {
                        print("🖼️ Loading outfit image: \(outfit.name ?? "Unknown")")
                        print("🖼️ Outfit image URL: \(imageURL)")
                    }
                } else {
                    // Placeholder when no image
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 60, height: 60)
                        .overlay(
                            Image(systemName: "person.2.fill")
                                .foregroundColor(.gray)
                        )
                        .onAppear {
                            print("❌ No outfit image URL: \(outfit.name ?? "Unknown")")
                            print("❌ outfit.imageURL: \(outfit.imageURL ?? "nil")")
                        }
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(outfit.name ?? "Untitled Outfit")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    if let description = outfit.description {
                        Text(description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                    
                    if let style = outfit.style, !style.isEmpty {
                        Text(style.joined(separator: ", "))
                            .font(.caption2)
                            .foregroundColor(.blue)
                    }
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.blue)
                        .font(.title2)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.blue.opacity(0.1) : Color(.systemGray6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct YearPickerView: View {
    @Binding var currentMonth: Date
    @Environment(\.dismiss) private var dismiss
    
    private let calendar = Calendar.current
    private let currentYear = Calendar.current.component(.year, from: Date())
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Select Year")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding(.top)
                
                ScrollView {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 16) {
                        ForEach((currentYear - 10)...(currentYear + 5), id: \.self) { year in
                            Button(action: {
                                // Set to January of the selected year
                                if let newDate = calendar.date(from: DateComponents(year: year, month: 1, day: 1)) {
                                    currentMonth = newDate
                                }
                                dismiss()
                            }) {
                                Text(String(year))
                                    .font(.title3)
                                    .fontWeight(.medium)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(year == currentYear ? Color.blue : Color.gray.opacity(0.2))
                                    )
                                    .foregroundColor(year == currentYear ? .white : .primary)
                            }
                        }
                    }
                    .padding()
                }
                
                Spacer()
            }
            .navigationTitle("Year Picker")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    CalendarView()
        .environmentObject(PlanningViewModel())
}
