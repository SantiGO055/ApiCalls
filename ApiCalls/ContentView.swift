//
//  ContentView.swift
//  ApiCalls
//
//  Created by Santiago Gonzalez on 07/01/2024.
//

import SwiftUI

struct ContentView: View {
    @State private var user: GitHubUser?
    
    var body: some View {
        VStack {
            AsyncImage(url: URL(string: user?.avatarUrl ?? "")) { image in
                image.resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipShape(Circle())
            } placeholder: {
                Circle()
                    .foregroundColor(.secondary)
                    
            }
            .frame(width: 120,height: 120)

            
            Text(user?.login ?? "Login placeholder")
                .bold()
                .font(.title3)
            Text(user?.bio ?? "Bio placeholder")
                .padding()
            Spacer()
        }
        .padding()
        .task {
            do{
                user = try await getUser()
            } catch GHError.invalidURL{
                print("invalid url")
            } catch GHError.invalidData{
                print("invalid data")
            } catch GHError.invalidResponse{
                print("invalid response")
            }catch{
                print("unexpected error")
            }
        }
    }
    
    func getUser() async throws -> GitHubUser{
        let endpoint = "https://api.github.com/users/SantiGO055"
        
        guard let url = URL(string: endpoint) else { throw GHError.invalidURL }
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else{
            throw GHError.invalidResponse
        }
        
        do{
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase // para convertir de snake case a camel case avatar_url a avatarUrl
            print(String(data: data, encoding: .utf8))
            return try decoder.decode(GitHubUser.self, from: data)
            
        }
        catch{
            throw GHError.invalidData
        }
    }
}

struct GitHubUser: Codable{ //codable es para encode y decode data, decode es para traer la data json de un sv y encode es para mandar data al sv
    let login: String
    let avatarUrl: String
    let bio: String
    
}
enum GHError: Error{
    case invalidURL
    case invalidResponse
    case invalidData
}
#Preview {
    ContentView()
}
