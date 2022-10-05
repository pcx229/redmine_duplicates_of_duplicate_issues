require_relative '../../lib/union_find'

class Duplicate < ActiveRecord::Base
	belongs_to :issue, :class_name => 'Issue'

	def self.rebuild_duplicates_groups_from_relations(relations)
		uf = UnionFind.new
		relations.each {|rel| uf.union(rel.issue_from_id, rel.issue_to_id)}
		return uf.groups
	end

	def self.next_duplicates_group_id
		max = Duplicate.maximum(:group_id)
		max != nil ? max + 1 : 0
	end

	def self.create_duplicates_group(issue_ids)
		duplicates = []
		group_id = next_duplicates_group_id()
		Rails.logger.debug "Creating duplicate group of issues #{issue_ids} with id #{group_id}"
		Duplicate.create(issue_ids.map {|member| {issue_id: member, group_id: group_id}})
	end

	def self.delete_duplicates_group(group_ids)
		groups = Duplicate.where(group_id: group_ids.to_a).all
		if groups.empty?
			Rails.logger.debug "No duplicate groups #{group_ids} where found to delete"
			return
		end
		Rails.logger.debug "Deleting duplicate groups #{group_ids}"
		groups.delete_all
	end

	def self.delete_all_duplicates_groups
		Duplicate.delete_all
	end

	def self.build_from_relations
		rebuild_duplicates_groups()
	end

	def self.duplicates_groups_of_issues(issue_ids)
		(Duplicate.where(issue_id: issue_ids).map {|dup| dup.group_id}).uniq
	end

	def self.rebuild_duplicates_groups(issue_ids=nil)
		relations = IssueRelation.where(relation_type: 'duplicates')
		if issue_ids == nil
			Rails.logger.debug "Rebuiding all duplicates groups"
			delete_all_duplicates_groups()
		else
			groups = duplicates_groups_of_issues(issue_ids)
			groups_issues_ids = Duplicate.where(group_id: groups.to_a).map {|dup| dup.issue_id}
			affected_issues_ids = groups_issues_ids + issue_ids
			Rails.logger.debug "Rebuiding duplicates groups for group #{groups} issues #{groups_issues_ids} and other issues #{issue_ids}"
			delete_duplicates_group(groups)
			relations = relations.where("issue_from_id IN (?) OR issue_to_id IN (?)", affected_issues_ids, affected_issues_ids)
		end
		rebuild_duplicates_groups_from_relations(relations).each {|group| create_duplicates_group(group)}
	end

	def self.duplicates(issue_id)
		Duplicate.where("group_id == (SELECT group_id FROM #{Duplicate.table_name} WHERE issue_id == #{issue_id} LIMIT 1) AND issue_id != #{issue_id}")
	end

	def is_root
		issue.relations.select {
			|r| r.relation_type == IssueRelation::TYPE_DUPLICATES
		}.map {
			|r| r.issue_to_id == issue.id
		}.all?
	end

	def is_direct(other_issue_id)
		issue.relations.map {
			|r| r.relation_type == IssueRelation::TYPE_DUPLICATES and (r.issue_to_id == other_issue_id or r.issue_from_id == other_issue_id)
		}.any?
	end
end