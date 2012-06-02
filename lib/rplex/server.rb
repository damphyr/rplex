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
    get '/' do
      [200,{'Content-Type' => 'application/json'},{"version"=>Rplex::Version::STRING}.to_json]
    end
    get '/backlog' do  
      [200,{'Content-Type' => 'application/json'},@overseer.backlog.to_json]
    end
    post '/reset' do
      begin
        reply={}
        workers= params["workers"] ? params["workers"] : @overseer.workers
        @overseer.reset(workers)
        [200,{'Content-Type' => 'application/json'},@overseer.backlog.to_json]
      rescue
        status 500
      end
    end
    ###########
    # /job
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
        #No jobs. No change
        #if the worker was not there before it has now been created, so no 404
        status 204
      end
    end
    
    ###########
    # /configuration
    get '/configuration' do 
      config=@overseer.workers.map{|worker| @overseer.configuration(worker)}
      [200,{'Content-Type' => 'application/json'},config.to_json]
    end
    get '/configuration/:worker' do |worker|
      begin
        [200,{'Content-Type' => 'application/json'},@overseer.configuration(worker).to_json]
      rescue InvalidData
        [404,{'Content-Type' => 'application/json'},$!.message]
      end
    end
    post '/configuration' do
      begin
        worker=params['worker']
        if params['maximum_size']
          max_size=params['maximum_size'].to_i
          @overseer.configure(worker,{'maximum_size'=>max_size})
          [200,{'Content-Type' => 'application/json'},@overseer.configuration(worker).to_json]
        else
          status 500
        end
      rescue
        status 500
      end
    end
    delete '/configuration/:worker' do |worker|
      @overseer.remove(worker)
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