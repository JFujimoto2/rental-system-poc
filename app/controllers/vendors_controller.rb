class VendorsController < ApplicationController
  before_action :set_vendor, only: %i[ show edit update destroy ]

  def index
    @search_params = search_params
    @vendors = Vendor.search(@search_params)
    respond_to do |format|
      format.html
      format.csv { send_csv(@vendors) }
    end
  end

  def show
  end

  def new
    @vendor = Vendor.new
  end

  def edit
  end

  def create
    @vendor = Vendor.new(vendor_params)

    respond_to do |format|
      if @vendor.save
        format.html { redirect_to @vendor, notice: "業者を登録しました。" }
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @vendor.update(vendor_params)
        format.html { redirect_to @vendor, notice: "業者を更新しました。", status: :see_other }
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @vendor.destroy!

    respond_to do |format|
      format.html { redirect_to vendors_path, notice: "業者を削除しました。", status: :see_other }
    end
  end

  private

  def set_vendor
    @vendor = Vendor.find(params.expect(:id))
  end

  def vendor_params
    params.expect(vendor: [ :name, :phone, :email, :address, :contact_person, :notes ])
  end

  def search_params
    params.fetch(:q, {}).permit(:name, :phone)
  end

  def send_csv(vendors)
    csv_data = "\xEF\xBB\xBF" + CSV.generate do |csv|
      csv << %w[業者名 電話番号 メールアドレス 住所 担当者名]
      vendors.each do |v|
        csv << [ v.name, v.phone, v.email, v.address, v.contact_person ]
      end
    end
    send_data csv_data, filename: "vendors_#{Date.current.strftime('%Y%m%d')}.csv", type: :csv
  end
end
