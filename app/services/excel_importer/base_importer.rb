module ExcelImporter
  class BaseImporter
    attr_reader :rows, :errors

    def initialize(file_path)
      @file_path = file_path
      @rows = []
      @errors = []
    end

    def preview
      spreadsheet = Roo::Spreadsheet.open(@file_path.to_s)
      sheet = spreadsheet.sheet(0)
      headers = sheet.row(1)

      (2..sheet.last_row).each do |i|
        row_data = sheet.row(i)
        parsed = parse_row(headers, row_data)
        row_errors = validate_row(parsed)

        @rows << { row_number: i, data: parsed, errors: row_errors }
      end

      @errors = @rows.select { |r| r[:errors].any? }.map { |r| "行#{r[:row_number]}: #{r[:errors].join(', ')}" }

      { rows: @rows, errors: @errors }
    end

    def import!
      imported = 0
      @rows.each do |row|
        next if row[:errors].any?

        record = build_record(row[:data])
        if record.save
          imported += 1
        end
      end
      imported
    end

    def valid_rows_count
      @rows.count { |r| r[:errors].empty? }
    end

    def error_rows_count
      @rows.count { |r| r[:errors].any? }
    end

    private

    def parse_row(_headers, _row_data)
      raise NotImplementedError
    end

    def validate_row(_parsed)
      raise NotImplementedError
    end

    def build_record(_data)
      raise NotImplementedError
    end
  end
end
