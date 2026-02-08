class ReportsController < ApplicationController
  def property_pl
    @from = params[:from].present? ? Date.parse(params[:from]) : Date.current.beginning_of_month
    @to = params[:to].present? ? Date.parse(params[:to]) : Date.current.end_of_month

    @buildings = Building.includes(:owner, :rooms).order(:name)
    @report = @buildings.map { |b| build_property_pl(b) }

    respond_to do |format|
      format.html
      format.csv { send_property_pl_csv }
    end
  end

  def aging
    @delinquencies = TenantPayment
                       .where(status: [ :overdue, :partial ])
                       .or(TenantPayment.where(status: :unpaid).where("due_date < ?", Date.current))
                       .includes(contract: [ :tenant, { room: :building } ])

    @aging_buckets = classify_aging(@delinquencies)

    respond_to do |format|
      format.html
      format.csv { send_aging_csv }
    end
  end

  def payment_summary
    @months = build_monthly_range
    @monthly_data = @months.map { |month| build_payment_month(month) }

    respond_to do |format|
      format.html
      format.csv { send_payment_summary_csv }
    end
  end

  private

  # === Property P&L ===

  def build_property_pl(building)
    room_ids = building.rooms.pluck(:id)
    contract_ids = Contract.where(room_id: room_ids).pluck(:id)
    ml_ids = MasterLease.where(building_id: building.id).pluck(:id)

    income = TenantPayment.where(contract_id: contract_ids, status: :paid)
                          .where(due_date: @from..@to).sum(:paid_amount)
    expense = OwnerPayment.where(master_lease_id: ml_ids, status: :paid)
                          .where(target_month: @from..@to).sum(:net_amount)

    total_rooms = building.rooms.size
    occupied = building.rooms.count { |r| r.occupied? }
    occupancy = total_rooms.positive? ? (occupied.to_f / total_rooms * 100).round(1) : 0

    {
      building: building,
      income: income,
      expense: expense,
      profit: income - expense,
      total_rooms: total_rooms,
      occupied: occupied,
      occupancy: occupancy
    }
  end

  def send_property_pl_csv
    csv_data = "\xEF\xBB\xBF" + CSV.generate do |csv|
      csv << %w[建物名 オーナー 転貸収入 保証賃料支出 収支差額 総部屋数 入居数 入居率]
      @report.each do |r|
        csv << [
          r[:building].name, r[:building].owner&.name,
          r[:income], r[:expense], r[:profit],
          r[:total_rooms], r[:occupied], "#{r[:occupancy]}%"
        ]
      end
    end
    send_data csv_data, filename: "property_pl_#{Date.current.strftime('%Y%m%d')}.csv", type: :csv
  end

  # === Aging ===

  def classify_aging(delinquencies)
    today = Date.current
    buckets = { "〜30日" => [], "31〜60日" => [], "61〜90日" => [], "90日超" => [] }

    delinquencies.each do |tp|
      days = (today - tp.due_date).to_i
      key = if days <= 30
              "〜30日"
      elsif days <= 60
              "31〜60日"
      elsif days <= 90
              "61〜90日"
      else
              "90日超"
      end
      buckets[key] << tp
    end
    buckets
  end

  def send_aging_csv
    csv_data = "\xEF\xBB\xBF" + CSV.generate do |csv|
      csv << %w[エイジング 入居者 建物 部屋 入金期日 滞納日数 請求金額 入金額 未収額]
      @aging_buckets.each do |label, payments|
        payments.each do |tp|
          days = (Date.current - tp.due_date).to_i
          csv << [
            label, tp.contract.tenant.name,
            tp.contract.room.building.name, tp.contract.room.room_number,
            tp.due_date, days, tp.amount, tp.paid_amount,
            tp.amount - (tp.paid_amount || 0)
          ]
        end
      end
    end
    send_data csv_data, filename: "aging_#{Date.current.strftime('%Y%m%d')}.csv", type: :csv
  end

  # === Payment Summary ===

  def build_monthly_range
    start_month = (params[:from].present? ? Date.parse(params[:from]) : 6.months.ago).beginning_of_month
    end_month = (params[:to].present? ? Date.parse(params[:to]) : Date.current).beginning_of_month

    months = []
    current = start_month
    while current <= end_month
      months << current
      current = current.next_month
    end
    months
  end

  def build_payment_month(month)
    range = month..month.end_of_month
    payments = TenantPayment.where(due_date: range)

    total = payments.count
    paid_count = payments.where(status: :paid).count
    paid_amount = payments.where(status: :paid).sum(:paid_amount)
    expected = payments.sum(:amount)
    rate = total.positive? ? (paid_count.to_f / total * 100).round(1) : 0

    by_method = {}
    TenantPayment.payment_methods.each_key do |method|
      by_method[method] = payments.where(status: :paid, payment_method: method).sum(:paid_amount)
    end

    {
      month: month,
      total: total,
      paid_count: paid_count,
      expected: expected,
      paid_amount: paid_amount,
      rate: rate,
      by_method: by_method
    }
  end

  def send_payment_summary_csv
    csv_data = "\xEF\xBB\xBF" + CSV.generate do |csv|
      csv << %w[対象月 予定件数 入金件数 予定金額 入金額 入金率 振込 口座振替 現金]
      @monthly_data.each do |d|
        csv << [
          d[:month].strftime("%Y-%m"), d[:total], d[:paid_count],
          d[:expected], d[:paid_amount], "#{d[:rate]}%",
          d[:by_method]["transfer"], d[:by_method]["direct_debit"], d[:by_method]["cash"]
        ]
      end
    end
    send_data csv_data, filename: "payment_summary_#{Date.current.strftime('%Y%m%d')}.csv", type: :csv
  end
end
