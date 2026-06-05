#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'

def main
  options = parse_options

  if $stdin.tty?
    filenames = ARGV
    file_metrics_list = build_metrics_list_from_argv(filenames)
  else
    file_content = $stdin.read
    file_metrics_list = build_metrics_list_from_stdin(file_content)
  end

  print_rows(file_metrics_list, options)
end

def parse_options
  options = []

  OptionParser.new do |opt|
    opt.on('-l') { options << :lines_count }
    opt.on('-w') { options << :words_count }
    opt.on('-c') { options << :file_size }
  end.parse!

  options = %i[lines_count words_count file_size] if options.empty?
  options
end

def build_metrics_list_from_argv(filenames)
  file_metrics_list = filenames.map do |filename|
    file_content = File.read(filename)
    file_size = File.stat(filename).size

    build_file_metrics(file_content, file_size, filename)
  end
  file_metrics_list << sum_file_metrics(file_metrics_list) if file_metrics_list.size > 1

  file_metrics_list
end

def build_metrics_list_from_stdin(file_content)
  file_size = file_content.bytesize
  [build_file_metrics(file_content, file_size)]
end

def print_rows(file_metrics_list, options)
  rows = format_rows(file_metrics_list, options)
  rows.each { |line| puts line }
end

def build_file_metrics(file_content, file_size, filename = nil)
  {
    lines_count: file_content.scan("\n").count,
    words_count: file_content.split(' ').count,
    file_size: file_size,
    file_name: filename
  }
end

def sum_file_metrics(file_metrics_list)
  {
    lines_count: file_metrics_list.sum { |hash| hash[:lines_count] },
    words_count: file_metrics_list.sum { |hash| hash[:words_count] },
    file_size: file_metrics_list.sum { |hash| hash[:file_size] },
    file_name: '合計'
  }
end

def format_rows(file_metrics_list, options)
  max_size = calc_max_width(file_metrics_list, options)

  file_metrics_list.map do |row|
    values = options.map do |key|
      row[key].to_s.rjust(max_size)
    end
    values << row[:file_name]
    values.join(' ')
  end
end

def calc_max_width(file_metrics_list, options)
  return 0 if options.size == 1 && file_metrics_list.size == 1
  return 7 if !$stdin.tty?

  %i[lines_count words_count file_size].map do |key|
    file_metrics_list.map { |data| data[key].to_s.size }.max
  end.max
end

main
