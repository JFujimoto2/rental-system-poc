require 'rails_helper'

RSpec.describe BulkClearingMatcher do
  let!(:building) { create(:building) }
  let!(:room) { create(:room, building: building) }
  let!(:tenant) { create(:tenant, name: '山田 太郎') }
  let!(:contract) { create(:contract, room: room, tenant: tenant, rent: 100_000) }
  let!(:unpaid) do
    create(:tenant_payment, contract: contract, due_date: '2024-06-01',
           amount: 100_000, status: :unpaid)
  end

  describe '#match' do
    it '名前と金額が一致する場合にマッチする' do
      rows = [ { date: '2024-06-01', name: '山田 太郎', amount: '100000' } ]
      result = described_class.new(rows).match

      expect(result.matched.size).to eq 1
      expect(result.matched.first.tenant_payment).to eq unpaid
      expect(result.matched.first.match_type).to eq :exact
      expect(result.unmatched).to be_empty
    end

    it '名前の空白を無視してマッチする' do
      rows = [ { date: '2024-06-01', name: '山田太郎', amount: '100000' } ]
      result = described_class.new(rows).match

      expect(result.matched.size).to eq 1
    end

    it '金額が一致しない場合はマッチしない' do
      rows = [ { date: '2024-06-01', name: '山田 太郎', amount: '50000' } ]
      result = described_class.new(rows).match

      expect(result.matched).to be_empty
      expect(result.unmatched.size).to eq 1
      expect(result.unmatched.first.candidates.size).to eq 1
    end

    it '名前が一致しない場合はマッチしない' do
      rows = [ { date: '2024-06-01', name: '佐藤 花子', amount: '100000' } ]
      result = described_class.new(rows).match

      expect(result.matched).to be_empty
      expect(result.unmatched.size).to eq 1
      expect(result.unmatched.first.candidates).to be_empty
    end

    it '入金済の支払にはマッチしない' do
      unpaid.update!(status: :paid, paid_amount: 100_000, paid_date: '2024-06-01')
      rows = [ { date: '2024-06-01', name: '山田 太郎', amount: '100000' } ]
      result = described_class.new(rows).match

      expect(result.matched).to be_empty
    end
  end
end
