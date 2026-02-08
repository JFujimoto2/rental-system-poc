class TenantsController < ApplicationController
  before_action :set_tenant, only: %i[ show edit update destroy ]

  def index
    @search_params = search_params
    @tenants = Tenant.search(@search_params).order(:name)
    respond_to do |format|
      format.html
      format.csv { send_csv(@tenants) }
    end
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

  def search_params
    params.fetch(:q, {}).permit(:name, :name_kana, :phone)
  end

  def send_csv(tenants)
    csv_data = "\xEF\xBB\xBF" + CSV.generate do |csv|
      csv << %w[入居者名 入居者名カナ 電話番号 メールアドレス]
      tenants.each do |t|
        csv << [ t.name, t.name_kana, t.phone, t.email ]
      end
    end
    send_data csv_data, filename: "tenants_#{Date.current.strftime('%Y%m%d')}.csv", type: :csv
  end

  def tenant_params
    params.expect(tenant: [ :name, :name_kana, :phone, :email, :postal_code, :address, :emergency_contact, :notes ])
  end
end
