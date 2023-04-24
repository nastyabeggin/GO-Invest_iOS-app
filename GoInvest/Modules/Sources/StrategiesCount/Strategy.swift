import Foundation
import QuoteClient
import DomainModels

// enum Strategy {
//    case sharpe
//    case rogersSatchell
//    case yangZhang
//
//    func getVector() -> [Double]{
//        switch self {
//        case .rogersSatchell:
//        case .sharpe:
//        case .yangZhang:
//        }
//    }
// }
public enum RiskLevel: Int {
    case low
    case lowMedium
    case upperMedium
    case high
}

public enum Strategy: Int {
    case sharpe
    case rogersSatchell
    case yangZhang
}

public class StrategyCounter {
    private var riskLevel: RiskLevel
    private var strategy: Strategy
    private let quoteClient: QuotesStatProvider = QuoteClient()
    private let tickers: [String]
    private let boards: [String]
    private let quotes: [Quote]

    public init(quotes: [Quote], riskLevel: RiskLevel = RiskLevel.low, strategy: Strategy = Strategy.sharpe) {
        self.quotes = quotes
        self.tickers = quotes.map { $0.id }
        self.boards = Array(repeating: "TQBR", count: tickers.count)
        self.riskLevel = riskLevel
        self.strategy = strategy
    }

    private func getSortedDictionary(_ unsortedVector: [(String, Double)]) -> [(String, Double)] {
        let vectorToReturn = unsortedVector.sorted {
            ($0.1) < ($1.1)
        }
        return vectorToReturn
    }

    public func getVector(completion: @escaping (_: [(Quote, Double)]) -> Void) {
        quoteClient.quoteStat(listOfId: tickers,
                              listOfBoardId: boards,
                              fromDate: Calendar.current.date(byAdding: .year, value: -1, to: .now)!
        ) { [self] result in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let data):
                var vector: [(Quote, Double)] = []
                switch strategy {
                case .sharpe:
                    vector = countSharpeStrategy(data: data)
                case .rogersSatchell:
                    vector = countRogersSatchellStrategy(data: data)
                case.yangZhang:
                    vector = countYangZhangStrategy(data: data)
                }
                completion(vector)
            }
        }
    }

    private func convertResult(quotes: [Quote], portfolio: [Double]) -> [(Quote, Double)] {
        var risk = 1.0
        switch riskLevel {
        case .low:
            risk *= 0.3
        case .lowMedium:
            risk *= 0.6
        case .upperMedium:
            risk *= 0.8
        case .high:
            risk *= 1.0
        }
        var cfcnts = portfolio.map { $0 * risk }
        var result = Array(zip(quotes, cfcnts))
        result.sort { $0.1 > $1.1 }
        var nilResult = result.map { $0.0.openPrice == nil ? nil : $0 }
        result = nilResult.compactMap { $0 }
        return Array(result[0..<min(6, result.count)])
    }
}

// MARK: - Sharpe strategy
private extension StrategyCounter {
    // TODO: should return all market data
    //    func getMarketData() -> [(String, Double)] {
    //
    //    }

    // returns cortege [("stock id", "coeff to buy")]
    func countSharpeStrategy(data: [QuoteCharts?]) -> [(Quote, Double)] {
        var allData = [[Double]]()
        var portfolioSharp = [Double](repeating: 0.0, count: tickers.count)
        for i in data {
            var dataForQuote = [Double]()
            if let quoteCharts = i {
                for point in quoteCharts.points {
                    dataForQuote.append(Double(point.1.description)!)
                }
            }
            allData.append(dataForQuote)
        }
        let returns = allData
        for i in 0 ..< tickers.count {
            let sharpCoef = self.getSharpeCoef(returns: getReturn(dataClose: returns[i]))
            portfolioSharp[i] = sharpCoef
        }
        portfolioSharp = portfolioSharp.map { $0.isNaN ? 0 : $0 }
        portfolioSharp = getPortfolioSharp(sharpList: portfolioSharp)
        return convertResult(quotes: quotes, portfolio: portfolioSharp)
    }

    // MARK: - func returns sharp coef
    private func getSharpeCoef(returns: [Double]) -> Double {
        let length = Double(returns.count - 1)
        let mean = returns.reduce(0, +) / Double(returns.count)
        let stdDev = sqrt(returns.map { pow($0 - mean, 2) }.reduce(0, +) / length)
        return sqrt(length) * mean / stdDev
    }
    // MARK: - returns vector
    private func getPortfolioSharp(sharpList: [Double]) -> [Double] {
        let absSharpList = sharpList.map(abs)
        let sumAbsSharpList = absSharpList.reduce(0, +)
        return sharpList.map { $0 / sumAbsSharpList }
    }

    /*
     Функция возвращает вектор доходностей за каждый день
     на протяжении всего периода
     */
    func getReturn(dataClose: [Double]) -> [Double] {
        var returnVector = [Double]()
        for i in 0..<dataClose.count {
            if i == 0 {
                returnVector.append(0)
            } else {
                returnVector.append((dataClose[i] / dataClose[i - 1]) - 1)
            }
        }
        return returnVector
    }
}

// MARK: - Rogers Satchell Strategy
private extension StrategyCounter {
    func countRogersSatchellStrategy(data: [QuoteCharts?]) -> [(Quote, Double)] {
        var allDataPrice = [[Double]]()
        var allDataOpenPrice = [[Double]]()
        var allDataClosePrice = [[Double]]()
        var portfolioRS = [Double](repeating: 0, count: tickers.count)
        for i in data {
            var dataPriceForQuote = [Double]()
            var dataOpenPriceForQuote = [Double]()
            var dataClosePriceForQuote = [Double]()
            if let quoteCharts = i {
                for point in quoteCharts.points {
                    dataPriceForQuote.append(Double(point.1.description)!)
                    dataOpenPriceForQuote.append(Double(point.2.description)!)
                    dataClosePriceForQuote.append(Double(point.3.description)!)
                }
            }
            allDataPrice.append(dataPriceForQuote)
            allDataOpenPrice.append(dataOpenPriceForQuote)
            allDataClosePrice.append(dataClosePriceForQuote)
        }

        for i in 0 ..< tickers.count {
            portfolioRS[i] = -getRSVolatility(dataOpen: allDataOpenPrice[i], dataClose: allDataClosePrice[i], dataHigh: allDataPrice[i], dataLow: allDataPrice[i])
        }
        portfolioRS = getPortfolioRS(rsList: portfolioRS)
        return convertResult(quotes: quotes, portfolio: portfolioRS)
    }

    func getRSVolatility(dataOpen: [Double], dataClose: [Double], dataHigh: [Double], dataLow: [Double]) -> Double {
        let firstZip = zip(dataHigh, dataClose).map { $0.0 * 1.1 / $0.1 }
        let secondZip = zip(dataHigh, dataOpen).map { $0.0 * 1.2 / $0.1 }
        let thirdZip = zip(dataLow, dataClose).map { $0.0 * 1.3 / $0.1 }
        let fourthZip = zip(dataLow, dataOpen).map { $0.0 * 1.4 / $0.1 }
        let intermediateArray = zip(zip(firstZip, secondZip), zip(thirdZip, fourthZip))
        let logData = intermediateArray.map { log($0.0.0) * log($0.0.1) * log($0.1.0) * log($0.1.1) }
        return sqrt(logData.reduce(0, +) / Double(dataOpen.count))
    }

    func getPortfolioRS(rsList: [Double]) -> [Double] {
        let rsMean = rsList.reduce(0, +) / Double(rsList.count)
        var normalizedRSList = rsList.map { $0 - rsMean }
        normalizedRSList = normalizedRSList.map { $0 / normalizedRSList.reduce(0) { $0 + abs($1) } }
        return normalizedRSList
    }
}

// MARK: - Yang Zhang Strategy
private extension StrategyCounter {
    func countYangZhangStrategy(data: [QuoteCharts?]) -> [(Quote, Double)] {
        var allData = [[Double]]()
        var portfolioYZ = [Double](repeating: 0, count: tickers.count)
        for i in data {
            var dataForQuote = [Double]()
            if let quoteCharts = i {
                for point in quoteCharts.points {
                    dataForQuote.append(Double(point.1.description)!)
                }
            }
            allData.append(dataForQuote)
        }
        let returns = allData
        for i in 0 ..< tickers.count {
            portfolioYZ[i] = -getYZVolatility(dataOpen: returns[i], dataClose: returns[i], dataHigh: returns[i], dataLow: returns[i])
        }
        portfolioYZ = getPortfolioYZ(yzList: portfolioYZ)
        return convertResult(quotes: quotes, portfolio: portfolioYZ)

    }

    func sigmaOpen(dataOpen: [Double], dataClose: [Double]) -> Double {
        let logDataOpen = dataOpen.map { log($0) }
        let shiftedDataClose = Array(dataClose.dropFirst())
        let logShiftedDataClose = shiftedDataClose.map { log($0) }
        let data = zip(logDataOpen, logShiftedDataClose)
        let dataRatio = data.map { exp($0.0 - $0.1) }
        return dataRatio.standardDeviation()
    }

    func sigmaClose(dataOpen: [Double], dataClose: [Double]) -> Double {
        let logDataClose = dataClose.map { log($0) }
        let shiftedDataOpen = Array(dataOpen.dropFirst())
        let logShiftedDataOpen = shiftedDataOpen.map { log($0) }
        let data = zip(logDataClose, logShiftedDataOpen)
        let dataRatio = data.map { exp($0.0 - $0.1) }
        return dataRatio.standardDeviation()
    }
    func getYZVolatility(dataOpen: [Double], dataClose: [Double], dataHigh: [Double], dataLow: [Double]) -> Double {
        let k = 0.34 / (1.34 + Double(dataClose.count + 1) / Double(dataClose.count - 1))
        let sigmaOpenSquared = pow(sigmaOpen(dataOpen: dataOpen, dataClose: dataClose), 2)
        let sigmaCloseSquared = pow(sigmaClose(dataOpen: dataOpen, dataClose: dataClose), 2)
        let rsVolatilitySquared = pow(getRSVolatility(dataOpen: dataOpen, dataClose: dataClose, dataHigh: dataHigh, dataLow: dataLow), 2)
        return sqrt(sigmaOpenSquared + k * sigmaCloseSquared + (1 - k) * rsVolatilitySquared)
    }
    func getPortfolioYZ(yzList: [Double]) -> [Double] {
        let mean = yzList.reduce(0, +) / Double(yzList.count)
        var adjustedYZList = yzList.map { $0 - mean }
        let absoluteSum = adjustedYZList.map(abs).reduce(0, +)
        adjustedYZList = adjustedYZList.map { $0 / absoluteSum }
        return adjustedYZList
    }
}

extension Sequence where Iterator.Element == Double, Self: Collection {
    func standardDeviation() -> Double {
        let mean = self.reduce(0.0, +) / Double(self.count)
        let sumOfSquaredDifferences = self.reduce(0.0) { total, value in
            let difference = value - mean
            return total + difference * difference
        }
        let standardDeviation = sqrt(sumOfSquaredDifferences / Double(self.count))
        return standardDeviation
    }
}
