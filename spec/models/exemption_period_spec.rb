require 'rails_helper'

RSpec.describe ExemptionPeriod do
  describe 'associations' do
    it { is_expected.to belong_to(:master_lease) }
    it { is_expected.to belong_to(:room).optional }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:start_date) }
    it { is_expected.to validate_presence_of(:end_date) }
  end
end
