module ApplicationHelper
  
  def array_for_javascript(option)
    if option.kind_of?(Array)
      "[#{option.join('\',\'')}]"
    elsif !option.nil?
      "'#{option}'"
    end
  end
  
  def highlight_cell(zstat, pvalue)
    if pvalue < 0.05
      if zstat > 0
        return "green-highlighted"
      else
        return "red-highlighted"
      end
    else
      return ""
    end
  end
  
  def link_to_unless_current_tab(name, options = {}, html_options = {}, &block)
    if current_page?(options)
      return sanitize("<a href=\"#\">#{name}</a>")
    else
      link_to(name, options, html_options, &block)
    end
  end

end
