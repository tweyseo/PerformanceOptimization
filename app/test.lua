local main = require("main")

local app = main.init()
main.addMiddleware(app)
main.addErrHandler(app)
main.addHandler(app)

main.run(app)