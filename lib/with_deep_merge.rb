module WithDeepMerge
  def deep_merge(base_object, other_object)
    if base_object.is_a?(Hash) && other_object.is_a?(Hash)
      base_object.merge(other_object) { |_, base_value, other_value|
        deep_merge(base_value, other_value)
      }
    else
      other_object
    end
  end
end
