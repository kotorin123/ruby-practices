require 'minitest/autorun'
require_relative '../lib/ls'

class LsTest < Minitest::Test
  def test_padding
    dirlist = ["01.txt", "02", "03", "04", "05", "06", "07", "08", "09", "10"]
    expected = ["01.txt     ", "02         ", "03         ", "04         ", "05         ", "06         ", "07         ", "08         ", "09         ", "10         "]

    assert_equal expected, padding(dirlist)
  end

  def test_split_into_columns1
    padding_list = ["01.txt     ", "02         ", "03         ", "04         ", "05         ", "06         "]
    expected = [["01.txt     ", "02         "], ["03         ", "04         "], ["05         ", "06         "]]

    assert_equal expected, split_into_columns(padding_list)
  end

  def test_split_into_columns2
    padding_list = ["01.txt     ", "02         ", "03         ", "04         ", "05         ", "06         ", "07         ", "08         ", "09         ", "10         "]
    expected = [["01.txt     ", "02         ", "03         ", "04         "], ["05         ", "06         ", "07         ", "08         "], ["09         ", "10         ",nil,nil]]
    
    assert_equal expected, split_into_columns(padding_list)
  end

  def test_output_format
    column_groups = [["01.txt     ", "02         ", "03         ", "04         "], ["05         ", "06         ", "07         ", "08         "], ["09         ", "10         ",nil,nil]]
    expected = [["01.txt     ", "05         ", "09         "], ["02         ", "06         ", "10         "], ["03         ", "07         ", nil], ["04         ", "08         ", nil]]
    
    assert_equal expected, output_format(column_groups)
  end
end
