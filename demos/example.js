/*
 * Example Demo
 *
 * This is an example of a demo you might write for bipio. You may use JavaScript or Literate CoffeeScript.
 *
 * All files are executed via the `bipio-lab <path>` command, where `<path>` is
 * the relative path to the demo you want to execute, relative to the demos/ folder.
 *
 * To execute this file, for example, you would run
 *
 *  ` bipio-lab example.js `
 *
 * As a contrived example, this demo shows how you might use Express to retrieve a value
 * from a mock server endpoint and print it to the console.
 *
 */

module.exports = function(done) {
  // Call done(exitmsg) to end the demo. done() is supplied with every demo you write.
  // If you don't call done(), the demo will never end.

  var express = require('express');
  var request = require('request');
  var app = express();

  app.get('/random/endpoint', function(req, res) {
    res.json({ hello: "world" }, 200);
  });

  server = app.listen(4000, function() {

    var port = server.address().port;

    console.log("Example app listening at http://localhost:" + port);

    request("http://localhost:" + port + "/random/endpoint", function(err, response, body) {
      console.log(body);
      done();
    });

  });
};
