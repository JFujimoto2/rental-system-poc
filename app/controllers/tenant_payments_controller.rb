class TenantPaymentsController < ApplicationController
  before_action :set_tenant_payment, only: %i[ show edit update destroy ]

  def index
    @search_params = search_params
    @tenant_payments = TenantPayment.includes(contract: [ :tenant, { room: :building } ]).search(@search_params).order(:due_date)
    respond_to do |format|
      format.html
      format.csv { send_csv(@tenant_payments) }
    end
  end

  def show
  end

  def new
    @tenant_payment = TenantPayment.new
  end

  def edit
  end

  def create
    @tenant_payment = TenantPayment.new(tenant_payment_params)

    if @tenant_payment.save
      redirect_to @tenant_payment, notice: "テナント入金を登録しました。"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @tenant_payment.update(tenant_payment_params)
      redirect_to @tenant_payment, notice: "テナント入金を更新しました。", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @tenant_payment.destroy!
    redirect_to tenant_payments_path, notice: "テナント入金を削除しました。", status: :see_other
  end

  private

  def set_tenant_payment
    @tenant_payment = TenantPayment.find(params.expect(:id))
  end

  def search_params
    params.fetch(:q, {}).permit(:tenant_name, :status, :payment_method, :due_date_from, :due_date_to)
  end

  def send_csv(tenant_payments)
    csv_data = "\xEF\xBB\xBF" + CSV.generate do |csv|
      csv << %w[入居者 部屋 入金期日 請求金額 入金額 状態 入金方法]
      tenant_payments.each do |tp|
        csv << [ tp.contract.tenant.name, "#{tp.contract.room.building.name} #{tp.contract.room.room_number}", tp.due_date, tp.amount, tp.paid_amount, tp.status_label, tp.payment_method_label ]
      end
    end
    send_data csv_data, filename: "tenant_payments_#{Date.current.strftime('%Y%m%d')}.csv", type: :csv
  end

  def tenant_payment_params
    params.expect(tenant_payment: [ :contract_id, :due_date, :amount, :paid_amount, :paid_date, :status, :payment_method, :notes ])
  end
end
