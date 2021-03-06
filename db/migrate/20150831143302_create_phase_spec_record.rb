class CreatePhaseSpecRecord < ActiveRecord::Migration
  def change
    create_table :phase_spec_records do |t|
      t.references :project_record, null: false
      t.integer :order, null: false
      t.string :phase_name, null: false
      t.integer :wip_limit_count
    end

    add_index :phase_spec_records, [:project_record_id, :order]
  end
end
