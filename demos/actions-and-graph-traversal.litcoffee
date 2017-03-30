## Actions and Graph Traversal

In this demo we will show how bipio's Actions can be modeled as nodes on a Bip "graph", and resolved/traversed in functional style.  

To run this demo you must first [install bipio-lab](../README.md#getting-started) and then run

```
	bipio-lab actions-and-graph-traversal.litcoffee
```

This demo imports the Bip class and Express server from the [Bips As Graphs](./bips-as-graphs.litcoffee) demo.

	module.exports = (done) ->

		Twitter = require 'twitter'
		Slack = require 'node-slack'
		Rx = require 'rx'
		Q = require 'q'
		_ = require 'underscore'
		config = require '../config'

		require('./bips-as-graphs') (Bip, app) ->

			error = (err) -> console.error "Stream Error: #{err}".red
			complete = () -> console.log "Stream Completed".green

#### Transform(config, transforms, data)

A templating algorithm.  

Takes string values from **transforms** object and interpolates them, replacing the "{property.subproperty}" values recursively with the corresponding value in **data**, and updating the corresponding **config** object key with the new interpolated strings.

			Transform = (config, transforms, data) ->

				getKeys = (prev, curr, index, array) -> prev[curr]

				paths = _.mapObject transforms, (transform, key) -> transform.match(/{([^}]+)}/g)
				replacements = _.mapObject paths, (paths, index) -> paths.map (path) -> path.substring(1,path.length-1).split('.').reduce(getKeys, data)
				
				for own key, transform of transforms
					transform = transform.replace(///#{paths[key][index]}///, replacement) for index, replacement of replacements[key]
					config[key] = transform

				return config

#### Bip.run()

Runs the bip.

			Bip::run = () ->
				for pipe in @edges()
					edge = @edge(pipe.v, pipe.w) # Retrieve each edge on the graph
					edge.in.then (i) -> edge.out.then (o) -> i.subscribe o # subscribe the promises on the edge

#### Pods

Abstraction of the role of a Pod in this scenario.  
Pods here take a more passive role, mainly retrieving Observers/Observables via a Promise API.

			Pods = {
				twitter: {
					on_new_tweet: (action) ->
						d = Q.defer()

						twitterClient = new Twitter action.auth

						twitterClient.stream 'statuses/filter', action.config, (stream) ->
							d.resolve Rx.Observable.fromEvent stream, "data"

						d.promise
				}
			
				slack: {
					post_message: (action) ->
						d = Q.defer()

						next = (tweet) ->
							slackClient = new Slack action.config.webhook_url
							slackClient.send Transform(action.config, action.transforms, tweet)

						d.resolve Rx.Observer.create next, error, complete

						d.promise

				}
			}

Create the bip, actions, and the edge that links them. In graph jargon, bip = graph, action = node, and edge = edge.  

To put it more visually: ('twitter.on_new_tweet')======['on_new_tweet.post_message']======>('slack.post_message')

			bip = new Bip { name: "Send IoT tweets to #bip_io channel" }

			# Configure Twitter node
			twitter = {
				id: "twitter.on_new_tweet",
				type: "trigger",
				auth: config.actions_and_graph_traversal.twitter_config,
				config: {
					track: 'IoT'
				}
			}

			# Configure Slack node
			slack = {
				id: "slack.post_message",
				type: "http",
				config: {
					webhook_url: config.actions_and_graph_traversal.slack_config.webhook_urls.default,
					text: 'Default Text', # sane default, will be overridden by transforms
					channel: '#iotwitter',
					username: 'IoTwitter', # sane default, will be overridden by transforms
					icon_emoji: ':bipio:',
					unfurl_links: true,
					link_names: 1
				}
				transforms: {
					text: "{text}"
					username: "{user.screen_name} - {user.location}"
				}
			}

			edge = {
				in: Pods.twitter.on_new_tweet(twitter)
				out: Pods.slack.post_message(slack)
			}

			bip.setAction twitter
			bip.setAction slack
			bip.setEdge twitter.id, slack.id, edge
			
			console.log "Bip representation for storage: ".green, bip.toJSON()

			bip.run()