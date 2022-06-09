//
//  MovieController.swift
//  mp-MovieApp
//
//  Created by Arslan Kaan AYDIN on 9.06.2022.
//

import UIKit
import SnapKit
import Alamofire

//MARK: - Protocols
protocol MovieOutput {
    func selectedMovies(movieID: Int)
}

class MovieController: UIViewController {
    //MARK: - UI Elements
    private let tableView: UITableView = {
        let tv = UITableView()
        tv.separatorStyle = .none
        tv.rowHeight = 200
        return tv
    }()

    //MARK: - Properties
    private lazy var movieResult = [MovieResult]()
    private var viewModel: MovieViewModelProtocol = MovieViewModel(service: Services())
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    //MARK: - Functions
    private func configure() {
        subviews()
        drawDesign()
        fetchData()
        makeTableView()
    }
    
    private func drawDesign() {
        // View
        view.backgroundColor = Color.appBlack
        // View Model
        viewModel.delegate = self
        // Navigation Bar
        configureNavigationBar(largeTitleColor: Color.appWhite, backgoundColor: Color.appBlack, tintColor: Color.appWhite, title: "Movies", preferredLargeTitle: false)
        self.navigationItem.setHidesBackButton(true, animated: true)
        // Table View
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(MovieTableCell.self, forCellReuseIdentifier: MovieTableCell.Identifier.custom.rawValue)
    }
    
    private func subviews() {
        view.addSubview(tableView)
    }
    //MARK: - Fetch 100 Datas
    private func fetchData() {
        
        for i in 1...5 {
            viewModel.fetchPopularMovies(page: i) { [weak self] movie in
                guard let movies = movie?.results else { return }
                self?.movieResult.append(contentsOf: movies)
                
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            } onError: { error in
                print(error)
            }
        }
        
    }
}
//MARK: - Table View Extension
extension MovieController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        movieResult.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: MovieTableCell = tableView.dequeueReusableCell(withIdentifier: MovieTableCell.Identifier.custom.rawValue) as? MovieTableCell else {
            return UITableViewCell()
        }
        cell.saveMovieModel(model: movieResult[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        viewModel.delegate?.selectedMovies(movieID: movieResult[indexPath.row].id ?? 0)
    }
}
//MARK: - Snapkit Extension
extension MovieController {
    private func makeTableView() {
        tableView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().inset(110)
            make.centerX.equalToSuperview()
        }
    }
}

//MARK: - View Model Extension
extension MovieController: MovieOutput {
    func selectedMovies(movieID: Int) {
        viewModel.getMovieDetail(movieID: movieID) { movie in
            guard let movie = movie else { return }
            self.navigationController?.pushViewController(MovieDetailController(detailResults: movie), animated: true)
        } onError: { error in
            print(error)
        }
    }
}
