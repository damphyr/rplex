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
    assert_equal([['worker1',1],['worker2',1]], ov.backlog)
  end
end
