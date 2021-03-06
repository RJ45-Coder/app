require 'test_helper'
require 'app'
require 'stringio'

class App < Configurable
  config.logger   = Logger.new StringIO.new

  config.tubular  = "way cool"
  config.awesome  = nil
  config.mondo    = lambda { |a, b| return a, b }

  config.can_do   = false
  def self.can_do?
    true
  end

  def self.destroy_something!
  end
end

class AppTest < ActiveSupport::TestCase
  test "should access many ways" do
    assert_equal "way cool", App.tubular
    assert_equal "way cool", App["tubular"]
    assert_equal "way cool", App[:tubular]
  end

  test 'should have new methods' do
    assert_equal true, App.respond_to?(:can_do?)
    assert_nothing_raised { App.method(:can_do?) }
    assert_equal true, App.can_do?
    assert_equal false, App.can_do

    assert_equal true, App.respond_to?(:destroy_something!)
    assert_nothing_raised { App.method(:destroy_something!) }


    assert_equal true, App.respond_to?(:tubular)
    assert_equal true, App.respond_to?(:tubular?)
    assert_nothing_raised { App.method(:tubular) }

    assert_equal true, App.respond_to?(:awesome)
    assert_equal true, App.respond_to?(:awesome?)
    assert_nothing_raised { App.method(:awesome) }

    assert_equal false, App.respond_to?(:tubular111)
    assert_equal false, App.respond_to?(:tubular111?)
    assert_raise(NameError) { App.method(:tubular111) }
  end

  test "should return booleans" do
    assert_equal true, App.tubular?
    assert_equal false, App.awesome?
  end

  test "should pass args" do
    assert_nothing_raised do
      App.mondo(1, 2)
    end
  end

  test "should warn for nonexistent keys" do
    log = App.logger.instance_variable_get(:@logdev).dev
    orig_length = log.length
    App.outrageous!
    assert_not_equal orig_length, log.length
  end

  test "should be reopenable" do
    App.configure do
      config.funky = Time.now
    end

    assert App.funky.is_a?(Time)
  end

  test "should be private" do
    assert_raise(NoMethodError) { App.assign = "this" }
    assert_raise(NoMethodError) { App.config = {} }
  end
end
