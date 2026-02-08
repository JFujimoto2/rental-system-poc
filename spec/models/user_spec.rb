require 'rails_helper'

RSpec.describe User do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:provider) }
    it { is_expected.to validate_presence_of(:uid) }
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_presence_of(:role) }
  end

  describe 'enums' do
    it {
      is_expected.to define_enum_for(:role)
        .with_values(admin: 0, manager: 1, operator: 2, viewer: 3)
    }
  end

  describe '.find_or_create_from_omniauth' do
    let(:auth_hash) do
      OmniAuth::AuthHash.new(
        provider: 'entra_id',
        uid: 'test-uid-123',
        info: {
          name: 'テスト太郎',
          email: 'taro@example.com'
        }
      )
    end

    it '新規ユーザーを作成する' do
      expect { User.find_or_create_from_omniauth(auth_hash) }.to change(User, :count).by(1)
      user = User.last
      expect(user.provider).to eq 'entra_id'
      expect(user.uid).to eq 'test-uid-123'
      expect(user.name).to eq 'テスト太郎'
      expect(user.email).to eq 'taro@example.com'
      expect(user).to be_viewer
    end

    it '既存ユーザーを返す' do
      create(:user, provider: 'entra_id', uid: 'test-uid-123')
      expect { User.find_or_create_from_omniauth(auth_hash) }.not_to change(User, :count)
    end

    it '既存ユーザーの名前・メールを更新する' do
      user = create(:user, provider: 'entra_id', uid: 'test-uid-123', name: '旧名前', email: 'old@example.com')
      User.find_or_create_from_omniauth(auth_hash)
      user.reload
      expect(user.name).to eq 'テスト太郎'
      expect(user.email).to eq 'taro@example.com'
    end
  end

  describe '#role_label' do
    it '管理者ラベルを返す' do
      expect(build(:user, :admin).role_label).to eq '管理者'
    end

    it 'マネージャーラベルを返す' do
      expect(build(:user, :manager).role_label).to eq 'マネージャー'
    end

    it 'オペレーターラベルを返す' do
      expect(build(:user, :operator).role_label).to eq 'オペレーター'
    end

    it '閲覧者ラベルを返す' do
      expect(build(:user, :viewer).role_label).to eq '閲覧者'
    end
  end

  describe 'permission methods' do
    it 'admin は全操作可能' do
      user = build(:user, :admin)
      expect(user.can_manage_master?).to be true
      expect(user.can_operate_payments?).to be true
      expect(user.can_manage_users?).to be true
    end

    it 'manager はマスタ管理・入出金操作可能' do
      user = build(:user, :manager)
      expect(user.can_manage_master?).to be true
      expect(user.can_operate_payments?).to be true
      expect(user.can_manage_users?).to be false
    end

    it 'operator は入出金操作のみ' do
      user = build(:user, :operator)
      expect(user.can_manage_master?).to be false
      expect(user.can_operate_payments?).to be true
      expect(user.can_manage_users?).to be false
    end

    it 'viewer は閲覧のみ' do
      user = build(:user, :viewer)
      expect(user.can_manage_master?).to be false
      expect(user.can_operate_payments?).to be false
      expect(user.can_manage_users?).to be false
    end
  end
end
