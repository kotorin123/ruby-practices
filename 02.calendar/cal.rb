#!/usr/bin/env ruby

require 'date'
require 'optparse'

today = Date.today
today_year = today.year
today_month = today.month

parser = OptionParser.new

options = {y: today_year, m: today_month}

parser.on('-y VAL') {|v| options[:y] = v }
parser.on('-m VAL') {|v| options[:m] = v }

parser.parse!(ARGV)

year = options[:y].to_i
month = options[:m].to_i

first_date = Date.new(year, month, 1)
last_date = Date.new(first_date.year, first_date.month, -1)

calendar_cells = []

calendar_cells += Array.new(first_date.wday, "   ")

(first_date..last_date).each do |date|
  if date.saturday? && date.day < 10
    calendar_cells.push " #{date.day}\n"
  elsif date.saturday?
    calendar_cells.push "#{date.day}\n"
  elsif date.day < 10
    calendar_cells.push " #{date.day} "
  else
    calendar_cells.push "#{date.day} "
  end
end

puts "#{month}月 #{year}".center(20)
puts "日 月 火 水 木 金 土"
puts calendar_cells.join
