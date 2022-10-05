# listen to changes to relations table and update duplicates table accordingly

module IssueRelationPatch
	
	def self.included(base)
		base.send(:include, InstanceMethods)

		base.class_eval do
			unloadable

			after_create_commit(:update_duplicates_on_create_duplicate_relation)
			after_update_commit(:update_duplicates_on_update_duplicate_relation)
			after_destroy_commit(:update_duplicates_on_destroy_duplicate_relation)
		end
	end

	module InstanceMethods
		def update_duplicates_on_create_duplicate_relation
			if relation_type != "duplicates"
				return
			end
			Rails.logger.debug "IssueRelation created duplicate relation between #{issue_from_id} and #{issue_to_id}, update duplicates table groups..."
			Duplicate.rebuild_duplicates_groups([issue_from_id, issue_to_id])
		end
	
		def update_duplicates_on_update_duplicate_relation
			if ((previous_changes.key?("relation_type") and previous_changes["relation_type"] != "duplicates" and relation_type != "duplicates") or 
				(not previous_changes.key?("relation_type") and relation_type != "duplicates"))
				return
			end
			affected_issues = [issue_from_id, issue_to_id]
			affected_issues << previous_changes["issue_from_id"] if previous_changes.key?("issue_from_id")
			affected_issues << previous_changes["issue_to_id"] if previous_changes.key?("issue_to_id")
			Rails.logger.debug "IssueRelation updated duplicate relation, now #{issue_from_id} to #{issue_to_id}, affected issues are #{affected_issues}, update duplicates table groups..."
			Duplicate.rebuild_duplicates_groups(affected_issues_groups)
		end
		
		def update_duplicates_on_destroy_duplicate_relation
			if relation_type != "duplicates"
				return
			end
			Rails.logger.debug "IssueRelation destroyed duplicate relation between #{issue_from_id} and #{issue_to_id}, update duplicates table groups..."
			Duplicate.rebuild_duplicates_groups([issue_from_id, issue_to_id])
		end
	end
end
IssueRelation.send(:include, IssueRelationPatch)