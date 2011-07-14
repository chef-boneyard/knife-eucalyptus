# monkey patch highline to allow max_length to be 
# based on individual columns
require 'highline'
class HighLine

  alias :old_list :list

  def list( items, mode = :rows, option = nil )
    case mode
    when :columns_across

      row_count = (items.size / option.to_f).ceil

      if option.nil?
        limit  = @wrap_at || 80
        option = (limit + 2) / (max_length + 2)
      end

      rows = Array.new(row_count) { Array.new }
      items.each_with_index do |item, index|
        rows[index / option] << item
      end

      cols = Array.new(option) { Array.new }
      rows.each do |row| 
        row.each_with_index do |item, index|
          cols[index] << item
        end
      end

      max_length = cols.map do |col| 
        actual_length(
          col.max { |a, b| actual_length(a) <=> actual_length(b) }
        )
      end

      require 'enumerator'
      rows = rows.enum_for(:each_with_index).map do |row, row_index|
        row.enum_for(:each_with_index).map do |item, col_index|
          pad = max_length[col_index] + (item.length - actual_length(item))
          "%-#{pad}s" % item
        end
      end

      rows.map { |row| row.join("  ") + "\n" }.join

    else

      old_list(items, mode, option)

    end
  end
end