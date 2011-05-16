class ValidUserSubtypeValidator < ActiveModel::EachValidator
  # implement the method called during validation
  def validate_each(record, attribute, value)
    record.errors[attribute] << "must be of type: #{User.types.join(",")}" unless User.types.include?(value)
  end
end
