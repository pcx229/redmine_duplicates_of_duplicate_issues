# all duplicates column

module IssuePatch

	def self.included(base)
	  base.send(:include, InstanceMethods)
  
	  base.class_eval do
		unloadable

		belongs_to :duplicate, :foreign_key => "id", :primary_key => "issue_id"

		after_destroy_commit(:update_duplicates_on_destroy_duplicate_relation)
	  end
	end
  
	module InstanceMethods
		def direct_indirect_duplicates
			@direct_indirect_duplicates ||= Duplicate.duplicates(self.id).joins(:issue).order("#{Issue.table_name}.created_on ASC")
		end

		def update_duplicates_on_destroy_duplicate_relation
			Rails.logger.debug "Issue #{id} is destroyed, update duplicates table groups..."
			Duplicate.rebuild_duplicates_groups([id])
		end
	end
end

unless Issue.included_modules.include?(IssuePatch)
    Issue.send(:include, IssuePatch)
end
