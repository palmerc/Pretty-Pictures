import UIKit



class MandelbrotViewController: UIViewController
{
    var startRect = ComplexRect<Double>(Complex<Double>(-2.1, 1.5), Complex<Double>(1.0, -1.5))
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let scaleFactor = UIScreen.mainScreen().scale
        let screenWidth = CGRectGetWidth(self.view.bounds) * scaleFactor
        let screenHeight = CGRectGetHeight(self.view.bounds) * scaleFactor
        let targetRect = CGRectMake(0, 0, screenWidth, screenHeight)
        let visibleComplexRect = self.startRect.fitCGRect(toCGRect: targetRect)
        let stepSize = visibleComplexRect.width / Double(screenWidth)
        let complexGrid = visibleComplexRect.complexGridWithStepSize(stepSize)

        let mc = MandelbrotCalculator()
        let states = mc.fractalStatesForComplexGrid(complexGrid, maximumIterations: 1024)
        let intensityTile = IntensityTile(states: states)
        let CGImage = intensityTile.CGImage
        if let imageRef = CGImage {
            let im = UIImage(CGImage: imageRef, scale: scaleFactor, orientation: .Up)
            print("\(im)")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

