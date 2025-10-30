import Cocoa
import TabularData
import CreateML

let fileURL = Bundle.main.url(forResource: "carvana", withExtension: "csv")!
let options = CSVReadingOptions(hasHeaderRow: true, delimiter: ",")

let formattingOptions = FormattingOptions(maximumLineWidth: 250, maximumCellWidth: 250, maximumRowCount: 100, includesColumnTypes: true)

let calendar = Calendar.current
let currentYear = calendar.component(.year, from: Date())

let dataFrame = try DataFrame(contentsOfCSVFile: fileURL, options: options)
//print(dataFrame.description(options: formattingOptions))

let dataSliceUnder60KMiles = dataFrame.filter(on: "Miles", Int.self) { miles in
    guard let miles else { return false }
    return miles <= 60000
}
let dataSliceLessThan5YearsOld = dataSliceUnder60KMiles.filter(on: "Year", Int.self) { year in
    guard let year else { return false }
    return currentYear - year >= 0 && currentYear - year <= 5
}
let dataSliceHondaAndToyota = dataSliceLessThan5YearsOld.filter(on: "Name", String.self) { name in
    guard let name else { return false }
    return name.contains("Toyota") || name.contains("Honda")
}
print(dataSliceHondaAndToyota.description(options: formattingOptions))

let carvanaDataFrame = DataFrame(dataSliceHondaAndToyota)

let regressor = try MLRegressor(trainingData: carvanaDataFrame, targetColumn: "Price")
let metaData = MLModelMetadata(author: "Joe", shortDescription: "Carvana Model", version: "1.0")
//try regressor.write(toFile: "/Users/joe/Downloads/carvana.mlmodel", metadata: metaData)

let nameDataFrame = carvanaDataFrame.selecting(columnNames: ["Name"])
let nameColumnSlice = nameDataFrame["Name"].distinct()
let uniqueNames: [String] = nameColumnSlice.compactMap { ($0 as? String)?.trimmingCharacters(in: .whitespacesAndNewlines)
}
//print(uniqueNames)

let nameColumn = Column(name: "name", contents: uniqueNames)
//print(nameColumn)
var uniqueNameDataFrame = DataFrame()
uniqueNameDataFrame.append(column: nameColumn)
print(uniqueNameDataFrame)

// write to a JSON file
try uniqueNameDataFrame.writeJSON(to: URL(filePath: "/Users/joe/Downloads/CarNames.json"))
