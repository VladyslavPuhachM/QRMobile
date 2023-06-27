import Foundation
import SwiftUI
import Stripe

// Reprezentacja pola tekstowego karty płatniczej Stripe jako widok SwiftUI
struct PaymentCardTextFieldRepresentable: UIViewRepresentable {
    @Binding var cardNumber: String
    @Binding var expirationDate: String
    @Binding var cvv: String

    // Tworzenie koordynatora do obsługi zdarzeń
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    // Tworzenie widoku UIKit, który ma być reprezentowany
    func makeUIView(context: Context) -> STPPaymentCardTextField {
        let paymentCardTextField = STPPaymentCardTextField()
        paymentCardTextField.delegate = context.coordinator
        return paymentCardTextField
    }
    
    // Aktualizacja widoku UIKit
    func updateUIView(_ uiView: STPPaymentCardTextField, context: Context) {
    }

    // Klasa koordynatora obsługująca zdarzenia związane z polami tekstowymi karty płatniczej
    class Coordinator: NSObject, STPPaymentCardTextFieldDelegate {
        var parent: PaymentCardTextFieldRepresentable

        // Inicjalizacja koordynatora z referencją do nadrzędnego widoku
        init(_ parent: PaymentCardTextFieldRepresentable) {
            self.parent = parent
        }

        // Metoda wywoływana, gdy zawartość pola tekstowego karty płatniczej ulegnie zmianie
        func paymentCardTextFieldDidChange(_ textField: STPPaymentCardTextField) {
            parent.cardNumber = textField.cardNumber ?? ""
            parent.expirationDate = "\(textField.expirationMonth)/\(textField.expirationYear)"
            parent.cvv = textField.cvc ?? ""
        }
    }
}
