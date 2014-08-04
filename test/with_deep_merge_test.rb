require 'with_deep_merge'

class WithDeepMergeTest < Test::Unit::TestCase
  include WithDeepMerge

  def test_simple_merge
    base_hash = { "a" => "b" }
    other_hash = { "c" => "d" }
    assert_equal({ "a" => "b", "c" => "d" }, deep_merge(base_hash, other_hash))
  end

  def test_recursive_merge
    base_hash = { "a" =>  { "b" => "c", "d" => "e" } }
    other_hash = { "a" => { "b" => "z", "f" => "g" } }
    assert_equal({ "a" => { "b" => "z", "d" => "e", "f" => "g" } },
      deep_merge(base_hash, other_hash))
  end
end
