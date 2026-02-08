class BulkClearingMatcher
  Result = Struct.new(:matched, :unmatched, keyword_init: true)
  MatchedRow = Struct.new(:csv_row, :tenant_payment, :match_type, keyword_init: true)
  UnmatchedRow = Struct.new(:csv_row, :candidates, keyword_init: true)

  def initialize(csv_rows)
    @csv_rows = csv_rows
  end

  def match
    unpaid_payments = TenantPayment
                        .where(status: [ :unpaid, :overdue ])
                        .includes(contract: :tenant)
                        .to_a

    matched = []
    unmatched = []

    @csv_rows.each do |row|
      payment = find_match(row, unpaid_payments)
      if payment
        unpaid_payments.delete(payment)
        matched << MatchedRow.new(csv_row: row, tenant_payment: payment, match_type: match_type(row, payment))
      else
        candidates = find_candidates(row, unpaid_payments)
        unmatched << UnmatchedRow.new(csv_row: row, candidates: candidates)
      end
    end

    Result.new(matched: matched, unmatched: unmatched)
  end

  private

  def find_match(row, payments)
    amount = row[:amount].to_i
    name = normalize_name(row[:name])

    payments.find do |tp|
      tp.amount == amount && normalize_name(tp.contract.tenant.name) == name
    end
  end

  def find_candidates(row, payments)
    name = normalize_name(row[:name])
    payments.select do |tp|
      normalize_name(tp.contract.tenant.name) == name
    end.first(3)
  end

  def match_type(row, payment)
    row[:amount].to_i == payment.amount ? :exact : :partial
  end

  def normalize_name(name)
    name.to_s.gsub(/[\s　]/, "")
  end
end
