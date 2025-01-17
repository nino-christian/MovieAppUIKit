//
//  HomeScreenViewController.swift
//  MovieAppUIKit
//
//  Created by Niño Christian Amahan on 11/18/24.
//

import UIKit
import Combine
import CoreData

class HomeScreenViewController: UIViewController {
    
    enum CollectionViewType: CaseIterable {
        case favorites
        case movieList
    }

    @IBOutlet weak var favoritesCollectionView: UICollectionView!
    @IBOutlet weak var movieListCollectitonView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var movieListInitialView: UIView!
    @IBOutlet weak var movieListLoaderView: UIView!
    @IBOutlet weak var movieListEmptyView: UIView!
    @IBOutlet weak var movieListErrorView: UIView!
    

    @IBOutlet weak var favoriteMoviewListLoaderView: UIView!
    @IBOutlet weak var favoriteMovieListErrorView: UIView!
    @IBOutlet weak var favoriteMovieListEmptyView: UIView!
    
    private var cancellables: Set<AnyCancellable> = []
    private var searchTextPublisher =  PassthroughSubject<String, Never>()
    private var movieCollectionDataSource: UICollectionViewDiffableDataSource<CollectionViewType, MovieModel>!
    
    private var homeScreenViewModel: HomeScreenViewModel
    
    var fetchedResultsController: NSFetchedResultsController<MovieEntity>?
    
    init(homeScreenViewModel: HomeScreenViewModel) {
        self.homeScreenViewModel = homeScreenViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureDataSource()
        setupFetchController()
        setupObservable()
        setUpSearchBar()
        setupViews()
       
    }

    
}

// MARK: UI CONFIGURATIONS

extension HomeScreenViewController {
    func setupViews() {
        self.title = "Home"
        
        setupNavigationBar()
        setupCollectionViews()
    }
    
    func setupNavigationBar() {
        let leftNavBarItem = UIBarButtonItem(image: UIImage(systemName: "gearshape"), style: .plain, target: self, action: #selector(showSettings))
        navigationItem.leftBarButtonItem = leftNavBarItem
        
        let rightNavBarItem = UIBarButtonItem(image: UIImage(systemName: "star"), style: .plain, target: self, action: #selector(showFavorites))
        navigationItem.rightBarButtonItem = rightNavBarItem
        
    }
    
    func setupCollectionViews() {
        
        let favoritesCollectionViewFlowLayout = UICollectionViewFlowLayout()
        favoritesCollectionViewFlowLayout.scrollDirection = .horizontal
        favoritesCollectionViewFlowLayout.minimumInteritemSpacing = 3
        favoritesCollectionViewFlowLayout.minimumLineSpacing = 5
        favoritesCollectionViewFlowLayout.itemSize = CGSize(width: 80, height: 100)
        favoritesCollectionView.collectionViewLayout = favoritesCollectionViewFlowLayout
        favoritesCollectionView.delegate = self
        favoritesCollectionView.dataSource = self
        favoritesCollectionView.showsHorizontalScrollIndicator = false
        favoritesCollectionView.register(UINib(nibName: "FavoritesCollectionViewCell", bundle: nil),
                                         forCellWithReuseIdentifier: FavoritesCollectionViewCell.identifier)
        
//        let movieListCollectionViewFlowLayout = UICollectionViewFlowLayout()
//        movieListCollectionViewFlowLayout.scrollDirection = .vertical
//        movieListCollectionViewFlowLayout.minimumInteritemSpacing = 5
//        movieListCollectionViewFlowLayout.minimumLineSpacing = 5
//        let itemWidth = (movieListCollectitonView.frame.width) / 2
//        let itemHeight = 250.0
//        movieListCollectionViewFlowLayout.itemSize = CGSize(width: itemWidth, height: itemHeight)
        movieListCollectitonView.collectionViewLayout = createMovieCollectionView()
        movieListCollectitonView.showsVerticalScrollIndicator = false
        movieListCollectitonView.delegate = self
    }
    
//    func configCollectionViewLayout() -> UICollectionViewLayout {
//        
//    }
}

extension HomeScreenViewController {
    
    func setupFetchController() {
        homeScreenViewModel.favoriteMoviesUIState = .loading
        let mainContext = CoreDataStack.shared.mainContext
        let fetchRequest = NSFetchRequest<MovieEntity>(entityName: "MovieEntity")
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController<MovieEntity>(
                   fetchRequest: fetchRequest,
                   managedObjectContext: mainContext,
                   sectionNameKeyPath: nil,
                   cacheName: nil
        )
        fetchedResultsController?.delegate = self
        
        do {
            try fetchedResultsController?.performFetch()
            favoritesCollectionView.reloadData()
            
        } catch {
            print("Failed performing fetch: \(error.localizedDescription)")
        }
    }
}

// MARK: UI STATE OBSERVABLES

extension HomeScreenViewController {
    
    func setupObservable() {
        homeScreenViewModel.$moviesUIState.sink { state in
            switch state {
            case .initial:
                self.movieListInitialView.isHidden = false
                self.movieListLoaderView.isHidden = true
                self.movieListEmptyView.isHidden = true
                self.movieListCollectitonView.isHidden = true
                self.movieListErrorView.isHidden = true
            case .loading:
                self.movieListInitialView.isHidden = true
                self.movieListLoaderView.isHidden = false
                self.movieListEmptyView.isHidden = true
                self.movieListCollectitonView.isHidden = true
                self.movieListErrorView.isHidden = true
            case .success(let data):
                self.movieListInitialView.isHidden = true
                self.movieListLoaderView.isHidden = true
                self.movieListErrorView.isHidden = true
                
                if !data.isEmpty {
                    self.movieListEmptyView.isHidden = true
                    self.movieListCollectitonView.isHidden = false
                } else {
                    self.movieListEmptyView.isHidden = false
                    self.movieListCollectitonView.isHidden = true
                }
            case .failure(_):
                self.movieListInitialView.isHidden = true
                self.movieListLoaderView.isHidden = true
                self.movieListEmptyView.isHidden = true
                self.movieListCollectitonView.isHidden = true
                self.movieListErrorView.isHidden = false
            }
        }
        .store(in: &cancellables)
        
        if let movieEntities = fetchedResultsController?.fetchedObjects {
            if movieEntities.isEmpty {
                self.favoritesCollectionView.isHidden = true
                self.favoriteMovieListEmptyView.isHidden = false
            } else {
                self.favoritesCollectionView.isHidden = false
                self.favoriteMovieListEmptyView.isHidden = true
            }
        }
        self.favoriteMoviewListLoaderView.isHidden = true
        self.favoriteMovieListErrorView.isHidden = true
       
        
//        homeScreenViewModel.$favoriteMoviesUIState.sink { state in
//            switch state {
//            case .initial:
//                break
//            case .loading:
//                self.favoriteMoviewListLoaderView.isHidden = false
//                self.favoritesCollectionView.isHidden = true
//                self.favoriteMovieListEmptyView.isHidden = true
//                self.favoriteMovieListErrorView.isHidden = true
//            case .success(let data):
//                self.favoriteMoviewListLoaderView.isHidden = true
//                self.favoriteMovieListErrorView.isHidden = true
//                if data.isEmpty {
//                    self.favoritesCollectionView.isHidden = true
//                    self.favoriteMovieListEmptyView.isHidden = false
//                } else {
//                    self.favoritesCollectionView.isHidden = false
//                    self.favoriteMovieListEmptyView.isHidden = true
//                    self.favoritesCollectionView.reloadData()
//                }
//              
//            case .failure(_):
//                self.favoriteMoviewListLoaderView.isHidden = true
//                self.favoritesCollectionView.isHidden = true
//                self.favoriteMovieListEmptyView.isHidden = true
//                self.favoriteMovieListErrorView.isHidden = false
//            }
//        }
//        .store(in: &cancellables)
        homeScreenViewModel.$movieResultList.sink { [weak self] movies in
            guard let this = self else { return }
            this.applyMovieDataSnapshot(movieList: movies)
        
        }
        .store(in: &cancellables)
    }
}

// MARK: SEARCH BAR

extension HomeScreenViewController: UISearchBarDelegate {
    func setUpSearchBar() {
        searchBar.delegate = self
        searchBar.placeholder = "Search for a track"
        
        setupSearchTextObserver()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchTextPublisher.send(searchText)
    }
    
    func setupSearchTextObserver() {
        searchTextPublisher
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] searchText in
                self?.homeScreenViewModel.searchMovie(keywordSearchText: searchText)
            }
            .store(in: &cancellables)
    }
}

// MARK: OBJC METHODS

extension HomeScreenViewController {
    @objc func showSettings() {
        print("Show settings")
        homeScreenViewModel.searchMovie(keywordSearchText: "star")
    }
    
    @objc func showFavorites() {
        let favoritesScreenViewController = FavoritesScreenViewController()
        navigationController?.pushViewController(favoritesScreenViewController, animated: true)
    }
}


// MARK: COLLECTION VIEW
extension HomeScreenViewController {
    private func createMovieCollectionView() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { (sectionIndex: Int, environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            let columns = 2
            let spacing = CGFloat(10)
            let itemSize: NSCollectionLayoutSize = .init(widthDimension: .fractionalWidth(1.0),
                                                         heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            let groupSize: NSCollectionLayoutSize = .init(widthDimension: .absolute(self.movieListCollectitonView.frame.width / 2),
                                                          heightDimension: .absolute(250.0))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, repeatingSubitem: item, count: columns)
            group.interItemSpacing = .fixed(spacing)
            
            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = spacing
            section.contentInsets = .init(top: 0, leading: spacing, bottom: 0, trailing: spacing)
            return section
        }
        
        return layout
    }
    
    private func configureDataSource() {
        var cellRegistration = UICollectionView.CellRegistration<MovieCollectionViewCell, MovieModel>(cellNib: UINib(nibName: "MovieCollectionViewCell", bundle: nil)) { [weak self] cell, indexPath, movie in
            guard let this = self else { return }
            
            let movieExist = this.homeScreenViewModel.searchMovieInFavorite(using: movie.trackId)
            cell.isFavorite = movieExist
            cell.updateViews(movie: movie)
            cell.favoriteIconTappedCallback = { [weak self] in
                guard let this = self else { return }
                if this.homeScreenViewModel.searchMovieInFavorite(using: movie.trackId) {
                    this.homeScreenViewModel.deleteFavoriteMovie(movie: movie)
                    cell.isFavorite = false
                } else {
                    this.homeScreenViewModel.addFavoriteMovie(movie: movie)
                    cell.isFavorite = true
                }
            }
        }
        
        
        movieCollectionDataSource = UICollectionViewDiffableDataSource(collectionView: movieListCollectitonView, cellProvider: { (collectionView: UICollectionView, indexPath: IndexPath, itemIdentifier: MovieModel) -> MovieCollectionViewCell? in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: itemIdentifier)
            }
        )
        
        
    }
    
    private func applyMovieDataSnapshot(movieList: [MovieModel]) {
        var movieSnapshot = NSDiffableDataSourceSnapshot<CollectionViewType, MovieModel>()
        movieSnapshot.appendSections([.movieList])
        movieSnapshot.appendItems(movieList)
        movieCollectionDataSource.apply(movieSnapshot, animatingDifferences: true)
    }
    
    private func applySingleMovieDataSnapshot(for updatedMovie: MovieModel) {
        var snapshot = movieCollectionDataSource.snapshot()
        if let index = snapshot.itemIdentifiers.firstIndex(of: updatedMovie) {
            snapshot.reloadItems([snapshot.itemIdentifiers[index]])
        }
        movieCollectionDataSource.apply(snapshot, animatingDifferences: true)
    }
}

extension HomeScreenViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == favoritesCollectionView {
            let results = fetchedResultsController?.sections?[section].numberOfObjects ?? 0
            return results
        } else if collectionView == movieListCollectitonView {
            return homeScreenViewModel.movieResultList.count
        } else {
            return 0
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == favoritesCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FavoritesCollectionViewCell.identifier,
                                                                for: indexPath) as? FavoritesCollectionViewCell,
                  let movie = fetchedResultsController?.fetchedObjects?[indexPath.row].convertToDataModel() else { return UICollectionViewCell() }
            cell.updateViews(title: movie.trackName,
                             posterUrl: movie.artworkUrl100)
            
            return cell
            
        } else {
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == favoritesCollectionView {
            
        } else if collectionView == movieListCollectitonView {
            let movie = homeScreenViewModel.movieResultList[indexPath.row]
            let movieDetailViewController = MovieDetailViewController(movieObject: movie)
            movieDetailViewController.favoriteIconCallback = { [weak self] in
                print(indexPath)

                self?.applySingleMovieDataSnapshot(for: movie)
            }
            movieDetailViewController.modalPresentationStyle = .automatic
            present(movieDetailViewController, animated: true)
        } else {
            
        }
    }
}

// MARK: NS FETCH REQUEST CONTROLLER

extension HomeScreenViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        favoritesCollectionView.performBatchUpdates(nil, completion: nil)
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        if let movieEntities = fetchedResultsController?.fetchedObjects {
            if movieEntities.isEmpty {
                self.favoritesCollectionView.isHidden = true
                self.favoriteMovieListEmptyView.isHidden = false
            } else {
                self.favoritesCollectionView.isHidden = false
                self.favoriteMovieListEmptyView.isHidden = true
            }
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<any NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            if let newIndexPath = newIndexPath {
                favoritesCollectionView.insertItems(at: [newIndexPath])
                if let cell = favoritesCollectionView.cellForItem(at: newIndexPath) {
                    cell.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                    UIView.animate(withDuration: 0.3,
                                   delay: 0,
                                   usingSpringWithDamping: 0.6,
                                   initialSpringVelocity: 0.5,
                                   options: .curveEaseOut,
                                   animations: {
                        cell.transform = .identity
                    }, completion: nil)
                    favoritesCollectionView.scrollToItem(at: newIndexPath, at: .centeredHorizontally, animated: true)
                }
            }
            
            
        case .update: break
        case .delete:
            if let indexPath = indexPath {
                favoritesCollectionView.deleteItems(at: [indexPath])
            }
        case .move: break
        @unknown default:
            fatalError("Unknown NSFetchedResultsChangeType detected.")
        }
        
    }
}
