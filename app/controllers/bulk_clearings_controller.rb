class BulkClearingsController < ApplicationController
  def new
  end

  def preview
    unless params.dig(:bulk_clearing, :file)
      redirect_to new_bulk_clearing_path, alert: "ファイルを選択してください。"
      return
    end

    csv_rows = parse_csv(params[:bulk_clearing][:file])
    matcher = BulkClearingMatcher.new(csv_rows)
    @result = matcher.match
  end

  def create
    clearings = params[:clearings] || {}
    cleared_count = 0

    clearings.each do |payment_id, attrs|
      next unless attrs[:match] == "1"

      payment = TenantPayment.find_by(id: payment_id)
      next unless payment

      paid_amount = attrs[:paid_amount].to_i
      payment.update!(
        paid_amount: paid_amount,
        paid_date: attrs[:paid_date],
        status: paid_amount >= payment.amount ? :paid : :partial,
        payment_method: :transfer
      )
      cleared_count += 1
    end

    redirect_to tenant_payments_path, notice: "#{cleared_count}件の入金を消込しました。"
  end

  private

  def parse_csv(file)
    rows = []
    content = file.read.force_encoding("UTF-8")
    content = content.sub("\xEF\xBB\xBF", "") # Remove BOM

    CSV.parse(content, headers: true).each do |row|
      rows << {
        date: row[0]&.strip,
        name: row[1]&.strip,
        amount: row[2]&.strip
      }
    end
    rows
  end
end
