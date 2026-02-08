class DelinquenciesController < ApplicationController
  def index
    @search_params = search_params
    @delinquencies = delinquent_payments(@search_params)

    respond_to do |format|
      format.html
      format.csv { send_csv(@delinquencies) }
    end
  end

  private

  def search_params
    params.fetch(:q, {}).permit(:tenant_name, :building_name, :aging)
  end

  def delinquent_payments(search)
    scope = TenantPayment
              .where(status: [ :overdue, :partial ])
              .or(TenantPayment.where(status: :unpaid).where("due_date < ?", Date.current))
              .includes(contract: [ :tenant, { room: :building } ])
              .order(:due_date)

    if search[:tenant_name].present?
      scope = scope.joins(contract: :tenant)
                   .where("tenants.name ILIKE ?", "%#{search[:tenant_name]}%")
    end

    if search[:building_name].present?
      scope = scope.joins(contract: { room: :building })
                   .where("buildings.name ILIKE ?", "%#{search[:building_name]}%")
    end

    if search[:aging].present?
      today = Date.current
      scope = case search[:aging]
      when "30"       then scope.where(due_date: (today - 30.days)..today)
      when "60"       then scope.where(due_date: (today - 60.days)..(today - 31.days))
      when "90"       then scope.where(due_date: (today - 90.days)..(today - 61.days))
      when "90over"   then scope.where("due_date < ?", today - 90.days)
      else scope
      end
    end

    scope
  end

  def send_csv(delinquencies)
    csv_data = "\xEF\xBB\xBF" + CSV.generate do |csv|
      csv << %w[入居者 建物 部屋 入金期日 滞納日数 請求金額 入金額 未収額 状態]
      delinquencies.each do |tp|
        days = (Date.current - tp.due_date).to_i
        unpaid = tp.amount - (tp.paid_amount || 0)
        csv << [
          tp.contract.tenant.name,
          tp.contract.room.building.name,
          tp.contract.room.room_number,
          tp.due_date,
          days,
          tp.amount,
          tp.paid_amount,
          unpaid,
          tp.status_label
        ]
      end
    end
    send_data csv_data, filename: "delinquencies_#{Date.current.strftime('%Y%m%d')}.csv", type: :csv
  end
end
