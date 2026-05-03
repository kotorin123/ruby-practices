require 'minitest/autorun'
require_relative '../lib/ls'

class LsTest < Minitest::Test
  def test_pad_entries
    dirlist = ["01.txt", "02", "03", "04", "05", "06", "07", "08", "09", "10"]
    expected = ["01.txt     ", "02         ", "03         ", "04         ", "05         ", "06         ", "07         ", "08         ", "09         ", "10         "]

    assert_equal expected, pad_entries(dirlist)
  end

  def test_split_into_columns1
    padded_filenames = ["01.txt     ", "02         ", "03         ", "04         ", "05         ", "06         "]
    expected = [["01.txt     ", "02         "], ["03         ", "04         "], ["05         ", "06         "]]

    assert_equal expected, split_into_columns(padded_filenames)
  end

  def test_split_into_columns2
    padded_filenames = ["01.txt     ", "02         ", "03         ", "04         ", "05         ", "06         ", "07         ", "08         ", "09         ", "10         "]
    expected = [["01.txt     ", "02         ", "03         ", "04         "], ["05         ", "06         ", "07         ", "08         "], ["09         ", "10         ",nil,nil]]
    
    assert_equal expected, split_into_columns(padded_filenames)
  end

end
