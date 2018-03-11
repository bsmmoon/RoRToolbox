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

  def self.insert(table, columns, rows)
    rows = rows.map{|e| convert_arr_to_db_columns(e)}.join(',')
    return unless rows.present?
    ActiveRecord::Base.connection.execute("INSERT INTO #{table} (#{columns.join(',')}) VALUES #{rows}")
  end

  def self.upsert(table_name, columns, rows, uniqs)
    rows = rows.map{|e| convert_arr_to_db_columns(e)}.join(',')
    return unless rows.present?

    table = table_name.classify.constantize
    uniqs = [uniqs] if uniqs.class != Array

    rows_to_be_created = rows

    uniqs.each do |uniq|
      uniq_constrained_col_index = row.index(uniq)
      existing = Set.new(table.pluck(uniq))

      rows_to_be_updated = []
      pruned_rows_to_be_created = []
      rows_to_be_created.each do |row|
        if existing.include? row[uniq_constrained_col_index]
          rows_to_be_updated << row
        else
          pruned_rows_to_be_created << row
        end
      end
      rows_to_be_created = pruned_rows_to_be_created

      rows_to_be_updated = rows_to_be_updated.map{ |_, e| convert_hash_to_db_columns(e, columns) }.join(',')

      QueryService::update(table_name, columns, rows_to_be_updated)
    end
    QueryService::insert(table_name, columns, rows_to_be_created)
  end

  def self.update(table, columns, rows, id='id')
    id_index = columns.index(id)
    mapped = rows.map{|e| e[id_index]}.join(',')
    mapping = rows.map{|e| "WHEN '#{e[id_index]}' THEN #{convert_arr_to_db_columns(ArrayService::delete_at(e, id_index))}"}.join(' ')
    ActiveRecord::Base.connection.execute("UPDATE #{table} SET (#{ArrayService::delete_at(columns, id_index).join(',')}) = (CASE id #{mapping} END) WHERE #{table}.#{id} IN (#{mapped})")
  end

  def self.sort(table:, sorters:)
    table.order(sorters.map{|sorter| "#{sorter['attr']} #{sorter['order']}"})
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
        if StringService::float? col
          col.to_f
        else
          col.to_i
        end
      elsif StringService::boolean?(col)
        StringService::to_boolean(col)
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
