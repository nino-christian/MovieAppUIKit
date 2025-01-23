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
    
    enum Sections: CaseIterable {
        case favorites
        case movies
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
    private var movieCollectionDataSource: UICollectionViewDiffableDataSource<Sections, MovieModel>!
    private var favoritesCollectionDataSource: UICollectionViewDiffableDataSource<Sections, NSManagedObjectID>!
    
    private var homeScreenViewModel: HomeScreenViewModel
    
    lazy var fetchedResultsController: NSFetchedResultsController<MovieEntity> = {
        let mainContext = CoreDataStack.shared.mainContext
        let fetchRequest = MovieEntity.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        let controller = NSFetchedResultsController(
                   fetchRequest: fetchRequest,
                   managedObjectContext: mainContext,
                   sectionNameKeyPath: nil,
                   cacheName: nil
        )
        controller.delegate = self
        return controller
    }()
    
    init(homeScreenViewModel: HomeScreenViewModel) {
        self.homeScreenViewModel = homeScreenViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureFavoriteDataSource()
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
        
//        let favoritesCollectionViewFlowLayout = UICollectionViewFlowLayout()
//        favoritesCollectionViewFlowLayout.scrollDirection = .horizontal
//        favoritesCollectionViewFlowLayout.minimumInteritemSpacing = 3
//        favoritesCollectionViewFlowLayout.minimumLineSpacing = 5
//        favoritesCollectionViewFlowLayout.itemSize = CGSize(width: 80, height: 100)
        favoritesCollectionView.collectionViewLayout = createFavoriteCollectionView()
        favoritesCollectionView.dataSource = favoritesCollectionDataSource
        favoritesCollectionView.delegate = self
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
        movieListCollectitonView.dataSource = movieCollectionDataSource
        movieListCollectitonView.delegate = self
    }
    
//    func configCollectionViewLayout() -> UICollectionViewLayout {
//        
//    }
}

extension HomeScreenViewController {
    
    func setupFetchController() {
        do {
            try fetchedResultsController.performFetch()
            applyFavoriteInitialDataSnapshot()
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
                    self.applyMovieDataSnapshot(movieList: data)
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
        

        self.favoriteMoviewListLoaderView.isHidden = true
        self.favoriteMovieListErrorView.isHidden = true
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
    
    private func createFavoriteCollectionView() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { (sectionIndex: Int, environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            let itemSize: NSCollectionLayoutSize = .init(widthDimension: .fractionalWidth(1.0),
                                                         heightDimension: .fractionalHeight(1.0))
            let item: NSCollectionLayoutItem = .init(layoutSize: itemSize)
            let groupSize: NSCollectionLayoutSize = .init(widthDimension: .absolute(80),
                                                          heightDimension: .absolute(100))
            let group: NSCollectionLayoutGroup = .horizontal(layoutSize: groupSize, subitems: [item])
            let section: NSCollectionLayoutSection = .init(group: group)
            section.orthogonalScrollingBehavior = .continuous
            return section
        }
        return layout
    }
    private func configureFavoriteDataSource() {
        favoritesCollectionDataSource = UICollectionViewDiffableDataSource(collectionView: favoritesCollectionView, cellProvider: { collectionView, indexPath, objectID -> UICollectionViewCell? in
            guard let object = try? self.fetchedResultsController.managedObjectContext.existingObject(with: objectID) as? MovieEntity else {
                fatalError("Managed object should be available")
            }
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FavoritesCollectionViewCell.identifier, for: indexPath) as? FavoritesCollectionViewCell
            cell?.updateViews(title: object.trackName!, posterUrl: object.artworkPoster!)
            return cell
            }
        )
    }
    
    private func configureDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<MovieCollectionViewCell, MovieModel>(cellNib: UINib(nibName: "MovieCollectionViewCell", bundle: nil)) { [weak self] cell, indexPath, movie in
            guard let this = self else { return }
            
            let isFavorite = this.homeScreenViewModel.isMovieInFavorites(using: movie.trackId)
            cell.updateViews(movie: movie, isFavorite: isFavorite)
            
            cell.favoriteIconTappedCallback = { [weak self] in
                guard let this = self else { return }
                let isFavorite = this.homeScreenViewModel.isMovieInFavorites(using: movie.trackId)
                if isFavorite {
                    this.homeScreenViewModel.deleteFavoriteMovie(movie: movie)
                } else {
                    this.homeScreenViewModel.addFavoriteMovie(movie: movie)
                }
                this.applySingleMovieDataSnapshot(for: movie)
            }
        }
        
        
        movieCollectionDataSource = UICollectionViewDiffableDataSource(collectionView: movieListCollectitonView, cellProvider: { (collectionView: UICollectionView, indexPath: IndexPath, itemIdentifier: MovieModel) -> MovieCollectionViewCell? in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration,
                                                                for: indexPath,
                                                                item: itemIdentifier)
            }
        )
        
        
    }
    
    private func applyFavoriteInitialDataSnapshot() {
        guard let fetchedObjects = fetchedResultsController.fetchedObjects else { return }
        if fetchedObjects.isEmpty {
            self.favoritesCollectionView.isHidden = true
            self.favoriteMovieListEmptyView.isHidden = false
        } else {
            self.favoritesCollectionView.isHidden = false
            self.favoriteMovieListEmptyView.isHidden = true
        }
        var snapshot = NSDiffableDataSourceSnapshot<Sections, NSManagedObjectID>()
        snapshot.appendSections([.favorites])
        snapshot.appendItems(fetchedObjects.map { $0.objectID })
        favoritesCollectionDataSource.apply(snapshot, animatingDifferences: false)
    }
    
    private func applyMovieDataSnapshot(movieList: [MovieModel]) {
        var movieSnapshot = NSDiffableDataSourceSnapshot<Sections, MovieModel>()
        movieSnapshot.appendSections([.movies])
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

extension HomeScreenViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == movieListCollectitonView {
            guard case let .success(movies) = homeScreenViewModel.moviesUIState else { return }
            let movie = movies[indexPath.row]
            let movieDetailViewController = MovieDetailViewController(movieObject: movie)
            movieDetailViewController.favoriteIconCallback = { [weak self] in
                print(indexPath)
                self?.applySingleMovieDataSnapshot(for: movie)
            }
            movieDetailViewController.modalPresentationStyle = .automatic
            present(movieDetailViewController, animated: true)
        }
    }
}

// MARK: NS FETCH REQUEST CONTROLLER

extension HomeScreenViewController: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<any NSFetchRequestResult>, didChangeContentWith snapshot: NSDiffableDataSourceSnapshotReference) {
        guard let dataSource = favoritesCollectionView.dataSource as? UICollectionViewDiffableDataSource<Sections, NSManagedObjectID> else {
            assertionFailure("The data source has not implemented snaphot support where it should")
            return
        }
        
        var snapshot = snapshot as NSDiffableDataSourceSnapshot<Sections, NSManagedObjectID>
        let currentSnapshot = dataSource.snapshot() as NSDiffableDataSourceSnapshot<Sections, NSManagedObjectID>
        
        print("snapshot count: \(snapshot.itemIdentifiers.count)")
        if snapshot.itemIdentifiers.isEmpty {
            self.favoritesCollectionView.isHidden = true
            self.favoriteMovieListEmptyView.isHidden = false
        } else {
            self.favoritesCollectionView.isHidden = false
            self.favoriteMovieListEmptyView.isHidden = true
        }
        let reloadIdentifiers: [NSManagedObjectID] = snapshot.itemIdentifiers.compactMap { itemIdentifier in
            guard let currentIndex = currentSnapshot.indexOfItem(itemIdentifier), let index = snapshot.indexOfItem(itemIdentifier), index == currentIndex else {
                return nil
            }
            guard let existingObject = try? controller.managedObjectContext.existingObject(with: itemIdentifier), existingObject.isUpdated else { return nil }
            return itemIdentifier
        }
        
        snapshot.reloadItems(reloadIdentifiers)
                
        let shouldAnimate = favoritesCollectionView.numberOfSections > 0
        favoritesCollectionDataSource.apply(snapshot, animatingDifferences: shouldAnimate)
    }
}
