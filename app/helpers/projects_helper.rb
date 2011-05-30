module ProjectsHelper
  def uncamel(str)
    return "" if str.nil?
    str = str.gsub(/([A-Z]+|[A-Z][a-z])/) {|x| ' ' + x }
    str = str.gsub(/[A-Z][a-z]+/) {|x| ' ' + x }
    return str.split(" ").reject{|part| part.empty?}.collect{|part| part.capitalize}.join(" ")
  end
end
