class ImportsController < ApplicationController
  def new
  end

  def preview
    unless params.dig(:import, :file)
      redirect_to new_import_path, alert: "ファイルを選択してください。"
      return
    end

    @import_type = params[:import][:import_type]
    uploaded_file = params[:import][:file]

    # Save to tmp for preview and later import
    @tmp_path = Rails.root.join("tmp", "import_#{SecureRandom.hex(8)}.xlsx")
    File.binwrite(@tmp_path, uploaded_file.read)

    @importer = build_importer(@import_type, @tmp_path)
    @result = @importer.preview

    session[:import_file_path] = @tmp_path.to_s
    session[:import_type] = @import_type
  end

  def create
    import_type = params[:import_type] || session[:import_type]
    file_path = session[:import_file_path]

    unless file_path && File.exist?(file_path)
      redirect_to new_import_path, alert: "インポートデータが見つかりません。再度アップロードしてください。"
      return
    end

    importer = build_importer(import_type, file_path)
    importer.preview
    imported_count = importer.import!

    # Clean up
    FileUtils.rm_f(file_path)
    session.delete(:import_file_path)
    session.delete(:import_type)

    redirect_path = import_type == "room" ? rooms_path : buildings_path
    redirect_to redirect_path, notice: "#{imported_count}件のデータをインポートしました。"
  end

  private

  def build_importer(import_type, file_path)
    case import_type
    when "building"
      ExcelImporter::BuildingImporter.new(file_path)
    when "room"
      ExcelImporter::RoomImporter.new(file_path)
    else
      raise ArgumentError, "不正なインポート種別: #{import_type}"
    end
  end
end
