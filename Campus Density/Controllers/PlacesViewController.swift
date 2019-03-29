//
//  ViewController.swift
//  Campus Density
//
//  Created by Matthew Coufal on 10/14/18.
//  Copyright © 2018 Cornell DTI. All rights reserved.
//

import UIKit
import SnapKit
import Firebase
import IGListKit

enum Filter {
    case all
    case north
    case west
    case central
}

class PlacesViewController: UIViewController, UIScrollViewDelegate {
    
    // MARK: - Data vars
    var filteredPlaces = [Place]()
    var filters: [Filter]!
    var selectedFilter: Filter = .all
    var gettingDensities = false
    var lastOffset: CGFloat = 0
    var adapter: ListAdapter!
    
    // MARK: - View vars
    var collectionView: UICollectionView!
    var loadingBarsView: LoadingBarsView!
    var refreshBarsView: LoadingBarsView!
    
    // MARK: - Constants
    let contentOffsetBound: CGFloat = 200
    let minOffset: CGFloat = 150
    let cellAnimationDuration: TimeInterval = 0.2
    let cellScale: CGFloat = 0.95
    let placeTableViewCellHeight: CGFloat = 105
    let filtersViewHeight: CGFloat = 65
    let loadingViewLength: CGFloat = 50
    let placeTableViewCellReuseIdentifier = "places"
    let smallLoadingBarsLength: CGFloat = 33
    let largeLoadingBarsLength: CGFloat = 63
    let logoLength: CGFloat = 50
    let dtiWebsite = "https://www.cornelldti.org/"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        Auth.auth().addIDTokenDidChangeListener { (auth, user) in
            if let user = user {
                user.getIDToken { (token, error) in
                    if let _ = error {
                        forgetToken()
                        self.alertError()
                    } else if let token = token {
                        rememberToken(token: token)
                    } else {
                        forgetToken()
                        self.alertError()
                    }
                }
            } else {
                forgetToken()
                self.alertError()
            }
        }
        
        signIn()

        view.backgroundColor = .white
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.backgroundColor = .white
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.largeTitleTextAttributes =
            [NSAttributedString.Key.foregroundColor: UIColor.grayishBrown]
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)

        filters = [.all, .north, .west, .central]

        setupViews()
        setupConstraints()
        
    }
    
    func signIn() {
        if let user = Auth.auth().currentUser {
            if let _ = System.token {
                getPlaces()
            } else {
                user.getIDToken { (token, error) in
                    if let _ = error {
                        forgetToken()
                        self.alertError()
                    } else {
                        if let token = token {
                            rememberToken(token: token)
                            self.getPlaces()
                        } else {
                            forgetToken()
                            self.alertError()
                        }
                    }
                }
            }
        } else {
            Auth.auth().signInAnonymously { (result, error) in
                if let _ = error {
                    forgetToken()
                    self.alertError()
                } else {
                    if let result = result {
                        let user = result.user
                        user.getIDToken { (token, error) in
                            if let _ = error {
                                forgetToken()
                                self.alertError()
                            } else {
                                if let token = token {
                                    rememberToken(token: token)
                                    self.getPlaces()
                                } else {
                                    forgetToken()
                                    self.alertError()
                                }
                            }
                        }
                    } else {
                        forgetToken()
                        self.alertError()
                    }
                }
            }
        }
    }
    
    func alertError() {
        let alertController = UIAlertController(title: "Error", message: "Failed to load data. Check your network connection.", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Try Again", style: .default, handler: { action in
            self.signIn()
            alertController.dismiss(animated: true, completion: nil)
        }))
        present(alertController, animated: true, completion: nil)
    }
    
    func getHistory() {
        API.history { gotHistory in
            if gotHistory {
                self.title = "Places"
                sortPlaces()
                self.filter(by: self.selectedFilter)
                self.loadingBarsView.stopAnimating()
                self.collectionView.isHidden = false
                self.adapter.performUpdates(animated: false, completion: nil)
            } else {
                self.alertError()
            }
        }
    }
    
    func getDensities() {
        API.densities { gotDensities in
            if gotDensities {
                self.getStatus()
            } else {
                self.alertError()
            }
        }
    }
    
    func getStatus() {
        API.status { gotStatus in
            if gotStatus {
                self.getHistory()
            } else {
                self.alertError()
            }
        }
    }
    
    func getPlaces() {
        API.places { gotPlaces in
            if gotPlaces {
                self.getDensities()
            } else {
                self.alertError()
            }
        }
    }
    
    func updatePlaces() {
        if !System.places.isEmpty {
            setupRefreshControl()
            API.densities { gotDensities in
                if gotDensities {
                    API.status { gotStatus in
                        if gotStatus {
                            self.filter(by: self.selectedFilter)
                            self.adapter.performUpdates(animated: false, completion: nil)
                        }
                    }
                }
            }
        }
    }
    
    
    @objc func didBecomeActive() {
        updatePlaces()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updatePlaces()
    }
    
    func filterLabel(filter: Filter) -> String {
        switch filter {
        case .all:
            return "All"
        case .central:
            return "Central"
        case .north:
            return "North"
        case .west:
            return "West"
        }
    }
    
    func filter(by selectedFilter: Filter) {
        switch selectedFilter {
        case .all:
            filteredPlaces = []
            filteredPlaces.append(contentsOf: System.places)
            break
        case .north:
            filteredPlaces = System.places.filter({ place -> Bool in
                return place.region == Region.north
            })
            break
        case .west:
            filteredPlaces = System.places.filter({ place -> Bool in
                return place.region == Region.west
            })
            break
        case .central:
            filteredPlaces = System.places.filter({ place -> Bool in
                return place.region == Region.central
            })
        }
        filteredPlaces = sortFilteredPlaces(places: filteredPlaces)
    }
    
    func setupRefreshControl() {
        if #available(iOS 10.0, *) {
            if refreshBarsView != nil {
                refreshBarsView.removeFromSuperview()
            }
            collectionView.refreshControl?.removeFromSuperview()
            let refreshControl = UIRefreshControl()
            refreshControl.tintColor = .white
            refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
            refreshBarsView = LoadingBarsView()
            refreshBarsView.configure(with: .small)
            refreshBarsView.alpha = 0.0
            refreshBarsView.startAnimating()
            refreshControl.addSubview(refreshBarsView)
            refreshBarsView.snp.makeConstraints { make in
                make.width.height.equalTo(smallLoadingBarsLength)
                make.center.equalToSuperview()
            }
            collectionView.refreshControl = refreshControl
        }
    }
    
    func setupViews() {
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.showsVerticalScrollIndicator = false
        collectionView.isHidden = true
        collectionView.alwaysBounceVertical = true
        collectionView.bounces = true
        view.addSubview(collectionView)
        
        let updater = ListAdapterUpdater()
        adapter = ListAdapter(updater: updater, viewController: nil)
        adapter.collectionView = collectionView
        adapter.dataSource = self
        adapter.scrollViewDelegate = self
        
        setupRefreshControl()
        
        loadingBarsView = LoadingBarsView()
        loadingBarsView.configure(with: .large)
        loadingBarsView.startAnimating()
        view.addSubview(loadingBarsView)
        
    }
    
    @objc func didPullToRefresh(sender: UIRefreshControl) {
        guard let refreshControl = collectionView.refreshControl else { return }
        API.densities { gotDensities in
            if gotDensities {
                sortPlaces()
                self.filter(by: self.selectedFilter)
            }
            refreshControl.endRefreshing()
        }
    }
    
    func setupConstraints() {
        
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        loadingBarsView.snp.makeConstraints { make in
            make.width.height.equalTo(largeLoadingBarsLength)
            make.center.equalToSuperview()
        }
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = -scrollView.contentOffset.y
        let fraction = offset / contentOffsetBound
        let alpha = min(1, fraction)
        if offset > minOffset || lastOffset > offset {
            refreshBarsView.alpha = alpha
        }
        lastOffset = offset
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        refreshBarsView.alpha = 0
    }


}

