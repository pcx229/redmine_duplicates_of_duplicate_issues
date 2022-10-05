# list all duplicate issues in issue page

module IssuesHelperPatch

	def self.included(base)
	  base.send(:include, InstanceMethods)
  
	  base.class_eval do
		unloadable
	  end
	end
  
	module InstanceMethods
		def render_issue_duplicates(issue, duplicates)
			s = ''.html_safe
			duplicates.each do |dup|
				other_issue = dup.issue
				css = "issue hascontextmenu #{other_issue.css_classes}"
				s <<
					content_tag(
						'tr',
						content_tag('td',
									link_to_issue(
										other_issue,
										:project => Setting.cross_project_issue_relations?
									),
									:class => 'subject') +
						content_tag('td', dup.is_direct(issue.id) ? l(:duplicates_text_direct) : l(:duplicates_text_indirect), :class => 'direct') +
						content_tag('td', dup.is_root ? "(#{l(:duplicates_text_root)})" : "", :class => 'root') +
						content_tag('td', other_issue.status, :class => 'status') +
						content_tag('td', format_date(other_issue.created_on), :class => 'start_date'),
						:id => "duplicate-#{dup.id}",
						:class => css
					)
			end
			content_tag('table', s, :class => 'list issues odd-even')
		end
	end
end
IssuesHelper.send(:include, IssuesHelperPatch)