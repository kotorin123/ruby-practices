#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'

def main
  options = parse_options
  stdin_is_tty = $stdin.tty?

  if stdin_is_tty
    filenames = ARGV
    file_metrics_list = build_metrics_list_from_argv(filenames)
  else
    file_content = $stdin.read
    file_metrics_list = build_metrics_list_from_stdin(file_content)
  end

  print_rows(file_metrics_list, options, stdin_is_tty)
end

def parse_options
  options = {}

  OptionParser.new do |opt|
    opt.on('-l') { |opt| options[:l] = opt }
    opt.on('-w') { |opt| options[:w] = opt }
    opt.on('-c') { |opt| options[:c] = opt }
  end.parse!

  options = { l: true, w: true, c: true } if options.empty?
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

def print_rows(file_metrics_list, options, stdin_is_tty)
  rows = format_rows(file_metrics_list, options, stdin_is_tty)
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

def format_rows(file_metrics_list, options, stdin_is_tty)
  selected_keys = selected_keys(options)
  max_size ||= calc_max_width(file_metrics_list, selected_keys, stdin_is_tty)

  file_metrics_list.map do |row|
    values = selected_keys.map do |key|
      row[key].to_s.rjust(max_size)
    end
    values << row[:file_name]
    values.join(' ')
  end
end

def selected_keys(options)
  selected_keys = []

  selected_keys << :lines_count if options[:l]
  selected_keys << :words_count if options[:w]
  selected_keys << :file_size if options[:c]

  selected_keys
end

def calc_max_width(file_metrics_list, selected_keys, stdin_is_tty)
  if selected_keys.size == 1 && file_metrics_list.size == 1
    0
  elsif !stdin_is_tty
    7
  else
    %i[lines_count words_count file_size].map do |key|
      file_metrics_list.map { |data| data[key].to_s.size }.max
    end.max
  end
end

main
