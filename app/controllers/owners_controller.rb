class OwnersController < ApplicationController
  before_action :set_owner, only: %i[ show edit update destroy ]

  # GET /owners or /owners.json
  def index
    @owners = Owner.all
  end

  # GET /owners/1 or /owners/1.json
  def show
  end

  # GET /owners/new
  def new
    @owner = Owner.new
  end

  # GET /owners/1/edit
  def edit
  end

  # POST /owners or /owners.json
  def create
    @owner = Owner.new(owner_params)

    respond_to do |format|
      if @owner.save
        format.html { redirect_to @owner, notice: "オーナーを登録しました。" }
        format.json { render :show, status: :created, location: @owner }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @owner.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /owners/1 or /owners/1.json
  def update
    respond_to do |format|
      if @owner.update(owner_params)
        format.html { redirect_to @owner, notice: "オーナーを更新しました。", status: :see_other }
        format.json { render :show, status: :ok, location: @owner }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @owner.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /owners/1 or /owners/1.json
  def destroy
    @owner.destroy!

    respond_to do |format|
      format.html { redirect_to owners_path, notice: "オーナーを削除しました。", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_owner
      @owner = Owner.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def owner_params
      params.expect(owner: [ :name, :name_kana, :phone, :email, :postal_code, :address, :bank_name, :bank_branch, :account_type, :account_number, :account_holder, :notes ])
    end
end
