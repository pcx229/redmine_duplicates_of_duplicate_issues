class CreateDuplicate < ActiveRecord::Migration[5.2]
	def self.up
	  create_table :duplicates do |t|
		t.column :issue_id, :integer, :null => false
		t.column :group_id, :integer, :null => false
	  end

	  Duplicate.build_from_relations()
	end
  
	def self.down
	  drop_table :duplicates
	end
  end
  