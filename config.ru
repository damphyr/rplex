#!/usr/bin/env ruby
$:.unshift File.join(File.dirname(__FILE__),"lib")
require 'rubygems'
require 'bundler/setup'
require 'rplex/server'

Rplex::Server.define_settings
Rplex::Server.run!