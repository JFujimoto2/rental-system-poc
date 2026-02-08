json.extract! room, :id, :building_id, :room_number, :floor, :area, :rent, :status, :room_type, :notes, :created_at, :updated_at
json.url room_url(room, format: :json)
