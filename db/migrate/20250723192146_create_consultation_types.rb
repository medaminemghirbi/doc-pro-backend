class CreateConsultationTypes < ActiveRecord::Migration[7.0]
  def change
    create_table :consultation_types, id: :uuid do |t|
      t.string :name, null: false                
      t.text :color, null: false
      t.text :description, null: false  
      t.timestamps
    end
  end
end
