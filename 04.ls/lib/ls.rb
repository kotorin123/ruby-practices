#!/usr/bin/env ruby
# frozen_string_literal: true

def main
  dirlist = Dir.glob('*')
  padding_list = padding(dirlist)
  column_groups = split_into_columns(padding_list)
  output_format(column_groups)
end

def padding(dirlist)
  max_length = dirlist.map(&:length).max
  dirlist.map do |entry|
    entry.ljust(max_length + 5)
  end
end

def split_into_columns(padding_list)
  column_count = 3
  adjust_length = padding_list.size

  adjust_length += 1 until (adjust_length % column_count).zero?

  rows_per_column = adjust_length / column_count
  column_groups = padding_list.each_slice(rows_per_column).to_a

  max_rows = column_groups[0].size
  column_groups.each do |column|
    next unless column.size != max_rows

    missing_count = max_rows - column.size
    missing_count.times do
      column.push nil
    end
  end
end

def output_format(column_groups)
  column_groups.transpose.each do |row|
    puts row.join
  end
end

main
