import UIKit



class JuliaViewController: UIViewController
{
    @IBOutlet weak var imageView: UIImageView!
    
    var startRect = ComplexRect<Double>(Complex<Double>(-2.1, 1.5), Complex<Double>(2.0, -1.5))
    var defaultCoordinate = Complex<Double>(-0.7269, 0.1889)
    var maximumIterations = 1024
    var degree = 2
    var threshold = 2.0

    override func viewDidLoad() {
        super.viewDidLoad()

        let scaleFactor = UIScreen.mainScreen().scale
        let screenWidth = CGRectGetWidth(self.view.bounds) * scaleFactor
        let screenHeight = CGRectGetHeight(self.view.bounds) * scaleFactor
        let targetRect = CGRectMake(0, 0, screenWidth, screenHeight)
        let visibleComplexRect = self.startRect.fitCGRect(toCGRect: targetRect)
        let stepSize = visibleComplexRect.width / Double(screenWidth)
        let complexGrid = visibleComplexRect.complexGridWithStepSize(stepSize)

        let jc = JuliaCalculator()
        jc.fractalStatesForComplexGrid(complexGrid, coordinate: self.defaultCoordinate, maximumIterations: self.maximumIterations, degree: self.degree, threshold: threshold, withCompletionHandler: {
            (fractalStates: [[FractalState]]) in
            let intensityTile = ContinuousColorTile(states: fractalStates)
            let CGImage = intensityTile.CGImage
            if let imageRef = CGImage {
                let im = UIImage(CGImage: imageRef, scale: scaleFactor, orientation: .Up)
                self.imageView.image = im
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}