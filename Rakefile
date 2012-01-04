# -*- ruby -*-
$:.unshift File.join(File.dirname(__FILE__),"lib")
require 'rubygems'
require 'hoe'
require 'rplex'

Hoe.spec 'rplex' do |prj|
  developer('Vassilis Rizopoulos', 'var@zuehlke.com')
  prj.version=Rplex::Version::STRING
  prj.summary = 'rplex multiplexes jobs across multiple workers'
  prj.description = prj.paragraphs_of('README.txt', 1..4).join("\n\n")
  prj.url = "http://github.com/damphyr/rplex"
  prj.changes = prj.paragraphs_of('History.txt', 0..1).join("\n\n")
  prj.extra_deps<<["sinatra", "~>1.3.1"]
  prj.extra_deps<<['rest-client',"~>1.6.7"]
end

# vim: syntax=ruby
