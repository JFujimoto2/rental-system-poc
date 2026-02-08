class SettlementsController < ApplicationController
  before_action :set_settlement, only: [ :show, :edit, :update, :destroy ]

  def index
    @settlements = Settlement.includes(contract: [ :tenant, { room: :building } ]).order(created_at: :desc)
  end

  def show
  end

  def new
    @settlement = Settlement.new(contract_id: params[:contract_id])
    @contracts = Contract.includes(:tenant, { room: :building }).where.not(status: :applying).order(:id)
  end

  def create
    @settlement = Settlement.new(settlement_params)

    if @settlement.settlement_type == "tenant_rent"
      @settlement.calculate_prorated_rent
    elsif @settlement.settlement_type == "tenant_deposit"
      @settlement.calculate_deposit_refund
    end

    if @settlement.save
      redirect_to @settlement, notice: "精算を作成しました。"
    else
      @contracts = Contract.includes(:tenant, { room: :building }).where.not(status: :applying).order(:id)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @contracts = Contract.includes(:tenant, { room: :building }).where.not(status: :applying).order(:id)
  end

  def update
    @settlement.assign_attributes(settlement_params)

    if @settlement.settlement_type == "tenant_rent"
      @settlement.calculate_prorated_rent
    elsif @settlement.settlement_type == "tenant_deposit"
      @settlement.calculate_deposit_refund
    end

    if @settlement.save
      redirect_to @settlement, notice: "精算を更新しました。"
    else
      @contracts = Contract.includes(:tenant, { room: :building }).where.not(status: :applying).order(:id)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @settlement.destroy
    redirect_to settlements_path, notice: "精算を削除しました。", status: :see_other
  end

  private

  def set_settlement
    @settlement = Settlement.find(params[:id])
  end

  def settlement_params
    params.require(:settlement).permit(
      :contract_id, :settlement_type, :termination_date,
      :deposit_amount, :restoration_cost, :other_deductions,
      :status, :notes
    )
  end
end
