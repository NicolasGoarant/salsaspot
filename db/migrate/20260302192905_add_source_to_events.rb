class AddSourceToEvents < ActiveRecord::Migration[7.2]
  def change
    add_column :events, :source, :string
  end
end
