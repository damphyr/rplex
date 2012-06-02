# -*- coding: utf-8 -*-
# encoding: utf-8
$:.unshift File.join(File.dirname(__FILE__),"..","lib")
require "test/unit"
require "rplex"

class TestRplex < Test::Unit::TestCase
  def test_version
    assert_equal(Rplex::Version::STRING, "#{Rplex::Version::MAJOR}.#{Rplex::Version::MINOR}.#{Rplex::Version::TINY}")
  end
end
