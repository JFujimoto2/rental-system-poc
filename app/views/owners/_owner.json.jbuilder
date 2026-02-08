json.extract! owner, :id, :name, :name_kana, :phone, :email, :postal_code, :address, :bank_name, :bank_branch, :account_type, :account_number, :account_holder, :notes, :created_at, :updated_at
json.url owner_url(owner, format: :json)
