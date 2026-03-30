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

scores_with_bonus = frames.each_with_object([]).with_index do |(frame, memo), i|
  if i >= 10
    next
  elsif frame[0] == 10 && frames[i + 1][0] == 10 # 連続strike
    memo.push(frame, 10, frames[i + 2][0])
  elsif frame[0] == 10 # strike
    memo.push(frame, frames[i + 1].sum)
  elsif frame.sum == 10 # spare
    memo.push(frame, frames[i + 1][0])
  else
    memo.push(frame)
  end
end

point = scores_with_bonus.flatten.sum
puts point
