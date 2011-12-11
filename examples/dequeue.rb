$:.unshift File.join(File.dirname(__FILE__),"..","lib")
require 'rubygems'
require 'rplex/client'

rplex=Rplex::Client.new("loop","http://localhost:7777/job")

p rplex.next_job