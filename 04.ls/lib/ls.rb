#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
require 'etc'
require 'date'

COLUMN_COUNT = 3
PERMISSION_MAP = {
  '0' => '---',
  '1' => '--x',
  '2' => '-w-',
  '3' => '-wx',
  '4' => 'r--',
  '5' => 'r-x',
  '6' => 'rw-',
  '7' => 'rwx'
}.freeze

FTYPE_MAP = {
  'file' => '-',
  'directory' => 'd',
  'link' => 'l',
  'characterSpecial' => 'c',
  'fifo' => 'p',
  'socket' => 's',
  'blockSpecial' => 'b'
}.freeze

def main
  options = parse_options
  dirlist = Dir.glob('*', options[:a] ? File::FNM_DOTMATCH : 0)
  file_infos = option_l(dirlist)
  padded_filenames = pad_entries(dirlist)
  padded_filenames.reverse! if options[:r]
  file_infos.reverse! if options[:r]
  column_groups = split_into_columns(padded_filenames)

  if options[:l]
    print_total_block_size(dirlist)
    file_infos.each do |file_info|
      puts file_info.join(' ')
    end
  else
    column_groups.transpose.each do |row|
      puts row.join
    end
  end
end

def parse_options
  opt = OptionParser.new
  options = {}
  opt.on('-a', 'Show all files, including hidden files.') { |v| options[:a] = v }
  opt.on('-r', 'Reverse the order.') { |v| options[:r] = v }
  opt.on('-l', 'Display detailed file information.') { |v| options[:l] = v }
  opt.parse!(ARGV)
  options
end

def option_l(dirlist)
  file_infos = dirlist.map do |name|
    link_stat = File.lstat(name)
    ftype = FTYPE_MAP[link_stat.ftype]

    month = link_stat.mtime.strftime('%-m月')
    day = link_stat.mtime.strftime('%-d')

    [
      build_permissions(ftype, link_stat),
      link_stat.nlink, Etc.getpwuid(link_stat.uid).name,
      Etc.getgrgid(link_stat.gid).name,
      build_file_size(ftype, link_stat),
      month,
      day,
      build_time_info(link_stat),
      build_file_name(name)
    ]
  end

  format_file_infos(file_infos)
end

def print_total_block_size(dirlist)
  total_block_size = dirlist.sum { |name| File.lstat(name).blocks }
  puts "合計 #{total_block_size / 2}" if total_block_size != 0
end

def build_permissions(ftype, link_stat)
  mode = link_stat.mode.to_s(8)[-3..].chars
  permissions = mode.map { |mode| PERMISSION_MAP[mode] }.join

  ftype + permissions
end

def build_file_size(ftype, link_stat)
  if %w[c b].include?(ftype)
    "#{link_stat.rdev_major.to_s.rjust(3)},#{link_stat.rdev_minor.to_s.rjust(4)}"
  else
    link_stat.size
  end
end

def build_time_info(link_stat)
  six_months_ago = Time.now - (60 * 60 * 24 * 182)
  if link_stat.mtime < six_months_ago
    link_stat.mtime.strftime('%Y')
  else
    link_stat.mtime.strftime('%H:%M')
  end
end

def build_file_name(name)
  if File.symlink?(name)
    "#{name} -> #{File.readlink(name)}"
  else
    name
  end
end

def format_file_infos(file_infos)
  max_length = file_infos.transpose.map do |col|
    col.map do |v|
      v.to_s.length
    end.max
  end

  file_infos.map do |row|
    row.map.with_index do |value, i|
      case i
      when 1, 4, 6, 7
        value.to_s.rjust(max_length[i])
      when 2..3
        value.to_s.ljust(max_length[i])
      when 5
        value.to_s.rjust(3)
      else
        value.to_s
      end
    end
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
