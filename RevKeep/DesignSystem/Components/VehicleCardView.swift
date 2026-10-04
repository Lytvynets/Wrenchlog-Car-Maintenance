

import SwiftUI

struct VehicleCardView: View {
    let vehicle: Vehicle
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: RevRadius.chip, style: .continuous)
                .fill(Color.revGraphiteLight)
            
            if let data = vehicle.photoData, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            } else {
                Image(systemName: "car.side.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(Color.revSlate)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            
            LinearGradient(
                colors: [Color.black.opacity(0.6), Color.black.opacity(0)],
                startPoint: .bottom,
                endPoint: .top
            )
            .frame(height: 38)
            .frame(maxWidth: .infinity, alignment: .bottom)
            .allowsHitTesting(false)
            
            VStack(alignment: .leading, spacing: 1) {
                Text(vehicle.displayName)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 1)
                
                if let plate = vehicle.licensePlate, !plate.isEmpty {
                    Text(plate)
                        .font(.system(size: 9, weight: .medium, design: .monospaced))
                        .foregroundStyle(.white.opacity(0.85))
                        .lineLimit(1)
                        .shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 1)
                }
            }
            .padding(.horizontal, 8)
            .padding(.bottom, vehicle.licensePlate != nil ? 6 : 20)
        }
        .frame(width: 140, height: 75)
        .clipShape(RoundedRectangle(cornerRadius: RevRadius.chip, style: .continuous))
    }
}



struct AddVehicleCardView: View {
    var body: some View {
        VStack(spacing: RevSpacing.sm) {
            Image(systemName: "plus")
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(Color.revAmber)
            Text("Add car")
                .font(.revCaption)
                .foregroundStyle(Color.revAmber)
        }
        .frame(width: 140, height: 75)
        .background(
            RoundedRectangle(cornerRadius: RevRadius.chip, style: .continuous)
                .strokeBorder(Color.revAmber, style: StrokeStyle(lineWidth: 1.5, dash: [6, 4]))
        )
    }
}
