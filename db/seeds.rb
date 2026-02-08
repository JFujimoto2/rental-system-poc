# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# 開発用ユーザー（各ロール1名ずつ）
if Rails.env.local?
  [
    { provider: "dev", uid: "dev-admin",    name: "管理者",         email: "admin@example.com",    role: :admin },
    { provider: "dev", uid: "dev-manager",  name: "マネージャー",   email: "manager@example.com",  role: :manager },
    { provider: "dev", uid: "dev-operator", name: "オペレーター",   email: "operator@example.com", role: :operator },
    { provider: "dev", uid: "dev-viewer",   name: "閲覧者",         email: "viewer@example.com",   role: :viewer }
  ].each do |attrs|
    User.find_or_create_by!(provider: attrs[:provider], uid: attrs[:uid]) do |user|
      user.name  = attrs[:name]
      user.email = attrs[:email]
      user.role  = attrs[:role]
    end
  end
  puts "開発用ユーザーを作成しました（4名）"
end
