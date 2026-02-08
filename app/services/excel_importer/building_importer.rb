module ExcelImporter
  class BuildingImporter < BaseImporter
    private

    def parse_row(_headers, row_data)
      {
        name: row_data[0].to_s.strip.presence,
        address: row_data[1].to_s.strip.presence,
        building_type: row_data[2].to_s.strip.presence,
        floors: row_data[3].present? ? row_data[3].to_i : nil,
        built_year: row_data[4].present? ? row_data[4].to_i : nil,
        nearest_station: row_data[5].to_s.strip.presence,
        notes: row_data[6].to_s.strip.presence
      }
    end

    def validate_row(parsed)
      errors = []
      errors << "建物名は必須です" if parsed[:name].blank?
      errors
    end

    def build_record(data)
      Building.new(data)
    end
  end
end
