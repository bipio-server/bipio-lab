# **NOTICE:** This repository has been **DEPRECATED**. Do not use.
# bipio-lab
R&amp;D and prototyping repository for bip.io

## Featured Demos

[Bips as Graphs](/demos/bips-as-graphs.litcoffee)  
[Actions and Graph Traversal](/demos/actions-and-graph-traversal.litcoffee)

### Why does this exist?

This repository is intended to house demos and proofs-of-concept for [bipio](http://bip.io) features. It's nothing more than a convenient scaffold for your executable JS/CS files, so we can show the merit of proposed changes and refactors, without getting lost in the abstract world of ideas and architecture. 

### Ok, but why not just use a branch

You still have the option not to use this tool - this was built with the idea that demos *become* branches on bipio/server. This will simply help you separate concerns (drafts vs implementation), and articulate ideas in their infant stage, in more "hands-on" way. A code notepad, if you will, to organize the team's collective thoughts and prove them in practice.  

To that end, [Literate CoffeeScript](http://coffeescript.org/#literate) is encouraged, because Github displays .litcoffee documents as Markdown, so you can be verbose about what you're trying to demonstrate and it will all be nice and readable. You will also be able to post the source code to the [blog](http://blog.bip.io) as a blog post, once your demo is all grown up and released as a feature set. Not to mention, [Docco](http://jashkenas.github.io/docco/) can generate documentation automagically from .litcoffee source. This is basically magic.

### Getting Started

```
git clone git@github.com:wotio/bipio-lab.git
cd bipio-lab
npm link
```

Now you should have `bipio-lab` command available in your Terminal.  

To create a new demo, simply use the `new` option like so:

```
bipio-lab new foo/bar/bruh.litcoffee
```

Alternatively, you can use JavaScript:
```
bipio-lab new foo/bar/bruh.js
```

You should now see a boilerplate demo script in `demos/foo/bar/` entitled "bruh". Parent folders are created automatically if they don't exist already.

### Guidelines

* Keep implementation details to a minimum, focus on showing how to get from Point A to Point B using node module C - hard code anything necessary to effectively illustrate the point.

## License

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.


Copyright (c) 2017 InterDigital, Inc. All Rights Reserved
