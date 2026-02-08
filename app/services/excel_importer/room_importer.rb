module ExcelImporter
  class RoomImporter < BaseImporter
    STATUS_MAP = {
      "空室" => :vacant,
      "入居中" => :occupied,
      "退去予定" => :notice
    }.freeze

    private

    def parse_row(_headers, row_data)
      {
        building_name: row_data[0].to_s.strip.presence,
        room_number: row_data[1].to_s.strip.presence,
        floor: row_data[2].present? ? row_data[2].to_i : nil,
        area: row_data[3].present? ? row_data[3].to_f : nil,
        rent: row_data[4].present? ? row_data[4].to_i : nil,
        room_type: row_data[5].to_s.strip.presence,
        status_label: row_data[6].to_s.strip.presence,
        notes: row_data[7].to_s.strip.presence
      }
    end

    def validate_row(parsed)
      errors = []
      errors << "建物名は必須です" if parsed[:building_name].blank?
      errors << "部屋番号は必須です" if parsed[:room_number].blank?

      if parsed[:building_name].present? && !Building.exists?(name: parsed[:building_name])
        errors << "建物「#{parsed[:building_name]}」が見つかりません"
      end

      errors
    end

    def build_record(data)
      building = Building.find_by(name: data[:building_name])
      status = STATUS_MAP[data[:status_label]] || :vacant

      Room.new(
        building: building,
        room_number: data[:room_number],
        floor: data[:floor],
        area: data[:area],
        rent: data[:rent],
        room_type: data[:room_type],
        status: status,
        notes: data[:notes]
      )
    end
  end
end
