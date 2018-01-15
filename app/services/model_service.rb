=begin
  table: ActiveRecord
  columns: Array of string / symbol. It can be a column of joined table.
  headers: Array of string / symbol. By default equals to columns.
  index: Object. Index each hash objects by this. Array will be returned if not provided. Should be in header.
  override_id: Boolean. If true, each hash's id will be overridden by index attribute.
=end

module ModelService
  def self.latest_records(table:, time: nil)
    if time.present?
      time = table.where('time <= ?', time.end_of_day).maximum(:time)
    else
      time = table.maximum(:time)
    end
    table.where(time: time)
  end

  def self.to_h(table:, columns:, headers: nil, index: nil, override_id: false, modifiers: {})
    raise Exception, 'columns length and headers length should be equal' if headers.present? && columns.length != headers.length
    raise Exception, 'can override id iff index is provided' if override_id.present? && !index.present?

    headers = columns unless headers.present?

    raise Exception, 'given index attribute is not known' if index.present? && !headers.include?(index)

    if columns.size == 1
      output = to_h_single_column(table, columns, headers, index, override_id, modifiers)
    else
      output = to_h_multiple_columns(table, columns, headers, index, override_id, modifiers)
    end

    if index.present?
      output = output.map{|attrs| [attrs[index], attrs]}.to_h
    end

    output
  end

  def self.index(table:, index:)
    table.all.map{|row| [row[index], row]}.to_h
  end

  private

  def self.to_h_multiple_columns(table, columns, headers, index, override_id, modifiers)
    table.pluck(*columns).map{|attrs| headers.zip(attrs).to_h}.map do |attrs|
      attrs[:id] = attrs[index] if override_id
      modifiers.each {|attr, modifier| attrs[attr] = modifier.call(attrs[attr])}
      attrs
    end
  end

  def self.to_h_single_column(table, columns, headers, index, override_id, modifiers: {})
    header = headers[0]
    table.pluck(*columns).map{|val| {header => val}}.map do |attrs|
      attrs[:id] = attrs[index] if override_id
      modifiers.each {|attr, modifier| attrs[attr] = modifier.call(attrs[attr])}
      attrs
    end
  end
end
