import UIKit



class ShipViewController: UIViewController
{
    @IBOutlet weak var imageView: UIImageView!

    var startRect = ComplexRect<Double>(Complex<Double>(1.936, 0.008998), Complex<Double>(1.945998, -0.001))
    var defaultCoordinate = (u: 1.941, v: -0.004)
    var maximumIterations = 256

    override func viewDidLoad() {
        super.viewDidLoad()

        let scaleFactor = UIScreen.mainScreen().scale
        let screenWidth = CGRectGetWidth(self.view.bounds) * scaleFactor
        let screenHeight = CGRectGetHeight(self.view.bounds) * scaleFactor
        let targetRect = CGRectMake(0, 0, screenWidth, screenHeight)
        let visibleComplexRect = self.startRect.fitCGRect(toCGRect: targetRect)
        let stepSize = visibleComplexRect.width / Double(screenWidth)
        let complexGrid = visibleComplexRect.complexGridWithStepSize(stepSize)

        let sc = ShipCalculator()
        sc.fractalStatesForComplexGrid(complexGrid, maximumIterations: self.maximumIterations, withCompletionHandler: {
            (fractalStates: [[FractalState]]) in
            let intensityTile = IntensityTile(states: fractalStates)
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