class CapitalizedValidator < ActiveModel::EachValidator
  # implement the method called during validation
  def validate_each(record, attribute, value)
    if value then
      fractions = value.split(/ |-/).reject{|e| e.empty?}
      record.errors[attribute] << 'must start with capital letter' unless fractions.inject(true){|mem, el| mem &= el.eql?(el.capitalize)}
    end
  end
end
