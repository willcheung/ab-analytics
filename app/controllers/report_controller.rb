class ReportController < ApplicationController
  def dashboard
    raw_data_rtn = []
    raw_data_str = []
    region_list = []
    @data_retention = []
    @data_streaming = []
    @highlighted = []
    @highlighted_str = []
    data = {}
    @cells = []
    @cell_name = []
    @selection = []
    
    # Assigning test metadata
    @period_label = PERIOD_LABELS[params[:period].to_sym]
    period = PERIOD_DATA_MAP[params[:period].to_sym]
    sub_plan = PLAN_DATA_MAP[params[:plan].to_sym]
    device = DEVICE_DATA_MAP[params[:device].to_sym]
    @test_id = params[:test]
    
    if params[:region].empty?
      region = REGION_DATA_MAP[:all]
      params[:region] = 'all'
    else
      params[:region].split(',').collect {|r| region_list << REGION_DATA_MAP[r.to_sym]}
      region = region_list.join(',')
    end
    
    @test_name, @cells, @cell_names = RdsReport.get_test_and_cells(@test_id)
    
    #########################
    # Drop down selection for cell comparison
    #########################
    if params[:selection]
      @selection = params[:selection].split(",").collect {|x| x.to_i}
      if @selection.size != @cells.size
        @selection.clear
        @cells.each {|c| @selection<<@cells[0]}
      end
    else # default compares everything to first cell
      @cells.each {|c| @selection<<@cells[0]}
    end
    
    ##########################################
    # Get retention data, which determines whether the returned dataset is nil or not
    ##########################################
    raw_data_rtn = RdsReport.get_retention(@test_id, period, region, sub_plan)
    
    unless raw_data_rtn.nil? or raw_data_rtn.empty? or raw_data_rtn[0]['test_cell_id'].nil?
      # If not nil, then process retention and get streaming data
      @data_retention, @highlighted = RdsReport.render_retention_grid(raw_data_rtn, period, @selection, @cells, {:debug => params[:debug]})
      
      raw_data_str = RdsReport.get_streaming(@test_id, period, region, sub_plan, device)
      @data_streaming, @highlighted_str = RdsReport.render_streaming_grid(raw_data_str, raw_data_rtn, @selection, @cells, {:debug => params[:debug]})
  
      # Javascript likes JSON 
      @highlighted = @highlighted.to_json
      @highlighted_str = @highlighted_str.to_json
      @data_streaming = @data_streaming.to_json
      @data_retention = @data_retention.to_json
      @cell_names = @cell_names.to_json
    else
      @data_retention = nil
      @data_streaming = nil
    end
  end
  
  def dashboard_old
    @data_retention = []
    @highlighted = []
    data = {}
    @cells = []
    @cell_name = []
    @selection = []
    
    allocations = MstrReport.get_allocations
    @cells, @cell_names = MstrReport.get_cells(allocations)
    
    # Drop down selection for cell comparison
    if params[:selection]
      @selection = params[:selection].split(",").collect {|x| x.to_i}
      if @selection.size != @cells.size
        @selection.clear
        @cells.each {|c| @selection<<@cells[0]}
      end
    else # default compares everything to first cell
      @cells.each {|c| @selection<<@cells[0]}
    end
    
    @data_retention, @highlighted = MstrReport.get_retention_grid(allocations, @selection, @cells, {:debug => params[:debug]})
    
    # Javascript likes JSON format
    @highlighted = @highlighted.to_json
    @data_retention = @data_retention.to_json
    @data_streaming = @data_streaming.to_json
    @cell_names = @cell_names.to_json
  end
end