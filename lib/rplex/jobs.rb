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
  end
end