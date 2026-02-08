class ContractsController < ApplicationController
  before_action :set_contract, only: %i[ show edit update destroy ]

  def index
    @search_params = search_params
    @contracts = Contract.includes(:room, :tenant, room: :building).search(@search_params).order(start_date: :desc)
    respond_to do |format|
      format.html
      format.csv { send_csv(@contracts) }
    end
  end

  def show
  end

  def new
    @contract = Contract.new
  end

  def edit
  end

  def create
    @contract = Contract.new(contract_params)

    if @contract.save
      create_approval_if_needed(@contract)
      redirect_to @contract, notice: "契約を登録しました。"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @contract.update(contract_params)
      redirect_to @contract, notice: "契約を更新しました。", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @contract.destroy!
    redirect_to contracts_path, notice: "契約を削除しました。", status: :see_other
  end

  private

  def set_contract
    @contract = Contract.find(params.expect(:id))
  end

  def search_params
    params.fetch(:q, {}).permit(:building_name, :tenant_name, :status, :lease_type)
  end

  def send_csv(contracts)
    csv_data = "\xEF\xBB\xBF" + CSV.generate do |csv|
      csv << %w[建物 部屋 入居者 借家種別 契約開始日 契約終了日 月額賃料 状態]
      contracts.each do |c|
        csv << [ c.room.building.name, c.room.room_number, c.tenant.name, c.lease_type_label, c.start_date, c.end_date, c.rent, c.status_label ]
      end
    end
    send_data csv_data, filename: "contracts_#{Date.current.strftime('%Y%m%d')}.csv", type: :csv
  end

  def contract_params
    params.expect(contract: [ :room_id, :tenant_id, :master_lease_id, :lease_type, :start_date, :end_date, :rent, :management_fee, :deposit, :key_money, :renewal_fee, :status, :notes ])
  end

  def create_approval_if_needed(contract)
    return if current_user.can_approve?

    contract.approvals.create!(
      requester: current_user,
      status: :pending,
      requested_at: Time.current
    )
  end
end
