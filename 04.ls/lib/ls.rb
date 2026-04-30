#!/usr/bin/env ruby
# frozen_string_literal: true

COLUMN_COUNT = 3

def main
  dirlist = Dir.glob('*')
  padding_list = padding(dirlist)
  column_groups = split_into_columns(padding_list)

  column_groups.transpose.each do |row|
    puts row.join
  end
end

def padding(dirlist)
  max_length = dirlist.map(&:length).max
  dirlist.map do |entry|
    entry.ljust(max_length + 5)
  end
end

def split_into_columns(padding_list)
  rows_per_column = padding_list.size.ceildiv(COLUMN_COUNT)
  return padding_list if rows_per_column.zero?

  column_groups = padding_list.each_slice(rows_per_column).to_a

  max_rows = column_groups[0].size
  column_groups.each do |column|
    next if column.size == max_rows

    column.fill(nil, column.size...max_rows)
  end
end

main
