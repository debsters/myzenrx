class CreateMedications < ActiveRecord::Migration
  def change
    create_table :medications do |t|
      t.string  :source
      t.string  :name
      t.string  :description
      t.string  :side_effects
      t.string  :url
      t.string  :side_effects_url
      t.integer :index_id
    end
  end
end
