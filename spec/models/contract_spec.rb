require 'rails_helper'

RSpec.describe Contract do
  describe 'associations' do
    it { is_expected.to belong_to(:room) }
    it { is_expected.to belong_to(:tenant) }
    it { is_expected.to belong_to(:master_lease).optional }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:lease_type) }
    it { is_expected.to validate_presence_of(:start_date) }
    it { is_expected.to validate_presence_of(:status) }
  end

  describe 'enums' do
    it {
      is_expected.to define_enum_for(:lease_type)
        .with_values(ordinary: 0, fixed_term: 1)
    }

    it {
      is_expected.to define_enum_for(:status)
        .with_values(applying: 0, active: 1, scheduled_termination: 2, terminated: 3)
    }
  end

  describe '#lease_type_label' do
    it '普通借家の日本語ラベルを返す' do
      contract = build(:contract, lease_type: :ordinary)
      expect(contract.lease_type_label).to eq '普通借家'
    end

    it '定期借家の日本語ラベルを返す' do
      contract = build(:contract, lease_type: :fixed_term)
      expect(contract.lease_type_label).to eq '定期借家'
    end
  end

  describe '#status_label' do
    it '契約中の日本語ラベルを返す' do
      contract = build(:contract, status: :active)
      expect(contract.status_label).to eq '契約中'
    end

    it '申込の日本語ラベルを返す' do
      contract = build(:contract, status: :applying)
      expect(contract.status_label).to eq '申込'
    end
  end
end
