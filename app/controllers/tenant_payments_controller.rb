class TenantPaymentsController < ApplicationController
  before_action :set_tenant_payment, only: %i[ show edit update destroy ]

  def index
    @tenant_payments = TenantPayment.includes(contract: [ :tenant, { room: :building } ]).order(:due_date)
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

  def tenant_payment_params
    params.expect(tenant_payment: [ :contract_id, :due_date, :amount, :paid_amount, :paid_date, :status, :payment_method, :notes ])
  end
end
