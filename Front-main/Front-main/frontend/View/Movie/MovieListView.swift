//
//  MovieListView.swift
//  CineTome
//
//  Created by 596 on 22.04.2025.
//

import SwiftUI

struct MovieListView: View {
    @Binding var selectedTab: Tab
    @StateObject private var viewModel = ContentViewModel()

    var body: some View {
        NavigationStack {
            VStack {
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let error = viewModel.errorMessage {
                    ErrorView(error: error)
                        .onAppear {
                            print("Error displayed: \(error)") // Отладка
                        }
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            if let popSeries = viewModel.seriesCollections[.pop], !popSeries.isEmpty {
                                ContentCollectionView(title: "Популярные сериалы", items: popSeries)
                                    .padding(.horizontal)
                            } else {
                                Text("Нет популярных сериалов")
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal)
                            }

                            if let bestSeries = viewModel.seriesCollections[.best], !bestSeries.isEmpty {
                                ContentCollectionView(title: "Топ-250 сериалов", items: bestSeries)
                                    .padding(.horizontal)
                            } else {
                                Text("Нет топ-250 сериалов")
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal)
                            }

                            if let popMovies = viewModel.collections[.pop], !popMovies.isEmpty {
                                ContentCollectionView(title: "Популярные фильмы", items: popMovies)
                                    .padding(.horizontal)
                            } else {
                                Text("Нет популярных фильмов")
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal)
                            }

                            if let newMovies = viewModel.collections[.new], !newMovies.isEmpty {
                                ContentCollectionView(title: "Ожидаемые фильмы", items: newMovies)
                                    .padding(.horizontal)
                            } else {
                                Text("Нет ожидаемых фильмов")
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal)
                            }

                            if let bestMovies = viewModel.collections[.best], !bestMovies.isEmpty {
                                ContentCollectionView(title: "Топ-250 фильмов", items: bestMovies)
                                    .padding(.horizontal)
                            } else {
                                Text("Нет топ-250 фильмов")
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal)
                            }

                            if let familyMovies = viewModel.collections[.family], !familyMovies.isEmpty {
                                ContentCollectionView(title: "Семейные фильмы", items: familyMovies)
                                    .padding(.horizontal)
                            } else {
                                Text("Нет семейных фильмов")
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal)
                            }

                            if let vampireMovies = viewModel.collections[.vampire], !vampireMovies.isEmpty {
                                ContentCollectionView(title: "Фильмы про вампиров", items: vampireMovies)
                                    .padding(.horizontal)
                            } else {
                                Text("Нет фильмов про вампиров")
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal)
                            }

                            if let loveMovies = viewModel.collections[.love], !loveMovies.isEmpty {
                                ContentCollectionView(title: "Романтические фильмы", items: loveMovies)
                                    .padding(.horizontal)
                            } else {
                                Text("Нет романтических фильмов")
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal)
                            }

                            if let zombieMovies = viewModel.collections[.zombie], !zombieMovies.isEmpty {
                                ContentCollectionView(title: "Фильмы про зомби", items: zombieMovies)
                                    .padding(.horizontal)
                            } else {
                                Text("Нет фильмов про зомби")
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal)
                            }

                            if let comicsMovies = viewModel.collections[.comics], !comicsMovies.isEmpty {
                                ContentCollectionView(title: "Фильмы по комиксам", items: comicsMovies)
                                    .padding(.horizontal)
                            } else {
                                Text("Нет фильмов по комиксам")
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal)
                            }

                            if let oskarMovies = viewModel.collections[.oskar], !oskarMovies.isEmpty {
                                ContentCollectionView(title: "Победители Оскара 2021", items: oskarMovies)
                                    .padding(.horizontal)
                            } else {
                                Text("Нет победителей Оскара 2021")
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal)
                            }

                            if let releasesMovies = viewModel.collections[.releases], !releasesMovies.isEmpty {
                                ContentCollectionView(title: "Новинки", items: releasesMovies)
                                    .padding(.horizontal)
                            } else {
                                Text("Нет новинок")
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal)
                            }
                        }
                        .padding(.vertical)
                    }
                }
            }
            .navigationTitle("Фильмы")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: SearchContentView()) {  // Убрали параметр items
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.blue)
                    }
                }
            }
            .task {
                await viewModel.loadCollections()
                print("Collections loaded: \(viewModel.collections.count) movie collections, \(viewModel.seriesCollections.count) series collections") // Отладка
            }
        }
    }
}

