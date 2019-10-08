//
//  ViewController.swift
//  DisappearingUnicorns
//
//  Created by Arjun cosare on 2019-09-19.
//  Copyright © 2019 Arjun cosare. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var startGameButton: UIButton!
    @IBOutlet weak var leaderboardButton: UIButton!
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var badButton: UIButton!
    @IBOutlet weak var goodButton: UIButton!
    
    var gameButtons = [UIButton]();
    var gamePoints = 0;
    var timer:Timer?
    var currentButton:UIButton!
    let defaults = UserDefaults.standard
    var intervals:Float = 0.0
    
    enum GameState{
        case gameOver
        case playing
    }
        
    var state = GameState.gameOver;
    var playerInfo = PlayerData(name: "DefaultPlayer", points: 0, rank: 0,photo: UIImage(named: "person")!)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        pointsLabel.isHidden = true;
        gameButtons = [goodButton, badButton];
        setupFreshGameState();
        
        let gameData = GameData()
        
        if(gameData.playerData(forName: defaults.string(forKey: "playerName") ?? "DefaultPlayer") != nil){
          playerInfo = gameData.playerData(forName: defaults.string(forKey: "playerName") ?? "DefaultPlayer")!
        }
        
        configureDefaults();
        
        
        defaults.addObserver(self, forKeyPath: "bgSwitchState", options: NSKeyValueObservingOptions.new, context: nil)
        defaults.addObserver(self, forKeyPath: "colorSegmentIndex", options: NSKeyValueObservingOptions.new, context: nil)
        defaults.addObserver(self, forKeyPath: "gameSpeed", options: NSKeyValueObservingOptions.new, context: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        configureDefaults()
    }
    
    //configurables
    func configureDefaults(){
        
        
        
        if(defaults.bool(forKey: "bgSwitchState"))
        {
            view.backgroundColor = colorDeterminer(defaults.integer(forKey: "colorSegmentIndex"))
        }
        else
        {
            view.backgroundColor = UIColor.white
        }
        
        intervals = defaults.float(forKey: "gameSpeed")
        //if defaults are not set, set it to 0.1s
        if(intervals == 0.0)	
        {
            intervals  = 1.0
        }
        
    }
    
    func colorDeterminer(_ color: Int) -> UIColor{
        switch color {
        case 0:
            return UIColor.red
        case 1:
            return UIColor.blue
        case 2:
            return UIColor.green
        case 3:
            return UIColor.yellow
        default:
            return UIColor.white
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //actions
    @IBAction func startPressed(_ sender: Any) {
        state = GameState.playing;
        startNewGame();
    }
    
    @IBAction func badPressed(_ sender: Any) {
        badButton.isHidden = true;
        timer?.invalidate();
        gameOver();
    }
    
    @IBAction func goodPressed(_ sender: Any) {
        gamePoints = gamePoints + 1;
        updatePointsLabel(gamePoints);
        goodButton.isHidden = true;
        timer?.invalidate();
        oneGameRound();
    }
    
    //Helpers
    func startNewGame()
    {
        startGameButton.isHidden = true;
        leaderboardButton.isHidden = true;
        gamePoints = 0;
        
        updatePointsLabel(gamePoints);
        pointsLabel.textColor = .magenta;
        pointsLabel.isHidden = false;
        oneGameRound();
    }
    
    func oneGameRound()
    {
        updatePointsLabel(gamePoints);
        displayRandomButton();
        
        timer = Timer.scheduledTimer(withTimeInterval: Double(intervals), repeats: false){ _ in
            if self.state == GameState.playing
            {
                if self.currentButton == self.goodButton
                {
                    self.gameOver();
                }
                else
                {
                    self.oneGameRound();
                }
            }
        }
    }

    func displayRandomButton(){
        for myButton in gameButtons{
            myButton.isHidden = true
        }
        let buttonIndex = Int.random(in: 0..<gameButtons.count)
        currentButton = gameButtons[buttonIndex]
        currentButton.center = CGPoint(x: randomXCoordinate(), y: randomYCoordinate())
        currentButton.isHidden = false
    }

    func gameOver() {
        state = GameState.gameOver
        pointsLabel.textColor = .brown
        setupFreshGameState()
        
        let gameData = GameData()
        gameData.savePoints(gamePoints, for: playerInfo.name)
    }

    func setupFreshGameState() {
        startGameButton.isHidden = false
        leaderboardButton.isHidden = false
        
        for mybutton in gameButtons {
            mybutton.isHidden = true
        }
        pointsLabel.alpha = 0.15
        currentButton = goodButton
        state = GameState.gameOver
        
    }
    
    func randCGFloat(_ min: CGFloat, _ max: CGFloat) -> CGFloat{
        return CGFloat.random(in: min..<max)
    }

    func randomXCoordinate() -> CGFloat {
        let left = view.safeAreaInsets.left + currentButton.bounds.width
        let right = view.bounds.width - view.safeAreaInsets.right - currentButton.bounds.width
        return randCGFloat(left, right)
    }
    
    func randomYCoordinate() -> CGFloat {
        let top = view.safeAreaInsets.top + currentButton.bounds.height
        let bottom = view.bounds.height - view.safeAreaInsets.bottom - currentButton.bounds.height
        return randCGFloat(top,bottom)
    }
    
    func updatePointsLabel(_ newValue: Int) {
        pointsLabel.text = "\(newValue)"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if let detailsViewController = segue.destination as? SettingViewController{
            detailsViewController.playerInfo = playerInfo
        }
    }
}

