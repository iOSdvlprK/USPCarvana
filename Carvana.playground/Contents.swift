import Cocoa
import TabularData
import CreateML

let fileURL = Bundle.main.url(forResource: "carvana", withExtension: "csv")!
let options = CSVReadingOptions(hasHeaderRow: true, delimiter: ",")

let formattingOptions = FormattingOptions(maximumLineWidth: 250, maximumCellWidth: 250, maximumRowCount: 100, includesColumnTypes: true)

let dataFrame = try DataFrame(contentsOfCSVFile: fileURL, options: options)
print(dataFrame.description(options: formattingOptions))

let regressor = try MLRegressor(trainingData: dataFrame, targetColumn: "Price")
let metaData = MLModelMetadata(author: "Joe", shortDescription: "Carvana Model", version: "1.0")
try regressor.write(toFile: "/Users/joe/Downloads/carvana.mlmodel", metadata: metaData)
