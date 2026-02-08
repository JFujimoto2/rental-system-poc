class MasterLeasesController < ApplicationController
  before_action :set_master_lease, only: %i[ show edit update destroy ]

  def index
    @search_params = search_params
    @master_leases = MasterLease.includes(:owner, :building).search(@search_params).order(start_date: :desc)
    respond_to do |format|
      format.html
      format.csv { send_csv(@master_leases) }
    end
  end

  def show
  end

  def new
    @master_lease = MasterLease.new
  end

  def edit
  end

  def create
    @master_lease = MasterLease.new(master_lease_params)

    if @master_lease.save
      redirect_to @master_lease, notice: "マスターリース契約を登録しました。"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @master_lease.update(master_lease_params)
      redirect_to @master_lease, notice: "マスターリース契約を更新しました。", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @master_lease.destroy!
    redirect_to master_leases_path, notice: "マスターリース契約を削除しました。", status: :see_other
  end

  private

  def set_master_lease
    @master_lease = MasterLease.find(params.expect(:id))
  end

  def search_params
    params.fetch(:q, {}).permit(:owner_id, :building_id, :status, :contract_type)
  end

  def send_csv(master_leases)
    csv_data = "\xEF\xBB\xBF" + CSV.generate do |csv|
      csv << %w[オーナー 建物 契約形態 契約開始日 契約終了日 保証賃料 状態]
      master_leases.each do |ml|
        csv << [ ml.owner.name, ml.building.name, ml.contract_type_label, ml.start_date, ml.end_date, ml.guaranteed_rent, ml.status_label ]
      end
    end
    send_data csv_data, filename: "master_leases_#{Date.current.strftime('%Y%m%d')}.csv", type: :csv
  end

  def master_lease_params
    params.expect(master_lease: [ :owner_id, :building_id, :contract_type, :start_date, :end_date, :guaranteed_rent, :management_fee_rate, :rent_review_cycle, :status, :notes ])
  end
end
