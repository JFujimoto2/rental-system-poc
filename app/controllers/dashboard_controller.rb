class DashboardController < ApplicationController
  def index
    @total_rooms = Room.count
    @occupied_rooms = Room.occupied.count
    @vacant_rooms = Room.vacant.count
    @notice_rooms = Room.notice.count
    @occupancy_rate = @total_rooms.positive? ? (@occupied_rooms.to_f / @total_rooms * 100).round(1) : 0

    @overdue_payments = TenantPayment.where(status: :overdue)
    @overdue_count = @overdue_payments.count
    @overdue_amount = @overdue_payments.sum(:amount)

    today = Date.current
    @unpaid_due_count = TenantPayment.where(status: :unpaid).where("due_date <= ?", today).count

    @owner_payment_unpaid_count = OwnerPayment.where(status: :unpaid).count

    @renewal_contracts = Contract.where(status: :active)
                                 .where(end_date: today..3.months.from_now)
                                 .includes(room: :building, tenant: [])
                                 .order(:end_date)

    @terminating_contracts = Contract.where(status: :scheduled_termination)
                                     .includes(room: :building, tenant: [])
                                     .order(:end_date)
  end
end
