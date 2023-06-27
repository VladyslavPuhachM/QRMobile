import Foundation
import SwiftUI
import Combine

// Widok ustawień płatności
struct PaymentSettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel = ShippingAddressViewModel()
    @State private var cardHolderName = ""
    @State private var cardNumber = ""
    @State private var expirationDate = ""
    @State private var cvv = ""
    // Ciało widoku
    var body: some View {
        NavigationView {
            Form {
                // Sekcja z danymi karty płatniczej
                Section(header: Text("Wprowadź dane swojej karty płatniczej")) {
                    TextField("Nazwa właściciela", text: $cardHolderName)
                    PaymentCardTextFieldRepresentable(cardNumber: $cardNumber, expirationDate: $expirationDate, cvv: $cvv)
                }
                // Przyciski zapisu i odrzucenia
                HStack {
                    Button(action: {
                        // Dodaj logikę zapisywania danych karty płatniczej
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
            .navigationBarTitle("Ustawienia płatności", displayMode: .inline)
        }
    }
}
