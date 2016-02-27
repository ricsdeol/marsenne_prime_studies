#!/usr/bin/env ruby
require 'rubygems'
require 'bundler/setup'
Bundler.require :default

#inpired by http://rosettacode.org/wiki/Lucas-Lehmer_test#Ruby
class MersennePrime

  def initialize(number)
    @number = number
  end

  def test
    @number if is_prime? && is_mersenne_prime?
  end

  def is_prime?
    return true  if @number == 2
    return false if @number <= 1 || @number.even?
    (3 .. Math.sqrt(@number)).step(2) do |i|
      return false  if @number % i == 0
    end
    true
  end

  def is_mersenne_prime?
    return true  if @number == 2

    # 1 << number = 2**number
    m_p = ( 1 << @number ) - 1
    s = 4
    (@number-2).times { s = (s ** 2 - 2) % m_p }
    s == 0
  end
end

numbers = Concurrent::Array.new
pool = Concurrent::CachedThreadPool.new(
:min_threads => [2, Concurrent.processor_count].max,
:max_threads => [2, Concurrent.processor_count].max
)

upb_prime = 3000


puts " Finding Mersenne primes in M[2..#{upb_prime}]:"

(2..upb_prime).each do |p|
  pool.post do
    number = MersennePrime.new(p).test
    unless number.nil?
      numbers.push number
      puts "M#{number}"
    end
  end
end

puts numbers
