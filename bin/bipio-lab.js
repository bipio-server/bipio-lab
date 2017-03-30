#!/usr/bin/env node

require('coffee-script').register()
fsSync = require('fs-sync')
fs = require('fs')
path = require('path')
pkg = require(path.join(__dirname, '../package.json'))
colors = require('colors')
mkdirp = require('mkdirp')

done = function (exitmsg) {
	if (typeof exitmsg === 'string') console.log("[bipio-lab]:".cyan, exitmsg)
	process.exit(0)
}

if (process.argv[2] !== undefined) {
	if (process.argv[2] === '-v') done("v"+pkg.version)
	else if (process.argv[2] === 'new') {
		if (process.argv[3] !== undefined && process.argv[3].match(/\.js|\.litcoffee/)) {
			mkdirp(path.join(__dirname, '../demos/' + path.dirname(process.argv[3])), function(err) {
				if (err) done(err)
				else {
					read = fs.createReadStream(path.join(__dirname, '../demos/example' + path.extname(process.argv[3])))
					write = fs.createWriteStream(path.join(__dirname, '../demos/' + process.argv[3]))

					write.on("finish", function() {
						done("New demo created at " + process.argv[3].green +" - Execute with:\n\n\t`bipio-lab " + process.argv[3].green + "`")
					})

					read.pipe(write)
				}
			})
		}
		else done("Not a valid parameter. \n\n\t`bipio-lab new <path>`")
	}
	else if (fsSync.exists(path.join(__dirname, '../demos/' + process.argv[2]))) require("../demos/" + process.argv[2])(done)
	else done("Not a valid parameter. \n\n\t`bipio-lab <path>`")
}
else done("Not a valid parameter.")
