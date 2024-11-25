//
//  ViewController.swift
//  JokesOfTheDay-UIKit
//
//  Created by AbdulMajid Shaikh on 25/11/24.
//

import UIKit

class ViewController: UIViewController
{
    
    @IBOutlet weak var lblAnswer: UILabel!
    @IBOutlet weak var textViewQuestions: UITextView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnGenerate: UIButton!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var imgView: UIImageView!
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        mainView.backgroundColor = GlobalFunctions.randomNeonColor()
        setUpTextView()
        
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        getData()
        animateLeftToRight(view: textViewQuestions)
        self.btnGenerate.isHidden = true
        self.imgView.isHidden = true
    }
    
    private func getData()
    {
        
        NetworkServices.shared.get(urlString: APIServices.jokeURL)
        { [weak self] result in
            
            guard let self = self else {return}
            
            switch result
            {
                
            case .success(let data) :
                do
                {
                    let items = try JSONDecoder().decode(DataModel.self, from: data)
                    print("DEBUG: Fetched data:",items)
                    
                    DispatchQueue.main.async
                    {
                        self.textViewQuestions.text = items.setup
                         
                        DispatchQueue.main.asyncAfter(deadline: .now() + 6.0)
                        {
                            self.animateLeftToRight(view: self.lblAnswer)
                            self.lblAnswer.text = items.punchline
                            self.btnGenerate.isHidden = false
                            self.imgView.isHidden = false
                            
                            self.animateLeftToRight(view: self.imgView)
                            self.animateLeftToRight(view: self.btnGenerate)
                        }
                    }
                     
                }catch
                {
                    print("Decoding error: \(error.localizedDescription)")
                }
                
            case .failure(let error) :
                print("Error: \(error.localizedDescription)")
            }
            
        }
        
    }
    
    
    
    @IBAction func btnGenerateClicked(_ sender: UIButton)
    {
        getData()
        mainView.backgroundColor = GlobalFunctions.randomNeonColor()
        btnGenerate.isHidden = true
        imgView.isHidden = true
        self.textViewQuestions.text = ""
        self.lblAnswer.text = ""
        animateLeftToRight(view: textViewQuestions)
        
    }
    
    func setUpTextView()
    {
        self.textViewQuestions.layer.borderColor = UIColor.black.cgColor
        self.textViewQuestions.layer.borderWidth = 5
        
    }
    
    func animateLeftToRight(view: UIView)
    {
        // Start the element off-screen on the left
        view.transform = CGAffineTransform(translationX: -UIScreen.main.bounds.width, y: 0)
        
        // Animate it to its original position
        UIView.animate(withDuration: 1.0, delay: 0, options: [.curveEaseInOut], animations: {
            view.transform = .identity
        }, completion: nil)
    }
    
    
}

