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
end