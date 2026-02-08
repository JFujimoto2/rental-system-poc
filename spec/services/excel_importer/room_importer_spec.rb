require 'rails_helper'

RSpec.describe ExcelImporter::RoomImporter do
  let!(:building) { create(:building, name: 'テストビルA') }
  let(:file_path) { Rails.root.join('spec/fixtures/files/rooms.xlsx') }

  before do
    generate_room_xlsx(file_path)
  end

  after do
    FileUtils.rm_f(file_path)
  end

  describe '#preview' do
    it '正常データをパースできる' do
      importer = described_class.new(file_path)
      result = importer.preview

      expect(result[:rows].size).to eq 2
      expect(result[:rows][0][:data][:room_number]).to eq '101'
      expect(result[:rows][1][:data][:room_number]).to eq '102'
      expect(result[:errors]).to be_empty
    end

    it '存在しない建物名はエラーになる' do
      generate_room_xlsx(file_path, include_invalid_building: true)
      importer = described_class.new(file_path)
      result = importer.preview

      error_rows = result[:rows].select { |r| r[:errors].any? }
      expect(error_rows.size).to eq 1
      expect(error_rows[0][:errors]).to include(/建物/)
    end

    it '部屋番号が空の行はエラーになる' do
      generate_room_xlsx(file_path, include_missing_room_number: true)
      importer = described_class.new(file_path)
      result = importer.preview

      error_rows = result[:rows].select { |r| r[:errors].any? }
      expect(error_rows.size).to eq 1
      expect(error_rows[0][:errors]).to include(/部屋番号/)
    end
  end

  describe '#import!' do
    it '部屋を一括登録できる' do
      importer = described_class.new(file_path)
      importer.preview

      expect { importer.import! }.to change(Room, :count).by(2)
    end

    it '登録した部屋が正しい建物に紐づく' do
      importer = described_class.new(file_path)
      importer.preview
      importer.import!

      room = Room.find_by(room_number: '101')
      expect(room.building).to eq building
    end
  end

  private

  def generate_room_xlsx(path, include_invalid_building: false, include_missing_room_number: false)
    require 'caxlsx'
    package = Axlsx::Package.new
    package.workbook.add_worksheet(name: '部屋') do |sheet|
      sheet.add_row %w[建物名 部屋番号 階数 面積 賃料 間取り 状態 備考]
      sheet.add_row [ 'テストビルA', '101', 1, 25.5, 80_000, '1K', '空室', '' ]
      sheet.add_row [ 'テストビルA', '102', 1, 30.0, 90_000, '1DK', '空室', '' ]
      sheet.add_row [ '存在しないビル', '201', 2, 40.0, 120_000, '2LDK', '空室', '' ] if include_invalid_building
      sheet.add_row [ 'テストビルA', '', 3, 35.0, 100_000, '1LDK', '空室', '' ] if include_missing_room_number
    end
    package.serialize(path.to_s)
  end
end
