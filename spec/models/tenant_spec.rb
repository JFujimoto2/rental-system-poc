require 'rails_helper'

RSpec.describe Tenant do
  describe 'associations' do
    it { is_expected.to have_many(:contracts) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
  end
end
