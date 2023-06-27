import Foundation
import SwiftUI
// Widok ustawień adresu
struct AddressSettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var streetAddress = ""
    @State private var city = ""
    @State private var zipCode = ""

    // Ciało widoku
    var body: some View {
        NavigationView {
            Form {
                // Sekcja z danymi adresu wysyłki
                Section(header: Text("Wpisz swój adres wysyłki")) {
                    TextField("Ulica, dom, mieszkanie", text: $streetAddress)
                    TextField("Miasto", text: $city)
                    TextField("Kod pocztowy", text: $zipCode)
                }

                // Przyciski zapisu i odrzucenia
                HStack {
                    Button(action: {
                        // Dodaj logikę zapisywania adresu wysyłki
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Save")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }

                    Spacer()

                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Odrzucić")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding()
            }
            .navigationBarTitle("Ustawienia adresu", displayMode: .inline)
        }
    }
}
