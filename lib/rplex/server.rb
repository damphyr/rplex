require 'sinatra/base'
require 'rplex'
require 'rplex/jobs'
require 'json'
module Rplex
  
  class Server<Sinatra::Base
    def initialize
      super
      @overseer = Rplex::Overseer.new
    end
    post '/job' do
      begin
        reply={}
        workers= params["workers"] ? params["workers"] : []
        reply[:workers]=@overseer.add_job(params,workers)
        [200,{'Content-Type' => 'application/json'},reply.to_json]
      rescue
        status 500
      end
    end
    get '/job/:worker' do |worker|
      reply={}
      reply=@overseer[worker]
      if reply
        [200,{'Content-Type' => 'application/json'},reply.to_json]
      else
        status 204
      end
    end
    get '/' do
      [200,{'Content-Type' => 'application/json'},{"version"=>Rplex::Version::STRING}.to_json]
    end
    
    get '/backlog' do  
      [200,{'Content-Type' => 'application/json'},@overseer.backlog.to_json]
    end
    
    def self.define_settings cfg={}
      cfg||={}
      #the settings that are not public
      enable :logging
      enable :run
      enable :static
      set :server, %w[thin mongrel webrick]
      set :root, File.dirname(__FILE__)
      #the settings that can be changed
      cfg[:public_folder] ||= File.dirname(__FILE__) + '/public'
      cfg[:port] ||= 7777
      #set them
      set :port, cfg[:port]
      set :public_folder,cfg[:public_folder]
    end
  end
end