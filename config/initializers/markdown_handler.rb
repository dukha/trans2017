#this modlue enables markdown files to contain erb code that will be precompiled prioer to display
# The file should be named *.html.md The erb will be processed first.

require 'rdiscount'

module MarkdownHandler
  def self.erb
    @erb ||= ActionView::Template.registered_template_handler(:erb)
  end

  def self.call(template)
    compiled_source = erb.call(template).html_safe
    "RDiscount.new(begin;#{compiled_source};end).to_html"
  end
end

ActionView::Template.register_template_handler :md, MarkdownHandler