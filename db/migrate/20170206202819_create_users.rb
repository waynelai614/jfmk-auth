class CreateUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :users do |t|
      t.string :username, limit: 32
      t.string :password_digest
      t.integer :login_attempts, default: 0
      t.boolean :login_locked
      t.boolean :admin
      t.string :first_name, limit: 32
      t.string :last_name, limit: 32

      t.timestamps
    end
    add_index :users, :username, unique: true
  end
end
