# -*- ruby -*-
$:.unshift File.join(File.dirname(__FILE__),"lib")
require 'rplex'
require 'rubygems'
require 'hoe'

Hoe.spec 'rplex' do |prj|
  developer('Vassilis Rizopoulos', 'var@zuehlke.com')
  prj.version=Rplex::Version::STRING
  prj.summary = 'rplex demultiplexes jobs across multiple workers'
  prj.description = prj.paragraphs_of('README.txt', 1..5).join("\n\n")
  prj.urls = ["http://github.com/damphyr/rplex"]
  prj.changes = prj.paragraphs_of('History.txt', 0..1).join("\n\n")
  prj.extra_deps<<["sinatra", "~>1.3.2"]
  prj.extra_deps<<['rest-client',"~>1.6.7"]
end

# vim: syntax=ruby
