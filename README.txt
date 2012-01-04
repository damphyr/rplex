= rplex

http://c11865-prj.zuehlke.com

== DESCRIPTION:

Simple asynchronous data based job management

== INSTALL:

* sudo gem install rplex

=== Why?
Because anything involving redis, postgres etc. is just a pain to install on Windows and we just wanted to parallelize a bunch of build tasks.

=== How do you use it?
In a CI system to reduce our build times by parallelizing test execution:

The main build finishes and posts as data the revision and the location of the build artifacts to rplex. rplex queues the data for every worker that has appeared until that point.
Each worker polls the rplex queue, and then uses the information to grab the build and run a bunch of tests.

=== Is that all?
Queues are created automatically when a worker tries to get data from the queue, data can be posted to a subset of the workers if necessary and that as they say is it.

== Example
Start the rplex service.

Use Rplex::Client to post data:

Rplex::Client.new("name","http://rplex.host:7777/job").new_job(job_id,data)

Use Rplex::Processor to check the queue and do something with any data present

Rplex::Processor.new(Rplex::Client.new("name","http://rplex.host:7777/job"),5).run!{|job_data| p job_data}


== LICENSE:

(The MIT License)

Copyright (c) 2011-2012 Vassilis Rizopoulos

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
