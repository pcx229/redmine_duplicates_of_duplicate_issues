# Redmine duplicates of duplicate issues plugin  
Redmine lets you specify an issue as a duplicate of another issue using relations.  
direct duplicate issues are two issues with a duplicate relation between them (Is\Has duplicate).  
you can see direct duplicate issues in the project issues page by looking at the column "Related issues" or at the issue page under "Related issues" section.  
indirect duplicates are two issues that are connected in any way by duplicate relations.  
for example:  
*  A is duplicate of C
*  B is duplicate of C  
	==> A is indirect duplicate of B

this plugin will add:
1. a column to project issues page that will show you all direct and indirect duplicate of an issue.  
1. a filter that allows you to search on the added column.
1. a section in issue page that list all the duplicate issues.
1. a group option by duplicates.

### requirements  
Redmine 5.0  

### install  
1. download plugin and copy plugin directory redmine_duplicates_of_duplicate_issues to Redmine's plugins directory.  
1. initialize the database by running the following command in Redmine's directory:  
	```bundle exec rake redmine:plugins:migrate RAILS_ENV=production```
1. restart server  

### uninstall  
1. remove database by running the following command:  
	```bundle exec rake redmine:plugins:migrate NAME=redmine_duplicates_of_duplicate_issues VERSION=0 RAILS_ENV=production``` 
1. go to Redmine's plugins directory, delete plugin directory redmine_duplicates_of_duplicate_issues  
1. restart server  

### screenshot  

![issues table and filter](https://raw.githubusercontent.com/pcx229/redmine_duplicates_of_duplicate_issues/master/screenshot_project_issues_page.jpg)  

![issue duplicates list](https://raw.githubusercontent.com/pcx229/redmine_duplicates_of_duplicate_issues/master/screenshot_issue_page.jpg)

![issue table and group](https://raw.githubusercontent.com/pcx229/redmine_duplicates_of_duplicate_issues/master/screenshot_project_issues_page_2.jpg)
