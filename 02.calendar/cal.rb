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

first_day = Date.new(year, month, 1)
last_day = Date.new(first_day.year, first_day.month, -1)

date_weekdays = (first_day..last_day).to_h { |d| [d.day, d.wday] }

calendar_cells = []
first_day.strftime('%w').to_i.times{calendar_cells.push "   "}
date_weekdays.each do |day, weekday|
  if weekday == 6 && day < 10
    calendar_cells.push " #{day}\n"
  elsif weekday == 6
    calendar_cells.push "#{day}\n"
  elsif day < 10
    calendar_cells.push " #{day} "
  else
    calendar_cells.push "#{day} "
  end
end

puts "#{first_day.month}月 #{first_day.year}".center(20)
puts "日 月 火 水 木 金 土"
puts calendar_cells.join
