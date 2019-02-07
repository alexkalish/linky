class CreateLinks < ActiveRecord::Migration[5.2]
  def change
    create_table :links do |t|
      t.references(:user)
      t.string(:destination_url, null: false)
      t.string(:public_identifier, null: false)
      t.column :created_at, 'timestamp with time zone', null: false
      t.column :updated_at, 'timestamp with time zone', null: false
    end
    add_index :links, [:user_id, :destination_url], unique: true
    add_index :links, :public_identifier, unique: true
  end
end
