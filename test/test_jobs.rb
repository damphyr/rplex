# -*- coding: utf-8 -*-
$:.unshift File.join(File.dirname(__FILE__),"..","lib")
require "test/unit"
require "rplex/jobs"

class TestOverseer < Test::Unit::TestCase
  def test_invalid_data
    ov=Rplex::Overseer.new
    job_data={:foo=>"8888"}
    assert_raise(Rplex::InvalidData) { ov << job_data }
    job_data="foo"
    assert_raise(Rplex::InvalidData) { ov << job_data }
    assert_raise(Rplex::InvalidData) { ov << nil }
  end
  def test_basic
    ov=Rplex::Overseer.new
    job_data={"identifier"=>"8888","data"=>{:foo=>"bar",:bar=>"foo"}}
    assert_nil(ov["worker"])
    #expect that there is only 1 queue there
    assert_equal(1, ov<<job_data)
    assert_nil(ov["slave"])
    assert_equal(2, ov<<job_data)
    assert_equal(1, ov.add_job(job_data,["slave"]) )
    #go through the slave queue
    assert_equal(job_data,ov["slave"])
    assert_equal(job_data,ov["slave"])
    assert_nil(ov["slave"])
  end
  def test_backlog
    ov=Rplex::Overseer.new
    assert(ov.backlog.empty?)
    job_data={"identifier"=>"8888","data"=>{:foo=>"bar",:bar=>"foo"}}
    ov['worker1']
    ov['worker2']
    ov<<job_data
    assert_equal(2, ov.backlog.size)
    assert(ov.backlog.include?(['worker1',1]), "worker1 not present")
    assert(ov.backlog.include?(['worker2',1]), "worker2 not present")
  end
  
  def test_reset_remove
    ov=Rplex::Overseer.new
    assert(ov.backlog.empty?)
    jd1={"identifier"=>"8888","data"=>{:foo=>"bar",:bar=>"foo"}}
    jd2={"identifier"=>"9999","data"=>{:foo=>"bar",:bar=>"foo"}}
    ov['worker1']
    ov['worker2']
    ov<<jd1
    ov<<jd2
    assert_equal(2, ov.backlog.size)
    assert(ov.backlog.include?(['worker1',2]), "worker1 not present")
    assert(ov.backlog.include?(['worker2',2]), "worker2 not present")
    ov.reset(['worker2'])
    assert(ov.backlog.include?(['worker2',0]), "worker2 not 0ed")
    ov.reset(['worker1'])
    assert(ov.backlog.include?(['worker1',0]), "worker1 not 0ed")
    ov.remove('worker1')
    assert_equal([['worker2',0]], ov.backlog)
  end
  
  def test_configure
    ret=nil
    ov=Rplex::Overseer.new
    assert_nothing_raised() { ret=ov.configure('worker1',{'maximum_size'=>2}) }
    assert_equal({'worker'=>'worker1','maximum_size'=>2}, ret)
    assert_equal([['worker1',0]], ov.backlog)
    ov<<{"identifier"=>"8888","data"=>{:foo=>"bar",:bar=>"foo"}}
    assert_equal([['worker1',1]], ov.backlog)
    ov<<{"identifier"=>"8889","data"=>{:foo=>"bar",:bar=>"foo"}}
    assert_equal([['worker1',2]], ov.backlog)
    ov<<{"identifier"=>"8899","data"=>{:foo=>"bar",:bar=>"foo"}}
    assert_equal([['worker1',2]], ov.backlog)
    assert_nothing_raised() { ret=ov.configure('worker1',{'maximum_size'=>0}) }
    assert_equal({'worker'=>'worker1','maximum_size'=>0}, ret)
    assert_equal([['worker1',0]], ov.backlog)
    #and now the ugly stuff
    assert_raise(ArgumentError) { ov.configure('worker1','maximum_size'=>"foo") }
  end
  
  def test_configuration
    assert_raise(Rplex::InvalidData) {  Rplex::Overseer.new.configuration('worker1') }
  end
  def test_full_sized_queue
    ov=Rplex::Overseer.new
    jd1={"identifier"=>"8888","data"=>{:foo=>"bar",:bar=>"foo"}}
    jd2={"identifier"=>"9999","data"=>{:foo=>"bar",:bar=>"foo"}}
    jd3={"identifier"=>"7777","data"=>{:foo=>"bar",:bar=>"foo"}}
    ov.configure('worker1',{'maximum_size'=>2})
    ov<<jd1
    ov<<jd2
    ov<<jd3
    assert_equal([['worker1',2]], ov.backlog)
    assert_equal(jd2,ov['worker1'])
    assert_equal(jd3,ov['worker1'])
    assert_nil(ov['worker1'])
  end
end
