import UIKit



class MandelbrotViewController: UIViewController
{
    @IBOutlet weak var imageView: UIImageView!
    
    var startRect = ComplexRect<Double>(Complex<Double>(-2.1, 1.5), Complex<Double>(1.0, -1.5))
    var maximumIterations = 4096
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

        let time = self.measureBlock { 
            let mc = MandelbrotCalculatorMetal()
            mc.fractalStatesForComplexGrid(complexGrid, maximumIterations: self.maximumIterations, degree: self.degree, threshold: self.threshold, withCompletionHandler: {
                (fractalStates: [[FractalState]]) in
                let continuousColorTile = ContinuousColorTile(states: fractalStates)
                let CGImage = continuousColorTile.CGImage
                if let imageRef = CGImage {
                    let im = UIImage(CGImage: imageRef, scale: scaleFactor, orientation: .Up)
                    self.imageView.image = im
                }
            })
        }

        print("Mandelbrot set calculated in \(time) seconds.")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    private func measureBlock(block: ()->()) -> CFTimeInterval
    {
        let start = CACurrentMediaTime()
        block()
        let end = CACurrentMediaTime()

        return end - start
    }
}

