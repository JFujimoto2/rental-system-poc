class OwnerPaymentsController < ApplicationController
  before_action :set_owner_payment, only: %i[ show edit update destroy ]

  def index
    @owner_payments = OwnerPayment.includes(master_lease: [ :owner, :building ]).order(:target_month)
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

  def owner_payment_params
    params.expect(owner_payment: [ :master_lease_id, :target_month, :guaranteed_amount, :deduction, :net_amount, :status, :paid_date, :notes ])
  end
end
