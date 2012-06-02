# -*- coding: utf-8 -*-
require 'thread'

module Rplex
  class InvalidData < RuntimeError
  end
  #Simple queue management for Rplex job data
  class Overseer
    def initialize
      @queues={}
    end
    #Add a job for all workers currently active
    def << job_data
      add_job(job_data)
    end
    #Add a job.
    #
    #You can limit the workers it is distributed to by providing an Array 
    #with the worker identifiers
    def add_job job_data,workers=[]
      queued_in=0
      workers=@queues.keys if workers.empty?
      if valid?(job_data)
        @queues.each do |w,q|
          if workers.include?(w)
            #this handles a SizedQueue without blocking
            if q.respond_to?(:max) && q.size == q.max
              q.pop
            end
            q.push(job_data)
            queued_in+=1  
          end
        end
      else
        raise InvalidData
      end
      return queued_in
    end
    #Get the next job for the worker
    #
    #If there is no Queue for the worker, create an empty one
    def [](worker)
      @queues[worker]||=Queue.new
      @queues[worker].pop(true) rescue nil
    end
    #Get an array of [name,queue size]
    def backlog
      @queues.map{|k,v| [k,v.size]} 
    end
    #Returns true if the job data is valid
    def valid? job_data
      job_data["identifier"] && job_data["data"]
    rescue
      false
    end
    #All worker queue names
    def workers
      @queues.keys
    end
    #Empties the worker queues
    def reset workers
      workers.each{|worker| @queues[worker].clear if @queues[worker]}
    end
    #Configures the named worker
    #
    #worker_config is a Hash with possible keys:
    # "maximum_size" - when 0 then it's unlimited
    #
    #Will create a queue for the worker if it doesn't exist
    #
    #Configuring a worker will reset it's queue
    def configure worker,worker_config
      if worker_config["maximum_size"]>0
        @queues[worker]=SizedQueue.new(worker_config["maximum_size"])
      else
        @queues[worker]=Queue.new
      end
      configuration(worker)
    end
    #Returns the worker's configuration
    def configuration worker
      if @queues[worker]  
        @queues[worker].respond_to?(:max) ? max_size=@queues[worker].max : max_size=0
        {'worker'=>worker,'maximum_size'=>max_size}
      else
        raise InvalidData,"non existent queue"
      end
    end
    #Removes a queue
    def remove worker
      @queues.delete(worker)
    end
  end
end