class ContractRenewalsController < ApplicationController
  before_action :set_contract_renewal, only: %i[ show edit update destroy ]

  def index
    @search_params = search_params
    @contract_renewals = ContractRenewal.includes(contract: [ :tenant, { room: :building } ]).search(@search_params)
    respond_to do |format|
      format.html
      format.csv { send_csv(@contract_renewals) }
    end
  end

  def show
  end

  def new
    @contract_renewal = ContractRenewal.new(contract_id: params[:contract_id])
    if @contract_renewal.contract
      @contract_renewal.current_rent = @contract_renewal.contract.rent
    end
  end

  def edit
  end

  def create
    @contract_renewal = ContractRenewal.new(contract_renewal_params)

    respond_to do |format|
      if @contract_renewal.save
        format.html { redirect_to @contract_renewal, notice: "契約更新を登録しました。" }
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @contract_renewal.update(contract_renewal_params)
        format.html { redirect_to @contract_renewal, notice: "契約更新を更新しました。", status: :see_other }
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @contract_renewal.destroy!

    respond_to do |format|
      format.html { redirect_to contract_renewals_path, notice: "契約更新を削除しました。", status: :see_other }
    end
  end

  private

  def set_contract_renewal
    @contract_renewal = ContractRenewal.find(params.expect(:id))
  end

  def contract_renewal_params
    params.expect(contract_renewal: [ :contract_id, :new_contract_id, :status, :renewal_date,
      :current_rent, :proposed_rent, :renewal_fee, :tenant_notified_on, :notes ])
  end

  def search_params
    params.fetch(:q, {}).permit(:building_name, :tenant_name, :status)
  end

  def send_csv(renewals)
    csv_data = "\xEF\xBB\xBF" + CSV.generate do |csv|
      csv << %w[建物名 部屋番号 入居者名 状態 更新日 現在賃料 提案賃料 更新料]
      renewals.each do |r|
        csv << [
          r.contract.room.building.name, r.contract.room.room_number,
          r.contract.tenant.name, r.status_label, r.renewal_date,
          r.current_rent, r.proposed_rent, r.renewal_fee
        ]
      end
    end
    send_data csv_data, filename: "contract_renewals_#{Date.current.strftime('%Y%m%d')}.csv", type: :csv
  end
end
