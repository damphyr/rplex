# -*- coding: utf-8 -*-
$:.unshift File.join(File.dirname(__FILE__),"..","lib")
require 'test/unit'
require 'rubygems'
require 'rplex/server'
require 'rack/test'
require 'json'

class ServerTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    Rplex::Server
  end
  
  def test_root
    get '/'
    assert_equal({"version"=>Rplex::Version::STRING},JSON.parse(last_response.body))
  end
  
  def test_new
    post '/job', :identifier=>"8888",:data=>{:url=>"http://foo.bar/drops",:revision=>"8888"}
    assert_not_nil(JSON.parse(last_response.body)["workers"])
    
    post '/job', :foo=>"bar"
    assert_equal(500, last_response.status)
  end
  
  def test_job
    get '/job/worker'
    assert_equal(204,last_response.status)
    payload={"identifier"=>"8888","data"=>{"url"=>"http://foo.bar/drops","revision"=>"8888"}}
    post '/job', payload
    get '/job/worker'
    assert_equal(200,last_response.status)
    assert_equal(payload,JSON.parse(last_response.body))
  end
  
  def test_backlog
    get '/backlog'
    assert_equal(200, last_response.status)
  end
  
  def test_reset_remove
    #do this because tests are otherwise exec sequence dependent
    post '/configuration', {'worker'=>'worker','maximum_size'=>0}
    payload={"identifier"=>"8888","data"=>{"url"=>"http://foo.bar/drops","revision"=>"8888"}}
    post '/job', payload
    post '/job', payload
    get '/backlog'
    assert_equal([["worker",2]], JSON.parse(last_response.body))
    post '/reset',{"workers"=>['worker']}
    get '/backlog'
    assert_equal([["worker",0]], JSON.parse(last_response.body))
    delete '/configuration/worker'
    get '/backlog'
    assert_equal([], JSON.parse(last_response.body))
  end
  
  def test_configuration
    get '/configuration'
    assert_equal([], JSON.parse(last_response.body))
    get '/job/worker'
    get '/configuration'
    assert_equal([{'worker'=>'worker','maximum_size'=>0}], JSON.parse(last_response.body))
    post '/configuration', {'worker'=>'worker','maximum_size'=>1}
    get '/configuration/worker'
    assert_equal({'worker'=>'worker','maximum_size'=>1}, JSON.parse(last_response.body))
  end
end