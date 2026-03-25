#!/usr/bin/env ruby
# frozen_string_literal: true

score = ARGV[0]

scores = score.split(',')
shots = []
scores.each do |s|
  if s == 'X'
    shots << 10
    shots << 0
  else
    shots << s.to_i
  end
end

frames = shots.each_slice(2).to_a

frames_new = frames.each_with_index do |frame, i|
  if [10, 11].include?(i)
    next
  elsif frame[0] == 10 && frames[i + 1][0] == 10 # 連続strike
    frame.push(10, frames[i + 2][0])
  elsif frame[0] == 10 # strike
    frame.push(frames[i + 1].sum)
  elsif frame.sum == 10 # spare
    frame.push(frames[i + 1][0])
  end
end

frames_new.slice!(10..)

point = frames.sum(&:sum)
puts point
