class MasterLeasesController < ApplicationController
  before_action :set_master_lease, only: %i[ show edit update destroy ]

  def index
    @master_leases = MasterLease.includes(:owner, :building).order(start_date: :desc)
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

  def master_lease_params
    params.expect(master_lease: [ :owner_id, :building_id, :contract_type, :start_date, :end_date, :guaranteed_rent, :management_fee_rate, :rent_review_cycle, :status, :notes ])
  end
end
