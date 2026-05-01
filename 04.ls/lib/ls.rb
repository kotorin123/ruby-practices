#!/usr/bin/env ruby
# frozen_string_literal: true

COLUMN_COUNT = 3

def main
  dirlist = Dir.glob('*')
  padded_filenames = pad_entries(dirlist)
  column_groups = split_into_columns(padded_filenames)

  column_groups.transpose.each do |row|
    puts row.join
  end
end

def pad_entries(dirlist)
  max_length = dirlist.map(&:length).max
  dirlist.map do |entry|
    entry.ljust(max_length + 5)
  end
end

def split_into_columns(padded_filenames)
  rows_per_column = padded_filenames.size.ceildiv(COLUMN_COUNT)
  return padded_filenames if rows_per_column.zero?

  column_groups = padded_filenames.each_slice(rows_per_column).to_a

  column_groups.each do |column|
    next if column.size == rows_per_column

    column.fill(nil, column.size...rows_per_column)
  end
end

main
