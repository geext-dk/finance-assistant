class InitialStructure < ActiveRecord::Migration[7.1]
  def change
    create_table :users, id: :uuid do |t|
      t.string :email, null: false, index: { unique: true, name: "unique_emails" }
      t.string :password_digest, null: false

      t.timestamps
    end

    create_table :accounts, id: :uuid do |t|
      t.string :name, null: false
      t.string :currency, null: false
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.timestamp :archived_at

      t.timestamps
    end

    create_table :merchants, id: :uuid do |t|
      t.string :name, null: false
      t.string :country, null: false
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.timestamp :archived_at

      t.timestamps
    end

    create_table :products, id: :uuid do |t|
      t.string :country, null: false
      t.string :name, null: false
      t.integer :quantity_type, null: false
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.timestamp :archived_at

      t.timestamps
    end
    
    create_table :transactions, id: :uuid do |t|
      t.string :country, null: false
      t.string :currency, null: false
      t.references :merchant, null: false, foreign_key: true, type: :uuid
      t.references :account, null: false, foreign_key: true, type: :uuid
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.timestamp :date, null: false

      t.timestamps
    end

    create_table :transaction_line_items, primary_key: [:owner_transaction_id, :product_id] do |t|
      t.references :product, null: false, foreign_key: true, type: :uuid
      t.references :owner_transaction, null: false, foreign_key: {to_table: :transactions}, type: :uuid
      t.integer :quantity_pieces
      t.float :quantity_weighted
      t.integer :price_cents, null: false
      t.integer :discounted_price_cents
      t.integer :total_price_cents, null: false

      t.timestamps
    end
  end
end
