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

  def self.upsert(table, columns, rows, uniq)
    rows = rows.map{|e| convert_arr_to_db_columns(e)}.join(',')
    ActiveRecord::Base.connection.execute("
        INSERT INTO #{table} (#{columns.join(',')}) VALUES #{rows}
          ON CONFLICT (#{uniq}) DO
        UPDATE SET (#{columns.join(',')}) = (#{columns.map{|e| "excluded.#{e}"}.join(',')})
    ")
  end

  private

  def self.sanitize_string_for_db(str, db_type: :pg)
    case db_type
      when :pg
        str.gsub("'", "''")
      else
        raise StandardError, "Unexpected db_type '#{db_type}' received"
    end
  end

  def self.sanitize_col(col, db_type: :pg)
    if col.class == String
      if StringService::numeric? col
        col.to_f
      else
        "'#{sanitize_string_for_db(col, db_type: db_type)}'"
      end
    elsif col.nil?
      'NULL'
    else
      "'#{col}'"
    end
  end

  def self.convert_arr_to_db_columns(arr, db_type: :pg)
    "(#{ (arr.map{|e| sanitize_col(e, db_type: db_type)}).join(', ') })"
  end
end
