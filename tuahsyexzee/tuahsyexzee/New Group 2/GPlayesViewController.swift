import UIKit
import WebKit
//import AdjustSdk
import Reachability


final class GPlayesViewController: UIViewController {

    private var wfaud: Occnyzye?
    private var pomcj: WKWebView?
//    private var bcyate: Ujicxn?
    
    override func loadView() {
        super.loadView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(diHydieye), name: .kScsiuy, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func diHydieye() {
        let dyuay: () -> Void = {
            self.aooidue()
        }
        dyuay()
    }
    
    private func aooidue() {
        if let aisy = Wiuznhs.Koixnhs() {
            wfaud = aisy
            
            Yhhcioa.shared.nuayea(from: aisy.kmciai ?? "")
//            reporter = Frcyacue(retags: config.ydbcuo ?? [:])
            ynasije(with: aisy)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let dokjsu = try! Reachability()
        dokjsu.whenReachable = { reachability in
            
            Raybxgd()
            
            dokjsu.stopNotifier()
        }
        do {
            try dokjsu.startNotifier()
        } catch {}

    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        kcojuee()
    }

    override var shouldAutorotate: Bool { false }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { .portrait }

    // MARK: - 搭建

//    private func nfuyakse(with config: Occnyzye) {
//        guard let token = config.yubcg else { return }
//        
//        let yugsas: () -> Void = {
//            let das = ADJConfig(appToken: token, environment: ADJEnvironmentProduction)
//            das?.delegate = self
//            Adjust.initSdk(das)
//        }
//        yugsas()
//        
//    }

    private func ynasije(with config: Occnyzye) {
        let contentController = WKUserContentController()
//        if let script = config.wpaomz {
//            let userScript = WKUserScript(source: script,
//                                          injectionTime: .atDocumentEnd,
//                                          forMainFrameOnly: true)
//            contentController.addUserScript(userScript)
//        }
//        contentController.add(self, name: Yhhcioa.shared.bry)

        let configuration = WKWebViewConfiguration()
        configuration.userContentController = contentController
        configuration.allowsInlineMediaPlayback = true
        configuration.defaultWebpagePreferences.allowsContentJavaScript = true

        let web = WKWebView(frame: .zero, configuration: configuration)
        web.allowsBackForwardNavigationGestures = true
        web.uiDelegate = self
        web.navigationDelegate = self
        view.addSubview(web)
        pomcj = web

        if let target = config.zgase, let url = URL(string: target) {
            web.load(URLRequest(url: url))
        }
    }

    private func kcojuee() {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let statusBarManager = scene.statusBarManager else { return }
        let topInset = statusBarManager.statusBarFrame.height
        let bottomInset = view.safeAreaInsets.bottom
        pomcj?.frame = CGRect(x: 0,
                                y: topInset,
                                width: view.bounds.width,
                                height: view.bounds.height - topInset - bottomInset)
    }
}

// MARK: - 导航与弹窗

extension GPlayesViewController: WKNavigationDelegate, WKUIDelegate {

    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        decisionHandler(.allow)
    }

    func webView(_ webView: WKWebView,
                 createWebViewWith configuration: WKWebViewConfiguration,
                 for navigationAction: WKNavigationAction,
                 windowFeatures: WKWindowFeatures) -> WKWebView? {
        if let url = navigationAction.request.url {
            UIApplication.shared.open(url)
        }
        return nil
    }
}

// MARK: - JS 桥

//extension GPlayesViewController: WKScriptMessageHandler {
//
//    func userContentController(_ userContentController: WKUserContentController,
//                               didReceive message: WKScriptMessage) {
//        guard message.name == Yhhcioa.shared.bry,
//              let payload = message.body as? [String: String] else { return }
//        bcyate?.zdjendd(payload)
//    }
//}
//

//extension GPlayesViewController: AdjustDelegate {
//
//    func adjustEventTrackingSucceeded(_ eventSuccessResponse: ADJEventSuccess?) {
//        print(eventSuccessResponse as Any)
//    }
//
//    func adjustEventTrackingFailed(_ eventFailureResponse: ADJEventFailure?) {
//        print(eventFailureResponse as Any)
//    }
//}
