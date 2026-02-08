class KeysController < ApplicationController
  before_action :set_key, only: %i[ show edit update destroy ]

  def index
    @search_params = search_params
    @keys = Key.includes(room: :building).search(@search_params)
    respond_to do |format|
      format.html
      format.csv { send_csv(@keys) }
    end
  end

  def show
  end

  def new
    @key = Key.new(room_id: params[:room_id])
  end

  def edit
  end

  def create
    @key = Key.new(key_params)

    respond_to do |format|
      if @key.save
        format.html { redirect_to @key, notice: "鍵を登録しました。" }
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @key.update(key_params)
        format.html { redirect_to @key, notice: "鍵を更新しました。", status: :see_other }
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @key.destroy!

    respond_to do |format|
      format.html { redirect_to keys_path, notice: "鍵を削除しました。", status: :see_other }
    end
  end

  private

  def set_key
    @key = Key.find(params.expect(:id))
  end

  def key_params
    params.expect(key: [ :room_id, :key_type, :key_number, :status, :notes ])
  end

  def search_params
    params.fetch(:q, {}).permit(:building_name, :room_number, :key_type, :status)
  end

  def send_csv(keys)
    csv_data = "\xEF\xBB\xBF" + CSV.generate do |csv|
      csv << %w[建物名 部屋番号 鍵種別 鍵番号 状態]
      keys.each do |k|
        csv << [
          k.room.building.name, k.room.room_number,
          k.key_type_label, k.key_number, k.status_label
        ]
      end
    end
    send_data csv_data, filename: "keys_#{Date.current.strftime('%Y%m%d')}.csv", type: :csv
  end
end
