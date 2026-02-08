class ConstructionsController < ApplicationController
  before_action :set_construction, only: %i[ show edit update destroy ]

  def index
    @search_params = search_params
    @constructions = Construction.includes(room: :building, vendor: nil).search(@search_params)
    respond_to do |format|
      format.html
      format.csv { send_csv(@constructions) }
    end
  end

  def show
  end

  def new
    @construction = Construction.new(room_id: params[:room_id])
  end

  def edit
  end

  def create
    @construction = Construction.new(construction_params)

    respond_to do |format|
      if @construction.save
        format.html { redirect_to @construction, notice: "工事を登録しました。" }
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @construction.update(construction_params)
        format.html { redirect_to @construction, notice: "工事を更新しました。", status: :see_other }
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @construction.destroy!

    respond_to do |format|
      format.html { redirect_to constructions_path, notice: "工事を削除しました。", status: :see_other }
    end
  end

  private

  def set_construction
    @construction = Construction.find(params.expect(:id))
  end

  def construction_params
    params.expect(construction: [ :room_id, :vendor_id, :construction_type, :status, :title, :description,
      :estimated_cost, :actual_cost, :scheduled_start_date, :scheduled_end_date,
      :actual_start_date, :actual_end_date, :cost_bearer, :notes ])
  end

  def search_params
    params.fetch(:q, {}).permit(:building_name, :vendor_name, :construction_type, :status, :cost_bearer)
  end

  def send_csv(constructions)
    csv_data = "\xEF\xBB\xBF" + CSV.generate do |csv|
      csv << %w[建物名 部屋番号 業者名 工事種別 状態 工事件名 見積金額 実績金額 費用負担]
      constructions.each do |c|
        csv << [
          c.room.building.name, c.room.room_number, c.vendor&.name,
          c.construction_type_label, c.status_label, c.title,
          c.estimated_cost, c.actual_cost, c.cost_bearer_label
        ]
      end
    end
    send_data csv_data, filename: "constructions_#{Date.current.strftime('%Y%m%d')}.csv", type: :csv
  end
end
