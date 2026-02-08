class InsurancesController < ApplicationController
  before_action :set_insurance, only: %i[ show edit update destroy ]

  def index
    @search_params = search_params
    @insurances = Insurance.includes(:building, :room).search(@search_params)
    respond_to do |format|
      format.html
      format.csv { send_csv(@insurances) }
    end
  end

  def show
  end

  def new
    @insurance = Insurance.new
  end

  def edit
  end

  def create
    @insurance = Insurance.new(insurance_params)

    respond_to do |format|
      if @insurance.save
        format.html { redirect_to @insurance, notice: "保険を登録しました。" }
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @insurance.update(insurance_params)
        format.html { redirect_to @insurance, notice: "保険を更新しました。", status: :see_other }
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @insurance.destroy!

    respond_to do |format|
      format.html { redirect_to insurances_path, notice: "保険を削除しました。", status: :see_other }
    end
  end

  private

  def set_insurance
    @insurance = Insurance.find(params.expect(:id))
  end

  def insurance_params
    params.expect(insurance: [ :building_id, :room_id, :insurance_type, :status,
      :policy_number, :provider, :coverage_amount, :premium,
      :start_date, :end_date, :notes ])
  end

  def search_params
    params.fetch(:q, {}).permit(:building_name, :insurance_type, :status, :provider)
  end

  def send_csv(insurances)
    csv_data = "\xEF\xBB\xBF" + CSV.generate do |csv|
      csv << %w[建物名 部屋番号 保険種別 状態 証券番号 保険会社名 補償額 保険料 開始日 終了日]
      insurances.each do |i|
        csv << [
          i.building&.name, i.room&.room_number,
          i.insurance_type_label, i.status_label, i.policy_number,
          i.provider, i.coverage_amount, i.premium,
          i.start_date, i.end_date
        ]
      end
    end
    send_data csv_data, filename: "insurances_#{Date.current.strftime('%Y%m%d')}.csv", type: :csv
  end
end
