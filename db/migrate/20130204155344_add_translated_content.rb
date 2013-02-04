class AddTranslatedContent < ActiveRecord::Migration
  def change
    create_table :translated_attributes do |t|
      t.references :owner, :polymorphic => true
      t.string :attribute_name
      t.string :locale
      t.text :translation
    end
  end
end
