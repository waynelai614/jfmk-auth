class UpdateUserBooleanDefaults < ActiveRecord::Migration[5.0]
  def change
    change_column_default :users, :login_locked, from: nil, to: false
    change_column_default :users, :admin, from: nil, to: false
  end
end
