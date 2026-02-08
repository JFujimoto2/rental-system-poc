class ContractsController < ApplicationController
  before_action :set_contract, only: %i[ show edit update destroy ]

  def index
    @contracts = Contract.includes(:room, :tenant, room: :building).order(start_date: :desc)
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

  def contract_params
    params.expect(contract: [ :room_id, :tenant_id, :master_lease_id, :lease_type, :start_date, :end_date, :rent, :management_fee, :deposit, :key_money, :renewal_fee, :status, :notes ])
  end
end
