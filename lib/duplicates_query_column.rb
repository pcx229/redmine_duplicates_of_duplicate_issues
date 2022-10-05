# duplicates column

class DuplicatesQueryColumn < QueryColumn
	include ActionView::Helpers::TagHelper
	include ActionView::Helpers::UrlHelper

	def initialize
		super(:duplicates, :groupable => true)
	end

	class DuplicatesGroup
		attr_reader :id

		def initialize(id)
			@id = id
		end

		def ==(other)
			if other.nil?
				return false
			end
			((self.class == other.class && self.id == other.id) || (other.class == Integer && self.id == other))
		end
	
		alias eql? ==

		def hash
			self.id.hash
		end

		def to_s
			""
		end
	end

	def group_value(issue)
	    groups = Duplicate.where(issue_id: issue.id)
	    group = nil
	    if groups.present?
			group = DuplicatesGroup.new(groups.first.group_id)
	    end
	    group
	end

	def value_object(issue)
		issue.direct_indirect_duplicates.map { |dup|
				content_tag('span', 
					("#{dup.is_direct(issue.id) ? l(:duplicates_text_direct) : l(:duplicates_text_indirect)} " + 
					link_to("##{dup.issue_id}", "/issues/#{dup.issue_id}") + 
					"  (#{format_date(dup.issue.created_on)})" + 
					" #{dup.is_root ? "(#{l(:duplicates_text_root)})" : ""}").html_safe,
				:class => "rel-duplicates")
			}
	end

	def sortable
		"duplicates"
	end

	def group_by_statement
		"duplicates"
	end
end
IssueQuery.available_columns << DuplicatesQueryColumn.new