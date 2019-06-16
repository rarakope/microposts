class CreateRelationships < ActiveRecord::Migration[5.2]
  def change
    create_table :relationships do |t|
      t.references :user, foreign_key: true
      t.references :follow, foreign_key: { to_table: :users }
      #t.referencesは別のテーブルを参照させるという意味。今回、follow_idにはusersテーブルを参照させたい(to_table: usersにより)
      
      t.timestamps

      t.index [:user_id, :follow_id], unique: true 
      #user_id と follow_id のペアで重複するものが保存されないようにするデータベースの設定
    end
  end
end
