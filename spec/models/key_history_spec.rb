require 'rails_helper'

RSpec.describe KeyHistory do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:action) }
    it { is_expected.to validate_presence_of(:acted_on) }
  end

  describe 'associations' do
    it { is_expected.to belong_to(:key) }
    it { is_expected.to belong_to(:tenant).optional }
  end

  describe 'enums' do
    it { is_expected.to define_enum_for(:action).with_values(issued: 0, returned: 1, lost_reported: 2, replaced: 3) }
  end

  describe 'label methods' do
    let(:history) { build(:key_history, action: :issued) }

    it 'action_label を返す' do
      expect(history.action_label).to eq "貸出"
    end
  end
end
