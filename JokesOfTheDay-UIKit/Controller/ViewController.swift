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
    @IBOutlet weak var textViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var lblRemainingTime: UILabel!
    
    var animatedLine: UIView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        mainView.backgroundColor = GlobalFunctions.randomNeonColor()
        self.textViewQuestions.isUserInteractionEnabled = false
        self.textViewQuestions.isScrollEnabled = false
        setUpTextView()
        lblRemainingTime.isHidden = true
        
        animateuiView()
    }
    
    func animateuiView()
    {
        // Create the line (UIView)
        animatedLine = UIView()
        animatedLine.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 5) // Small height initially
        animatedLine.backgroundColor = GlobalFunctions.randomNeonColor()  // Initial color
        
        // Add the line to the view
        self.view.addSubview(animatedLine)
        
    }
    
    
    func animateLineFromTopToBottom() {
            // Create the line (UIView) with a fixed width (view.bounds.width) and height initially 0
            animatedLine = UIView()
            animatedLine.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 0) // Fixed width, height 0
            animatedLine.backgroundColor = .red  // Initial color
            self.view.addSubview(animatedLine)
            self.view.sendSubviewToBack(animatedLine)
            
            // Animate the line from top to bottom, maintaining fixed width
            UIView.animate(withDuration: 4.0, animations: {
                // Increase the height of the line while keeping width fixed
                self.animatedLine.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
                
                // Change the color during the animation
                self.animatedLine.backgroundColor = .green
            })
        }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        getData()
        self.btnGenerate.isHidden = true
        self.imgView.isHidden = true
        setUpTextView()
    }
    
    
    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
        updateTextViewHeight()
    }
    
    private func updateTextViewHeight()
    {
        let fittingSize = CGSize(width: textViewQuestions.frame.width, height: CGFloat.greatestFiniteMagnitude)
        let calculatedSize = textViewQuestions.sizeThatFits(fittingSize)
        textViewHeightConstraint.constant = calculatedSize.height
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
                        self.resetTheAnimation()
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 6.0)
                        {
                            self.animateLineFromTopToBottom()
                            self.mainView.backgroundColor = .clear
    
                            self.lblAnswer.text = items.punchline
                            self.btnGenerate.isHidden = false
                            self.imgView.isHidden = false
                            self.animateLeftToRight(view: self.imgView)
                            self.animateLeftToRight(view: self.lblAnswer)
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
        
        resetTheAnimation()
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
        self.animateLeftToRight(view: self.textViewQuestions)
        self.animateLeftToRight(layout: self.textViewHeightConstraint, view: self.textViewQuestions)
    }
    
    private func resetTheAnimation()
    {
        animatedLine.layer.removeAllAnimations() // Stop any ongoing animations
        animatedLine.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 0) // Reset to initial state
        animatedLine.backgroundColor = .red // Reset to initial color if needed
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
    
    func animateLeftToRight(layout: NSLayoutConstraint, view: UIView)
    {
        // Move the view off-screen to the left
        layout.constant = -UIScreen.main.bounds.width
        view.layoutIfNeeded() // Apply the initial layout state

        // Animate the view back to its original position
        layout.constant = 0
        UIView.animate(withDuration: 1.0, delay: 0, options: [.curveEaseInOut], animations:{
            view.layoutIfNeeded() // Animate the layout change
        }, completion: nil)
    }
 
    func textViewDidChange(_ textView: UITextView)
    {
        let contentHeight = textViewQuestions.contentSize.height
        textViewHeightConstraint.constant = contentHeight
    }
    
}







