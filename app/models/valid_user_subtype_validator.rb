class ValidUserSubtypeValidator < ActiveModel::EachValidator
  # implement the method called during validation
  def validate_each(record, attribute, value)
    record.errors[attribute] << 'must be of type staff or eit' unless %w[Eit Staff].include?(value)
  end
end
