module QueryService
  def self.time_range_query(table:, column:, from: nil, to: nil)
    return unless from.present? || to.present?
    from = Time.at(0) unless from.present?
    to = Time.now unless to.present?
    "#{table}.#{column} BETWEEN '#{from.beginning_of_day.to_s(:db)}' AND '#{to.end_of_day.to_s(:db)}'"
  end

  def self.conditional_string_query(table:, column:, value:, tolerant: false, condition: true)
    return unless condition
    if tolerant
      "LOWER(#{table}.#{column}) LIKE LOWER('%#{value}%')"
    else
      "LOWER(#{table}.#{column}) = LOWER('#{value}')"
    end
  end

  def self.conditional_integer_query(table:, column:, value:, condition: true)
    return unless condition
    "#{table}.#{column} = #{value}"
  end

  def self.conditional_boolean_query(table:, column:, value:, condition: true)
    return unless condition
    "#{table}.#{column} IS #{value}"
  end

  def self.upsert(table, columns, rows)
    rows = rows.map{|e| convert_arr_to_db_columns(e)}.join(',')
    ActiveRecord::Base.connection.execute("
        INSERT INTO #{table} (#{columns.join(',')}) VALUES #{rows}
          ON CONFLICT (id) DO
        UPDATE SET (#{columns.join(',')}) = (#{columns.map{|e| "excluded.#{e}"}.join(',')})
    ")
  end

  private

  def self.convert_arr_to_db_columns(arr)
    "(#{ (arr.map{|e| "'#{e}'"}).join(', ') })"
  end
end
