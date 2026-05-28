#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'

def main
  options = parse_options

  if $stdin.tty?
    filenames = ARGV
    file_metrics_list = build_metrics_list_from_argv(filenames)
    print_rows(file_metrics_list, options)
  else
    file_content = $stdin.read
    file_metrics_list = build_metrics_list_from_stdin(file_content)
    print_rows(file_metrics_list, options, max_size: 7)
  end
end

def parse_options
  options = {}

  OptionParser.new do |opt|
    opt.on('-l') { |opt| options[:l] = opt }
    opt.on('-w') { |opt| options[:w] = opt }
    opt.on('-c') { |opt| options[:c] = opt }
  end.parse!
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

def print_rows(file_metrics_list, options, max_size: nil)
  rows = format_rows(file_metrics_list, options, max_size)
  rows.each { |line| puts line }
end

def build_file_metrics(file_content, file_size, filename = nil)
  {
    lines_count: file_content.scan("\n").count,
    words_count: file_content.gsub(/\s/, ' ').split(' ').count,
    file_size: file_size,
    file_name: filename
  }
end

def sum_file_metrics(file_metrics_list)
  {
    lines_count: file_metrics_list.inject(0) { |sum, hash| sum + hash[:lines_count] },
    words_count: file_metrics_list.inject(0) { |sum, hash| sum + hash[:words_count] },
    file_size: file_metrics_list.inject(0) { |sum, hash| sum + hash[:file_size] },
    file_name: '合計'
  }
end

def format_rows(file_metrics_list, options, max_size = nil)
  selected_keys = selected_keys(options)
  max_size ||= calc_max_width(file_metrics_list, selected_keys)

  if file_metrics_list[0][:file_name].nil? && selected_keys.size == 1
    [[file_metrics_list[0][selected_keys[0]]]]
  else
    file_metrics_list.map do |row|
      values = selected_keys.map do |key|
        row[key].to_s.rjust(max_size)
      end
      values << row[:file_name]
      values.join(' ')
    end
  end
end

def selected_keys(options)
  selected_keys = []
  if options.empty?
    selected_keys += %i[lines_count words_count file_size]
  else
    selected_keys << :lines_count if options[:l]
    selected_keys << :words_count if options[:w]
    selected_keys << :file_size if options[:c]
  end
  selected_keys
end

def calc_max_width(file_metrics_list, selected_keys)
  max_sizes =
    if selected_keys.size == 1 && file_metrics_list.size == 1
      selected_keys.map do |key|
        file_metrics_list.map { |data| data[key].to_s.size }.max
      end
    else
      %i[lines_count words_count file_size].map do |key|
        file_metrics_list.map { |data| data[key].to_s.size }.max
      end
    end
  max_sizes.max
end

main
