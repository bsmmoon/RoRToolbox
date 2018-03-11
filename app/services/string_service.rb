module StringService
  def self.random_string(length=10)
    rng(length: length, radix: 36)
  end

  def self.random_numeric_string(length=10)
    rng(length: length, radix: 10)
  end

  # depends on time. it may generate same number if called in very short time span (ex. automated testing)
  def self.rng(length:, radix:)
    str = ''
    loop do
      break if str.length > length
      str += Time.now.to_f.to_s.hash.to_s(radix)[1..-1]
    end
    str[0...length]
  end

  def self.float?(string)
    numeric?(string) && string.include?('.')
  end

  # thanks KC
  def self.numeric?(string)
    !!(string =~ /\A[-+]?[0-9]+(\.[0-9]+)?\z/)
  rescue TypeError, ArgumentError
    false
  end

  def self.to_f(value)
    value = value.gsub(',', '')
    return unless StringService::numeric?(value)
    value.to_f
  end

  def self.boolean?(string)
    %w'true false'.include? string.downcase
  end

  def self.to_boolean(string)
    return true if %w'true'.include? string.downcase
    false
  end
end
