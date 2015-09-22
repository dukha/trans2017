module ApplicationHelper
  include WillPaginate::ViewHelpers
  require 'translations_helper'
  include TranslationsHelper

  
  $APPLICATION_NAME = "Vipassana Translator"
  $APPLICATION_VERSION ="0.9.0"
  
def titler
    #if @title.nil?
      $APPLICATION_NAME
    #else
      #"#{$APPLICATION_NAME} : #{@title}"
    #end
  end

  def logo
    image_tag( "bodhi.gif", :alt => "Bodhi leaf not found", :height=>"50px")
  end
  # you need this if you are doing hebrew or arabic
  def text_direction
    I18n.translate(:'bidi.direction') == 'right-to-left' ? 'rtl' : 'ltr'
    # in ../locale/he.yml add
    # he:
        #bidi:
        #direction: right-to-left
    # then in ../locale/root.yml  add
    # root:
       #bidi:
       #  direction: left-to-right
  end
  # Use to display flash in different places if required
  # Removes flashes once they are displayed
  def display_flashes
    html = ''
    flash.each do |name, msg|
      if msg.blank? || msg == true
        break
      else
        html.concat(content_tag :div, msg, :id => "flash_#{name}")
      end
    end # do
    flash.discard
    return html.html_safe   
  end
def markdown_file( path)
  text = File.read(path)
  markdown(text)
end  

def markdown(text)
  render_options = {
    # will remove from the output HTML tags inputted by user 
    filter_html:     true,
    # will insert <br /> tags in paragraphs where are newlines 
    # (ignored by default)
    hard_wrap:       true, 
    # hash for extra link options, for example 'nofollow'
    link_attributes: { rel: 'nofollow' },
    # more
    # will remove <img> tags from output
    # no_images: true
    # will remove <a> tags from output
    # no_links: true
    # will remove <style> tags from output
     no_styles: false
    # generate links for only safe protocols
    # safe_links_only: true
    # and more ... (prettify, with_toc_data, xhtml)
  }
  renderer = Redcarpet::Render::HTML.new(render_options)

  extensions = {
    #will parse links without need of enclosing them
    autolink:           true,
    # blocks delimited with 3 ` or ~ will be considered as code block. 
    # No need to indent.  You can provide language name too.
    # ```ruby
    # block of code
    # ```
    fenced_code_blocks: true,
    # will ignore standard require for empty lines surrounding HTML blocks
    lax_spacing:        true,
    # will not generate emphasis inside of words, for example no_emph_no
    no_intra_emphasis:  false,
    # will parse strikethrough from ~~, for example: ~~bad~~
    strikethrough:      true,
    # will parse superscript after ^, you can wrap superscript in () 
    superscript:        true
    # will require a space after # in defining headers
    # space_after_headers: true
  }
  
  Redcarpet::Markdown.new(renderer, extensions).render(text).html_safe
end


def display_timestamp (time)
    if time.blank?
      return ''
    else
      #binding.pry
      #return time.localtime.in_time_zone(current_user.time_zone).strftime("%e-%b-%y %H:%M") if current_user && current_user.time_zone
      return time.localtime.strftime("%e-%b-%y %H:%M")  
    end
  end   
end
