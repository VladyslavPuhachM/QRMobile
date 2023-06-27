import SwiftUI
import Stripe
import Combine

// ViewModel do obsługi adresu wysyłki i płatności
class ShippingAddressViewModel: NSObject, ObservableObject, STPAuthenticationContext {
    @Published var paymentCardTextField = STPPaymentCardTextField()
    private let paymentIntentClientSecret = "your_client_secret_here"
    
    // Enum do wyboru metody płatności
    enum PaymentMethod {
        case card, cashOnDelivery
    }
    
    // Aktualizacja adresu wysyłki i metody płatności
    func updateShippingAddress(paymentMethod: PaymentMethod) {
        switch paymentMethod {
        case .card:
            payWithCard()
        case .cashOnDelivery:
            // Twój kod do obsługi płatności przy odbiorze
            print("Cash on delivery selected")
        }
    }
    
    // Płatność kartą
    private func payWithCard() {
        let cardParams = paymentCardTextField.paymentMethodParams.card
        let paymentMethodParams = STPPaymentMethodParams(card: cardParams!, billingDetails: nil, metadata: nil)
        let paymentIntentParams = STPPaymentIntentParams(clientSecret: paymentIntentClientSecret)
        paymentIntentParams.paymentMethodParams = paymentMethodParams
        
        // Tworzenie płatności
        let paymentHandler = STPPaymentHandler.shared()
        paymentHandler.confirmPayment(paymentIntentParams, with: self) { status, paymentIntent, error in
            switch status {
            case .succeeded:
                print("Payment succeeded")
            case .failed:
                print("Payment failed")
            case .canceled:
                print("Payment canceled")
            @unknown default:
                print("Unknown payment status")
            }
        }
    }
    
    // Funkcja potrzebna do STPAuthenticationContext
    func authenticationPresentingViewController() -> UIViewController {
        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        let windows = windowScene?.windows ?? []
        
        return windows.first?.rootViewController ?? UIViewController()
    }
}

// Widok adresu wysyłki
struct ShippingAddressView: View {
    @StateObject private var viewModel = ShippingAddressViewModel()
    
    @State private var paymentMethod: ShippingAddressViewModel.PaymentMethod = .card
    
    // Ciało widoku
    var body: some View {
        VStack {
            Form {
                // Sekcja z wyborem metody płatności
                Section(header: Text("Metoda płatności")) {
                    Picker("Wybierz metodę płatności", selection: $paymentMethod) {
                        Text("Karta").tag(ShippingAddressViewModel.PaymentMethod.card)
                        Text("Płatność gotówką przy odbiorze").tag(ShippingAddressViewModel.PaymentMethod.cashOnDelivery)
                    }
                }
                
                // Sekcja z danymi karty, jeśli wybrano płatność kartą
                if paymentMethod == .card {
                    Section(header: Text("Dane karty")) {
                        CardTextField(cardTextField: $viewModel.paymentCardTextField)
                    }
                }
            }
            Button("Zapłacić", action: { viewModel.updateShippingAddress(paymentMethod: paymentMethod) })
                .padding()
        }
    }
}

// Reprezentowalny widok UIKit dla STPPaymentCardTextField
struct CardTextField: UIViewRepresentable {
    @Binding var cardTextField: STPPaymentCardTextField
    
    func makeUIView(context: Context) -> STPPaymentCardTextField {
        return cardTextField
    }
    
    func updateUIView(_ uiView: STPPaymentCardTextField, context: Context) {
        uiView.borderColor = .clear
    }
}

// Podgląd do widoku ShippingAddressView
struct ShippingAddressView_Previews: PreviewProvider {
    static var previews: some View {
        ShippingAddressView()
    }
}
