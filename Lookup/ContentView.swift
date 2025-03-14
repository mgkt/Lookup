//
//  ContentView.swift
//  Lookup
//
//  Created by Hu, Shengliang on 07/03/2025.
//
import PDFKit
import SwiftUI
import SwiftData
import UniformTypeIdentifiers
//
//  LookupApp.swift
//  Lookup
//
//  Created by Hu, Shengliang on 07/03/2025.
//

struct ContentView: View {
    var body: some View {
        TabView {
            BookshelfView()
                .tabItem {
                    Label("Bookshelf", systemImage: "books.vertical")
                }
            
            InternetSearchView()
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
    }
}

struct BookshelfView: View {
    @State private var showImportView = false
    @State private var importedFiles: [URL] = []
    
    var body: some View {
        NavigationStack {
            List(importedFiles, id: \.self) { file in
                NavigationLink(destination: FileReaderView(fileURL: file)) {
                    Text(file.lastPathComponent)
                }
            }
            .navigationTitle("Bookshelf")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        showImportView = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showImportView) {
                ImportView()
            }
        }
    }
}


struct ImportView: View {
    @State private var selectedFiles: [URL] = []
    @State private var isFilePickerPresented = false
    
    var body: some View {
        VStack {
            Button(action: {
                isFilePickerPresented = true
            }) {
                Label("Select Files", systemImage: "doc.fill.badge.plus")
            }
            .padding()
            .fileImporter(
                isPresented: $isFilePickerPresented,
                allowedContentTypes: [
                    UTType.pdf,
                    UTType.plainText,
                    UTType.fileURL,  // 兼容所有文件类型
                    UTType.data
                ],
                allowsMultipleSelection: true
            ) { result in
                switch result {
                case .success(let urls):
                    selectedFiles.append(contentsOf: urls)
                case .failure(let error):
                    print("Error selecting files: \(error.localizedDescription)")
                }
            }
            
            List(selectedFiles, id: \.self) { file in
                Text(file.lastPathComponent)
            }
            
            Button("Add to Bookshelf") {
                addToBookshelf()
            }
            .padding()
        }
        .navigationTitle("Import Files")
    }
    
    private func addToBookshelf() {
        // 将选择的文件存入全局存储（例如 SwiftData）
        print("Files added: \(selectedFiles)")
    }
}

struct InternetSearchView: View {
    var body: some View {
        Text("Internet Search Page")
    }
}

struct SettingsView: View {
    var body: some View {
        Text("Settings Page")
    }
}



struct FileReaderView: View {
    let fileURL: URL
    
    var body: some View {
        if fileURL.pathExtension == "pdf" {
            PDFKitView(url: fileURL)
        } else if fileURL.pathExtension == "txt" {
            TextFileReader(url: fileURL)
        } else {
            Text("Unsupported file type")
        }
    }
}

// PDF 阅读器
struct PDFKitView: UIViewRepresentable {
    let url: URL
    
    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.document = PDFDocument(url: url)
        pdfView.autoScales = true
        return pdfView
    }
    
    func updateUIView(_ uiView: PDFView, context: Context) {}
}

// 文本阅读器
struct TextFileReader: View {
    let url: URL
    @State private var content: String = "Loading..."
    
    var body: some View {
        ScrollView {
            Text(content)
                .padding()
        }
        .onAppear {
            loadTextFile()
        }
    }
    
    private func loadTextFile() {
        do {
            content = try String(contentsOf: url, encoding: .utf8)
        } catch {
            content = "Failed to load text file."
        }
    }
}
