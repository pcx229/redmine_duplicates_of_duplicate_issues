# all duplicates filter
module IssueQueryPatch

	def self.included(base)
	  base.send(:include, InstanceMethods)
  
	  base.class_eval do
		unloadable

		alias_method :initialize_available_filters_without_duplicates_filters, :initialize_available_filters
		alias_method :initialize_available_filters, :initialize_available_filters_with_duplicates_filters

		alias_method :joins_for_order_statement_without_duplicates_group_scope, :joins_for_order_statement
		alias_method :joins_for_order_statement, :joins_for_order_statement_with_duplicates_group_scope
	  end
	end
  
	module InstanceMethods

		# for group column by duplicates
		def joins_for_order_statement_with_duplicates_group_scope(order_options)
			joins = [joins_for_order_statement_without_duplicates_group_scope(order_options)]
			
			if order_options
				if order_options.include?('duplicates')
				  joins << "LEFT OUTER JOIN (SELECT issue_id, group_id as duplicates from #{Duplicate.table_name}) duplicates ON duplicates.issue_id = #{Issue.table_name}.id"
				end
			end

			joins.any? ? joins.join(' ') : nil
		end

		def initialize_available_filters_with_duplicates_filters
			add_available_filter(
			  "has_direct_indirect_duplicates",
			  :type => :relation,
			  :values => lambda {all_projects_values}
			)
			return initialize_available_filters_without_duplicates_filters
		end
	end

	def sql_for_has_direct_indirect_duplicates_field(field, operator, value, options={})
		issue_has_duplicates = "#{Issue.table_name}.id IN (SELECT DISTINCT org.issue_id FROM #{Duplicate.table_name} org)"
		sql =
		  case operator
		  when "*", "!*"
			op = (operator == "*" ? 'IN' : 'NOT IN')
			"#{Issue.table_name}.id #{op}" \
			 " (SELECT DISTINCT org.issue_id FROM #{Duplicate.table_name} org)"
		  when "=", "!"
			op = (operator == "=" ? 'IN' : 'NOT IN')
			"#{issue_has_duplicates}" \
			 " AND #{Issue.table_name}.id #{op}" \
			  " (SELECT DISTINCT org.issue_id" \
			   " FROM #{Duplicate.table_name} org, #{Duplicate.table_name} dup" \
			   	" WHERE org.issue_id != dup.issue_id AND org.group_id == dup.group_id" \
				 " AND dup.issue_id = #{value.first.to_i})"
		  when "=p", "=!p", "!p"
			op = (operator == "!p" ? 'NOT IN' : 'IN')
			comp = (operator == "=!p" ? '<>' : '=')
			"#{issue_has_duplicates}" \
			 " AND #{Issue.table_name}.id #{op}" \
			  " (SELECT DISTINCT org.issue_id" \
			   " FROM #{Duplicate.table_name} org, #{Duplicate.table_name} dup, #{Issue.table_name} relissues" \
			    " WHERE org.issue_id != dup.issue_id AND org.group_id == dup.group_id" \
				 " AND dup.issue_id = relissues.id" \
				 " AND relissues.project_id #{comp} #{value.first.to_i})"
		  when "*o", "!o"
			op = (operator == "!o" ? 'NOT IN' : 'IN')
			"#{issue_has_duplicates}" \
			 " AND #{Issue.table_name}.id #{op}" \
			  " (SELECT DISTINCT org.issue_id" \
			   " FROM #{Duplicate.table_name} org, #{Duplicate.table_name} dup, #{Issue.table_name} relissues" \
			    " WHERE org.issue_id != dup.issue_id AND org.group_id == dup.group_id" \
				 " AND dup.issue_id = relissues.id" \
				 " AND relissues.status_id IN" \
				   " (SELECT id FROM #{IssueStatus.table_name}" \
				   "  WHERE is_closed = #{self.class.connection.quoted_false}))"
		  end
		"(#{sql})"
	end

end

IssueQuery.send(:include, IssueQueryPatch)