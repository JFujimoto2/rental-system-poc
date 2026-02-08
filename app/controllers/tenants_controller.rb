class TenantsController < ApplicationController
  before_action :set_tenant, only: %i[ show edit update destroy ]

  def index
    @tenants = Tenant.order(:name)
  end

  def show
  end

  def new
    @tenant = Tenant.new
  end

  def edit
  end

  def create
    @tenant = Tenant.new(tenant_params)

    if @tenant.save
      redirect_to @tenant, notice: "入居者を登録しました。"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @tenant.update(tenant_params)
      redirect_to @tenant, notice: "入居者を更新しました。", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @tenant.destroy!
    redirect_to tenants_path, notice: "入居者を削除しました。", status: :see_other
  end

  private

  def set_tenant
    @tenant = Tenant.find(params.expect(:id))
  end

  def tenant_params
    params.expect(tenant: [ :name, :name_kana, :phone, :email, :postal_code, :address, :emergency_contact, :notes ])
  end
end
