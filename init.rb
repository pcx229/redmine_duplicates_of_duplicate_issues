require 'redmine'

require_relative 'lib/issue_patch'
require_relative 'lib/issue_query_patch'
require_relative 'lib/issue_relation_patch'
require_relative 'lib/views_hook'
require_relative 'lib/issues_helper_patch'
require_relative 'lib/duplicates_query_column'

Redmine::Plugin.register :redmine_duplicates_of_duplicate_issues do
	name 'Duplicates Of Duplicate Issues'
	author 'Eli Elbaz'
	description 'show all direct/in-direct duplicates each issue have'
	version '1.0.0'
	url 'https://github.com/pcx229/redmine_duplicates_of_duplicate_issues'
end