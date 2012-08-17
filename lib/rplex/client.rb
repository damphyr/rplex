# -*- coding: utf-8 -*-
# encoding: utf-8
require 'rest_client'
require 'json'
module Rplex
  class ClientError<RuntimeError
  end
  
  class Client
    attr_reader :name,:service
    def initialize name,srv
      @name=name
      @service=srv
    end
    
    def new_job identifier,data,workers=[]
      puts "Adding #{identifier} to #{@service}"
      response=RestClient.post(@service, {"identifier"=>identifier, "data" => data,"workers"=>workers}, :content_type => :json, :accept => :json)
      return response
    rescue
      raise ClientError, $!.message
    end
    
    def next_job
      srv="#{@service}/#{@name}"
      response=RestClient.get(srv,:accept => :json)
      unless response.empty?
        return JSON.parse(response)
      else
        return {}
      end
    rescue
      raise ClientError, $!.message
    end
    
    def reset workers
      if workers && !workers.empty?
        response=RestClient.post(@service, {"workers"=>workers}, :content_type => :json, :accept => :json)
        return JSON.parse(response)
      else
        return []
      end
    rescue
      raise ClientError, $!.message
    end
    
    def backlog
      response=RestClient.get("#{@service}/backlog",:accept => :json)
      unless response.empty?
        return JSON.parse(response)
      else
        return []
      end
    rescue
      raise ClientError, $!.message
    end
    
    def configuration
      srv="#{@service}/configuration/#{@name}"
      response=RestClient.get(srv,:accept => :json)
      unless response.empty?
        return JSON.parse(response)
      else
        return {}
      end
    rescue
      raise ClientError, $!.message
    end
    
    def configure max_size
      response=RestClient.post("#{@service}/configuration", {"worker"=>@name, "maximum_size" => max_size}, :content_type => :json, :accept => :json)
      return response
    rescue
      raise ClientError, $!.message
    end
    
    def remove
      response=RestClient.delete("#{@service}/configuration/#{@name}")
      return response
    rescue
      raise ClientError, $!.message
    end
    
    def to_s
      "#{@name} working with #{@service}"
    end
  end
  
  class Processor
    def initialize client,interval=30
      @client=client
      @interval=interval
    end
    
    def run! 
      raise "You need to provide a block" unless block_given?
      while true do
        begin
          job_data=@client.next_job
          yield job_data unless job_data.empty?
        rescue ClientError
          puts $!
        end
        sleep @interval
      end
    end
  end
end