

class IncludeStyleForDuplicateColumnHook < Redmine::Hook::ViewListener
	include ActionView::Helpers::TagHelper

	# add style for duplicates column
	def view_layouts_base_html_head(context)
		styles = [stylesheet_link_tag('application', plugin: 'redmine_duplicates_of_duplicate_issues')]
		if l(:direction) == 'rtl'
			styles << stylesheet_link_tag('rtl', plugin: 'redmine_duplicates_of_duplicate_issues')
		end
		styles
	end

	# all duplicates in issue page
    render_on :view_issues_show_description_bottom,
              :partial => 'hooks/redmine_duplicates_of_duplicate_issues/duplicates'
end