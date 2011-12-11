$:.unshift File.join(File.dirname(__FILE__),"..","lib")
require 'rubygems'
require 'rplex/client'

rplex=Rplex::Processor.new(Rplex::Client.new("loop","http://localhost:7777/job"),5)

rplex.run!{|job_data| p job_data}