$:.unshift File.join(File.dirname(__FILE__),"..","lib")
require 'rubygems'
require 'rplex/client'

rplex=Rplex::Client.new("loop","http://localhost:7777/job")

rplex.new_job("id",{"url"=>"http://server/build","revision"=>"8888"})
