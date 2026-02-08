require 'rails_helper'

RSpec.describe RentRevision do
  describe 'associations' do
    it { is_expected.to belong_to(:master_lease) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:revision_date) }
    it { is_expected.to validate_presence_of(:old_rent) }
    it { is_expected.to validate_presence_of(:new_rent) }
  end
end
