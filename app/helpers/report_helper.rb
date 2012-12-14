module ReportHelper
  def show_filter_selection(str)
    s = ""
    str.split(',').collect {|r| s+="<span class=\"badge\">#{REGION_LABELS[r.to_sym]}</span>&nbsp;" }
    sanitize s.to_s
  end
end