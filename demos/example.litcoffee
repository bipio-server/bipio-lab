## Example Demo

This is an example of a demo you might write for bipio. You may use JavaScript or Literate CoffeeScript.  

All files are executed via the `bipio-lab <path>` command, where `<path>` is the relative path to the demo you want to execute, relative to the demos/ folder.  

To execute this file, for example, you would run

```
	bipio-lab example.litcoffee
```

As a contrived example, this demo shows how you might use [Express](http://expressjs.com) to retrieve a value from a mock server endpoint and print it to the console. 

	module.exports = (done) -> 

	# Call done(exitmsg) to end the demo. done() is supplied with every demo you write.
	# If you don't call done(), the demo will never end. 

		express = require 'express'
		request = require 'request'
		app = express()

		app.get '/random/endpoint', (req, res) ->
			res.json { hello: "world" }, 200

		server = app.listen 4000, () ->

			host = server.address().address
			port = server.address().port

			console.log "Example app listening at http://localhost:#{port}"

			request "http://localhost:#{port}/random/endpoint", (err, response, body) ->
				console.log body
				done()
