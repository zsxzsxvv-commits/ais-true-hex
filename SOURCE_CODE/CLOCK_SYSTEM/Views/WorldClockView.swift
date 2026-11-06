import SwiftUI

public struct WorldClockView: View {
    @State private var cities: [WorldClockCity] = [
        WorldClockCity(cityName: "กรุงเทพฯ", countryName: "ไทย", timeZoneIdentifier: "Asia/Bangkok"),
        WorldClockCity(cityName: "โตเกียว", countryName: "ญี่ปุ่น", timeZoneIdentifier: "Asia/Tokyo"),
        WorldClockCity(cityName: "ลอนดอน", countryName: "สหราชอาณาจักร", timeZoneIdentifier: "Europe/London"),
        WorldClockCity(cityName: "นิวยอร์ก", countryName: "สหรัฐอเมริกา", timeZoneIdentifier: "America/New_York")
    ]
    
    @State private var isEditing = false
    @State private var showAddCitySheet = false
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                List {
                    ForEach(cities) { city in
                        HStack(alignment: .center) {
                            VStack(alignment: .leading, spacing: 3) {
                                Text(city.timeDifferenceDescription)
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                                Text(city.cityName)
                                    .font(.system(size: 26, weight: .medium))
                                    .foregroundColor(.white)
                            }
                            
                            Spacer()
                            
                            Text(city.formattedTime)
                                .font(.system(size: 54, weight: .light, design: .default))
                                .foregroundColor(.white)
                        }
                        .padding(.vertical, 8)
                        .listRowBackground(Color.black)
                    }
                    .onDelete(perform: deleteCity)
                }
                .listStyle(PlainListStyle())
            }
            .navigationTitle("นาฬิกาโลก")
            .navigationBarItems(
                leading: Button(isEditing ? "เสร็จสิ้น" : "แก้ไข") {
                    withAnimation { isEditing.toggle() }
                }
                .foregroundColor(.orange),
                trailing: Button(action: { showAddCitySheet = true }) {
                    Image(systemName: "plus")
                        .foregroundColor(.orange)
                        .font(.system(size: 18, weight: .semibold))
                }
            )
        }
    }
    
    private func deleteCity(at offsets: IndexSet) {
        cities.remove(atOffsets: offsets)
    }
}
