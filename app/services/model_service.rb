module ModelService
  def self.to_h(table:, columns:, headers: nil, index: nil, override_id: false)
    headers = columns unless headers.present?
    if index.present?
      if columns.size == 1
        header = headers[0]
        table.pluck(*columns).map{|val| {header => val}}.map do |attrs|
          attrs[:id] = attrs[index] if override_id
          attrs
        end.map{|attrs| [attrs[index], attrs]}.to_h
      else
        table.pluck(*columns).map{|attrs| headers.zip(attrs).to_h}.map do |attrs|
          attrs[:id] = attrs[index] if override_id
          attrs
        end.map{|attrs| [attrs[index], attrs]}.to_h
      end
    else
      if columns.size == 1
        header = headers[0]
        table.pluck(*columns).map{|val| {header => val}}.map do |attrs|
          attrs[:id] = attrs[index] if override_id
          attrs
        end
      else
        table.pluck(*columns).map{|attrs| headers.zip(attrs).to_h}.map do |attrs|
          attrs[:id] = attrs[index] if override_id
          attrs
        end
      end
    end
  end
end
