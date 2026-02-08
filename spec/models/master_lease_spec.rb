require 'rails_helper'

RSpec.describe MasterLease do
  describe 'associations' do
    it { is_expected.to belong_to(:owner) }
    it { is_expected.to belong_to(:building) }
    it { is_expected.to have_many(:exemption_periods).dependent(:destroy) }
    it { is_expected.to have_many(:rent_revisions).dependent(:destroy) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:contract_type) }
    it { is_expected.to validate_presence_of(:start_date) }
    it { is_expected.to validate_presence_of(:status) }
  end

  describe 'enums' do
    it {
      is_expected.to define_enum_for(:contract_type)
        .with_values(sublease: 0, management: 1, own: 2)
    }

    it {
      is_expected.to define_enum_for(:status)
        .with_values(active: 0, scheduled_termination: 1, terminated: 2)
    }
  end

  describe '#contract_type_label' do
    it 'サブリースの日本語ラベルを返す' do
      master_lease = build(:master_lease, contract_type: :sublease)
      expect(master_lease.contract_type_label).to eq 'サブリース'
    end

    it '管理委託の日本語ラベルを返す' do
      master_lease = build(:master_lease, contract_type: :management)
      expect(master_lease.contract_type_label).to eq '管理委託'
    end
  end

  describe '#status_label' do
    it '契約中の日本語ラベルを返す' do
      master_lease = build(:master_lease, status: :active)
      expect(master_lease.status_label).to eq '契約中'
    end
  end
end
