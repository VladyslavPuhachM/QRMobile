import SwiftUI
import AVFoundation
import Combine
import Foundation

// Struktura reprezentująca wynik skanowania kodu QR
struct QRCodeResult: Decodable {
    let productId: String
    let orderId: String
}

// Główny widok aplikacji
struct ContentView: View {
    @StateObject private var apiService = APIService()
    @State private var cancellables = Set<AnyCancellable>()

    @State private var isShowingScanner = false
    @State private var scannedProducts: [String] = []
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var showAddressSettings = false
    @State private var showPaymentSettings = false

    @State private var backgroundColor: Color = .black

    private let maxProducts = 20

    var body: some View {
        GeometryReader { geometry in
            NavigationView {
                VStack {
                    HStack {
                        Text("Zeskanowane towary")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(backgroundColor == .black ? .white : .black)

                        Spacer()

                        // Menu z różnymi opcjami
                        Menu {
                            Button(action: {
                                showAddressSettings = true
                            }) {
                                Label("Ustawienia adresu", systemImage: "location.circle")
                            }

                            Button(action: {
                                showPaymentSettings = true
                            }) {
                                Label("Ustawienie danych oplate", systemImage: "creditcard")
                            }

                            Button(action: {
                                backgroundColor = backgroundColor == .black ? .white : .black
                            }) {
                                Label("Zmień tło", systemImage: "circle.lefthalf.fill")
                            }

                        } label: {
                            Image(systemName: "gear")
                                .font(.system(size: 24))
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .clipShape(Circle())
                                .shadow(radius: 5)
                        }
                        .padding(.trailing, geometry.safeAreaInsets.trailing)
                    }
                    .padding(.horizontal)

                    // Lista zeskanowanych produktów
                    List {
                        ForEach(scannedProducts, id: \.self) { product in
                            NavigationLink(destination: ShippingAddressView()) {
                                Text("Test")

                                Spacer()

                                // Przycisk do usuwania produktu z listy
                                Button(action: {
                                    if let index = scannedProducts.firstIndex(of: product) {
                                        scannedProducts.remove(at: index)
                                    }
                                }) {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                        .font(.footnote)
                                }
                                .buttonStyle(BorderlessButtonStyle())
                            }
                        }
                    }
                    .padding(.top, -10) // Redukcja górnego marginesu

                    HStack {
                        // Przycisk do skanowania produktu
                        Button(action:{
                            isShowingScanner = true
                        }) {
                            Text("Zeskanuj produkt")
                                .font(.headline)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .padding(.trailing, 8)

                        Spacer()

                        // Przycisk do czyszczenia listy produktów
                        Button(action: {
                            scannedProducts.removeAll()
                        }) {
                            Text("Wyczyść listę")
                                .font(.headline)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.red)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .padding(.leading, 8)
                    }
                    .padding()
                    .disabled(scannedProducts.count >= maxProducts)
                }
                .background(backgroundColor.edgesIgnoringSafeArea(.all))
                .navigationTitle("")
                .navigationBarHidden(true)
                .sheet(isPresented: $isShowingScanner) {
                    QRScannerView { code in
                        if scannedProducts.count < maxProducts {
                            if !scannedProducts.contains(code) {
                                scannedProducts.append(code)
                                isShowingScanner = false
                                let result = try! JSONDecoder().decode(QRCodeResult.self, from: code.data(using: .utf8)!)

                                addProductToOrder(orderId: result.orderId, productId: result.productId)
                            } else {
                                alertMessage = "Produkt został już wcześniej zeskanowany"
                                showAlert = true
                            }
                        } else {
                            isShowingScanner = false
                        }
                    }
                }
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("Ostrzeżenie"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                }
                .sheet(isPresented: $showAddressSettings) {
                    ShippingAddressView()
                }
                .sheet(isPresented: $showPaymentSettings) {
                    PaymentSettingsView()
                }
            }
        }
    }

    // Funkcja do dodawania produktu do zamówienia
    private func addProductToOrder(orderId: String, productId: String) {
        apiService.addProductToOrder(orderId: orderId, productId: productId)
            /*.sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print("Error: \(error.localizedDescription)")
                }
            }, receiveValue: { _ in })
            .store(in: &cancellables)
             */
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
