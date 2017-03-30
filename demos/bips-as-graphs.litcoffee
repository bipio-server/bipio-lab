## Bips as Graphs

In this demo we will show how a bip can be modeled as a graph using [Graphlib](https://github.com/cpettitt/graphlib/wiki), and stored/retrieved using [RethinkDB](http://rethinkdb.com/).

To run this demo you must first [install](../README.md#getting-started) bipio-lab and then run

```
bipio-lab bips-as-graphs.litcoffee
```

References:

[RethinkDB API Reference](http://rethinkdb.com/api/javascript/)  
[Graphlib API Reference](https://github.com/cpettitt/graphlib/wiki/API-Reference)  

	module.exports = (done) ->

		r = require 'rethinkdb'
		uuid = require 'node-uuid'
		graphlib = require 'graphlib'
		Graph = graphlib.Graph
		express = require 'express'
		request = require 'request'
		bodyParser = require 'body-parser'

#### Bip

class Bip has an instance of [Graph](https://github.com/cpettitt/graphlib/wiki/API-Reference#graph-concepts) at Bip._graph.  

Bip instances may be created with or without custom options either like this:  
`new Bip({ //...JSON to be converted into graph...// })`  
or like this:  
`new Bip({ //...JSON to be converted into graph...// }, { //...graphlib options...//})`

**accepts**: Object 
**returns**: Bip 

		class Bip extends Graph

			constructor: (object) ->

				@[key] = value for key, value of object
				if not object.hasOwnProperty 'id'
					id = uuid.v4()
					@id = id

				super { directed: true, multigraph: true, compound: true }
			
				console.log "Bip object instantiated with id #{this.id}".cyan

				@

			setAction: (action) ->
				delete action.auth if action.auth

				if @node action.id
					return "Action #{action.id} already exists."
				else 
					@setNode action.id, action

			getAction: (id) ->
				@node id

			hasAction: (id) ->
				@hasNode id

			toJSON: () ->
				graph = graphlib.json.write @
				for key, value of @
					graph[key] = value unless (key[0] is '_') or (typeof value is 'function')

				return graph

#### Server

Here's how you'd patch the main [existing bip REST endpoints](https://github.com/bipio-server/bipio/wiki/Bips) to create a bip.  

##### Explore the DB

You can see for yourself the DB entries produced here, by following these steps.

Step 1: Comment out the line at the bottom of this code block where `request.del` is invoked  
Step 2: Run `bipio-lab bips-as-graphs.litcoffee` in your Terminal  
Step 3: Click <a href="http://bip.wot.io:8080/#dataexplorer" target="_blank">here</a>  
Step 4: In the "Data Explorer" text box, write `r.db('bipioGraphDemo').table('bips')` and press "Run"  
Step 5: To delete all the entries, run `r.db('bipioGraphDemo').table('bips').delete()`  

		app = express()

		app.use bodyParser.urlencoded { extended: true }
		app.use bodyParser.json()

		# RethinkDB middleware
		app.use (req, res, next) ->
			r.connect { host: 'bip.wot.io', port: 28015, authKey: '', db: 'bipioGraphDemo'}, (err, conn) ->
				if err
					res.status(500).json err
				else
					req._rdbConn = conn
					next()

		# REST endpoints
		app.post '/rest/bip', (req, res) ->
			bip = new Bip req.body

			r.table('bips').insert(bip.toJSON(), {returnChanges: true}).run req._rdbConn, (err, result) ->
				if err
					res.status(500).json err
				else if result.inserted is not 1
					res.status(500).json new Error("Document not inserted")
				else
					res.status(200).json result.changes[0].new_val

		app.get '/rest/bip/:id', (req, res) ->
			r.table('bips').get(req.params.id).run req._rdbConn, (err, result) ->
				if err
					res.status(500).json err
				else
					res.status(200).json result

		app.delete '/rest/bip', (req, res) ->
			r.table('bips').delete().run req._rdbConn, (err, result) ->
				if err
					res.status(500).json err
				else
					console.log "Cleaning up...".yellow
					res.status(200).json result

		# start the server
		server = app.listen 4000, () ->

			port = server.address().port

			console.log "Example bipio API listening at http://localhost:#{port}"

			form =
				name: "exampleBip"
				#actions: []
				#transforms: []

			console.log "POST\n#{JSON.stringify(form, null, '\t')}\nto http://localhost:#{port}/rest/bip"

			# create a bip
			request.post { url: "http://localhost:#{port}/rest/bip", form: form }, (err, response, body) ->
				console.log JSON.stringify(JSON.parse(body), null, '\t')

				# delete all bips from DB (cleanup after ourselves)
				request.del "http://localhost:#{port}/rest/bip", () -> done(Bip, app) # export all this stuff so we can reuse it in later demos


