//
//  ContentView.swift
//  Query_Response
//
//  Created by Ahmad Azam on 13/03/2024.
//
import SwiftUI
import WebKit

struct GenderCheckerView: View {
    @StateObject private var viewModel = GenderViewModel()
    @State private var isWebViewPresented = false
    @State private var isFetchingData = false
    @State private var showAlert = false
    @State private var errorMessage = ""

    var body: some View {
        NavigationStack {
            VStack {
                TextField("Please enter your name", text: $viewModel.name)
                    .textFieldStyle(.roundedBorder)
                    .padding()
                
                Button(action: {
                    if viewModel.name.isEmpty {
                        errorMessage = "Please enter a name."
                        showAlert = true
                    } else {
                        Task {
                            isFetchingData = true
                            do {
                                try await viewModel.fetchGender()
                                isWebViewPresented = true
                            } catch {
                                showAlert = true
                                switch error {
                                case GenderNetworkServiceError.genderNotFound:
                                    errorMessage = "Gender Not Found"
                                case GenderNetworkServiceError.invalidURL:
                                    errorMessage = "Invalid Request"
                                case GenderNetworkServiceError.networkError(let error):
                                    errorMessage = "\(error.localizedDescription)"
                                default:
                                    errorMessage = "Some unknown issue"
                                }
                            }
                            isFetchingData = false
                        }
                    }
                }) {
                    Text("Check Gender")
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.purple)
                        .cornerRadius(25)
                }
                .padding()
                
                if isFetchingData {
                    ProgressView()
                        .padding()
                }
                
                Spacer()
            }
            .padding()
            .ignoresSafeArea(.keyboard)
            .navigationBarTitle("Gender Checker", displayMode: .inline)
            .navigationDestination(isPresented: $isWebViewPresented, destination: {
                WebView(htmlContent: viewModel.genderInfoHTML)
            })
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
            }
            .onAppear {
                viewModel.name = ""
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        GenderCheckerView()
    }
}
