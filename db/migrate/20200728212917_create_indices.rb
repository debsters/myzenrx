class CreateIndices < ActiveRecord::Migration
  def change
    create_table :indices do |t|
      t.string :letter
    end
  end
end

