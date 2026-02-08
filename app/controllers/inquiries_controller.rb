class InquiriesController < ApplicationController
  before_action :set_inquiry, only: %i[ show edit update destroy ]

  def index
    @search_params = search_params
    @inquiries = Inquiry.includes(:room, :tenant).search(@search_params)
    respond_to do |format|
      format.html
      format.csv { send_csv(@inquiries) }
    end
  end

  def show
  end

  def new
    @inquiry = Inquiry.new
  end

  def edit
  end

  def create
    @inquiry = Inquiry.new(inquiry_params)

    respond_to do |format|
      if @inquiry.save
        format.html { redirect_to @inquiry, notice: "問い合わせを登録しました。" }
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @inquiry.update(inquiry_params)
        format.html { redirect_to @inquiry, notice: "問い合わせを更新しました。", status: :see_other }
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @inquiry.destroy!

    respond_to do |format|
      format.html { redirect_to inquiries_path, notice: "問い合わせを削除しました。", status: :see_other }
    end
  end

  private

  def set_inquiry
    @inquiry = Inquiry.find(params.expect(:id))
  end

  def inquiry_params
    params.expect(inquiry: [ :room_id, :tenant_id, :assigned_user_id, :construction_id,
      :category, :priority, :status, :title, :description, :response,
      :received_on, :resolved_on, :notes ])
  end

  def search_params
    params.fetch(:q, {}).permit(:building_name, :tenant_name, :category, :priority, :status)
  end

  def send_csv(inquiries)
    csv_data = "\xEF\xBB\xBF" + CSV.generate do |csv|
      csv << %w[建物名 部屋番号 入居者名 カテゴリ 優先度 状態 件名 受付日 解決日]
      inquiries.each do |i|
        csv << [
          i.room&.building&.name, i.room&.room_number, i.tenant&.name,
          i.category_label, i.priority_label, i.status_label,
          i.title, i.received_on, i.resolved_on
        ]
      end
    end
    send_data csv_data, filename: "inquiries_#{Date.current.strftime('%Y%m%d')}.csv", type: :csv
  end
end
