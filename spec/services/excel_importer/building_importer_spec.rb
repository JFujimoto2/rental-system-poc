require 'rails_helper'

RSpec.describe ExcelImporter::BuildingImporter do
  let(:file_path) { Rails.root.join('spec/fixtures/files/buildings.xlsx') }

  before do
    generate_building_xlsx(file_path)
  end

  after do
    FileUtils.rm_f(file_path)
  end

  describe '#preview' do
    it '正常データをパースできる' do
      importer = described_class.new(file_path)
      result = importer.preview

      expect(result[:rows].size).to eq 2
      expect(result[:rows][0][:data][:name]).to eq 'テストビルA'
      expect(result[:rows][1][:data][:name]).to eq 'テストビルB'
      expect(result[:errors]).to be_empty
    end

    it '必須項目が空の行はエラーになる' do
      generate_building_xlsx(file_path, include_invalid: true)
      importer = described_class.new(file_path)
      result = importer.preview

      error_rows = result[:rows].select { |r| r[:errors].any? }
      expect(error_rows.size).to eq 1
      expect(error_rows[0][:errors]).to include(/建物名/)
    end
  end

  describe '#import!' do
    it '建物を一括登録できる' do
      importer = described_class.new(file_path)
      importer.preview

      expect { importer.import! }.to change(Building, :count).by(2)
    end

    it 'バリデーションエラーがある行はスキップして他を登録する' do
      generate_building_xlsx(file_path, include_invalid: true)
      importer = described_class.new(file_path)
      importer.preview

      expect { importer.import! }.to change(Building, :count).by(2)
    end
  end

  private

  def generate_building_xlsx(path, include_invalid: false)
    require 'caxlsx'
    package = Axlsx::Package.new
    package.workbook.add_worksheet(name: '建物') do |sheet|
      sheet.add_row %w[建物名 住所 構造 階数 築年 最寄駅 備考]
      sheet.add_row [ 'テストビルA', '東京都渋谷区1-1', 'RC', 5, 2010, '渋谷駅', '' ]
      sheet.add_row [ 'テストビルB', '東京都新宿区2-2', 'SRC', 10, 2015, '新宿駅', 'テスト備考' ]
      sheet.add_row [ '', '東京都港区3-3', '木造', 2, 2020, '品川駅', '' ] if include_invalid
    end
    package.serialize(path.to_s)
  end
end
