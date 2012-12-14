class SiteController < ApplicationController
  
  def home
    # For test autocomplete
    @tests = RdsReport.get_test_md
  end

  def about
  end

end
