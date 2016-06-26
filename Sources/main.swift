print(Process.arguments)

let pathToConfig = Process.arguments[1]

Log.logLevel = Log.Level.DEBUG
Log.addOutput(output: ConsoleOutput())

let config = CloudConfig(path: pathToConfig)

let cloud = TheCloud(config: config)
cloud.listLocations()
