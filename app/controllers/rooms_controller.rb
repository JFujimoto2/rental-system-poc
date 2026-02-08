class RoomsController < ApplicationController
  before_action :set_room, only: %i[ show edit update destroy ]

  def index
    @search_params = search_params
    @rooms = Room.includes(:building).search(@search_params)
    respond_to do |format|
      format.html
      format.csv { send_csv(@rooms) }
    end
  end

  # GET /rooms/1 or /rooms/1.json
  def show
  end

  # GET /rooms/new
  def new
    @room = Room.new(building_id: params[:building_id])
  end

  # GET /rooms/1/edit
  def edit
  end

  # POST /rooms or /rooms.json
  def create
    @room = Room.new(room_params)

    respond_to do |format|
      if @room.save
        format.html { redirect_to @room, notice: "部屋を登録しました。" }
        format.json { render :show, status: :created, location: @room }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @room.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /rooms/1 or /rooms/1.json
  def update
    respond_to do |format|
      if @room.update(room_params)
        format.html { redirect_to @room, notice: "部屋を更新しました。", status: :see_other }
        format.json { render :show, status: :ok, location: @room }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @room.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /rooms/1 or /rooms/1.json
  def destroy
    @room.destroy!

    respond_to do |format|
      format.html { redirect_to rooms_path, notice: "部屋を削除しました。", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_room
      @room = Room.find(params.expect(:id))
    end

    def search_params
      params.fetch(:q, {}).permit(:building_id, :room_number, :status, :room_type)
    end

    def send_csv(rooms)
      csv_data = "\xEF\xBB\xBF" + CSV.generate do |csv|
        csv << %w[建物 部屋番号 階数 間取り 面積 賃料 状態]
        rooms.each do |r|
          csv << [ r.building.name, r.room_number, r.floor, r.room_type, r.area, r.rent, r.status_label ]
        end
      end
      send_data csv_data, filename: "rooms_#{Date.current.strftime('%Y%m%d')}.csv", type: :csv
    end

    def room_params
      params.expect(room: [ :building_id, :room_number, :floor, :area, :rent, :status, :room_type, :notes ])
    end
end
