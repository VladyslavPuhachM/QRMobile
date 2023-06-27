import Foundation
import Combine

// Klasa APIService obsługująca różne żądania HTTP do API
class APIService: ObservableObject {
    // Podstawowy adres URL API
    let baseURL = "https://shopping-qr-api.azurewebsites.net"

    // Struktura reprezentująca produkt
    struct Product: Codable {
        let id: String
        let name: String
    }

    // Struktura reprezentująca zamówienie
    struct Order: Codable {
        let id: String
        let products: [Product]
    }
    
    // Metoda sprawdzająca poprawność identyfikatora
    private func isValidId(_ id: String) -> Bool {
        let idRegex = "^[a-zA-Z0-9-]+$"
        let idPredicate = NSPredicate(format: "SELF MATCHES %@", idRegex)
        return idPredicate.evaluate(with: id)
    }

    // Metoda pobierająca listę produktów
    func fetchProducts() -> AnyPublisher<[Product], Error> {
        let url = URL(string: "\(baseURL)/Products")!
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: [Product].self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }

    // Metoda pobierająca listę zamówień
    func fetchOrders() -> AnyPublisher<[Order], Error> {
        let url = URL(string: "\(baseURL)/Orders")!
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: [Order].self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
    
    // Metoda dodająca produkt do zamówienia
    func addProductToOrder(orderId: String, productId: String) -> Void {
        let url = URL(string: "\(baseURL)/Orders/AddProductToOrder")
        
        print("URL: \(url!)") // Wydrukowanie adresu URL przed żądaniem
        
        var request = URLRequest(url: url!)
        request.httpMethod = "PUT"
        request.addValue("api-key", forHTTPHeaderField:"Api-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Słownik JSON zawierający identyfikatory zamówienia i produktu
        let jsonDictionary: [String: String] = [
            "orderId": orderId,
            "productId": productId
        ]

        // Przekształcenie słownika JSON w dane
        let data = try! JSONSerialization.data(withJSONObject: jsonDictionary, options: .prettyPrinted)
        
        // Wysłanie żądania PUT
        URLSession.shared.uploadTask(with: request, from: data) { (responseData, response, error) in
            if let error = error {
                print("Error making PUT request: \(error.localizedDescription)")
                return
            }

            if let responseCode = (response as? HTTPURLResponse)?.statusCode, let responseData = responseData {
                guard responseCode == 200 else {
                    print("Invalid response code: \(responseCode)")
                    return
                }

                if let responseJSONData = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) {
                    print("Response JSON data = \(responseJSONData)")
                }
            }
        }.resume()
        
    }
}
