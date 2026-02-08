class OwnerPaymentsController < ApplicationController
  before_action :set_owner_payment, only: %i[ show edit update destroy ]

  def index
    @search_params = search_params
    @owner_payments = OwnerPayment.includes(master_lease: [ :owner, :building ]).search(@search_params).order(:target_month)
    respond_to do |format|
      format.html
      format.csv { send_csv(@owner_payments) }
    end
  end

  def show
  end

  def new
    @owner_payment = OwnerPayment.new
  end

  def edit
  end

  def create
    @owner_payment = OwnerPayment.new(owner_payment_params)

    if @owner_payment.save
      redirect_to @owner_payment, notice: "オーナー支払を登録しました。"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @owner_payment.update(owner_payment_params)
      redirect_to @owner_payment, notice: "オーナー支払を更新しました。", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @owner_payment.destroy!
    redirect_to owner_payments_path, notice: "オーナー支払を削除しました。", status: :see_other
  end

  private

  def set_owner_payment
    @owner_payment = OwnerPayment.find(params.expect(:id))
  end

  def search_params
    params.fetch(:q, {}).permit(:owner_name, :building_name, :status, :target_month_from, :target_month_to)
  end

  def send_csv(owner_payments)
    csv_data = "\xEF\xBB\xBF" + CSV.generate do |csv|
      csv << %w[オーナー 建物 対象月 保証賃料額 控除額 支払額 状態]
      owner_payments.each do |op|
        csv << [ op.master_lease.owner.name, op.master_lease.building.name, op.target_month.strftime("%Y年%m月"), op.guaranteed_amount, op.deduction, op.net_amount, op.status_label ]
      end
    end
    send_data csv_data, filename: "owner_payments_#{Date.current.strftime('%Y%m%d')}.csv", type: :csv
  end

  def owner_payment_params
    params.expect(owner_payment: [ :master_lease_id, :target_month, :guaranteed_amount, :deduction, :net_amount, :status, :paid_date, :notes ])
  end
end
