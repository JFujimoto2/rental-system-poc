json.extract! building, :id, :name, :address, :building_type, :floors, :built_year, :nearest_station, :notes, :created_at, :updated_at
json.url building_url(building, format: :json)
