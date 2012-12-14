include ActionView::Helpers::NumberHelper
include ApplicationHelper

class MstrReport
  
  def self.get_allocations
    allocations = JSON.parse(File.read("/Users/wcheung/Desktop/allocations_new.json"))
    if allocations['status'] == "OK"
      return allocations['data']
    else
      return "Error: error message here."
    end
  end
  
  def self.get_cells(allocations)
    cells=[]
    cell_names=[]
    
    allocations.each_with_index do |a,i|      
      cells << a['attribute']['test_cell_id'].to_i
      cell_names << a['attribute']['test_cell_name'].to_s
    end
    
    return cells, cell_names
  end
  
  def self.calculate_retention(allocations, selection)
    data = {}
    cells = []
    
    # Set the static values first
    allocations.each_with_index do |a,i|      
      cell_num = a['attribute']['test_cell_id'].to_s
      cells << a['attribute']['test_cell_id'].to_s
      
      data["cell_#{cell_num}_allocations"] = a['metric']['Allocations'].to_i 
      data["cell_#{cell_num}_p1completes"] = a['metric']['P1 Completes'].to_i
      data["cell_#{cell_num}_p2completes"] = a['metric']['P2 Completes'].to_i
      data["cell_#{cell_num}_p3completes"] = a['metric']['P3 Completes'].to_i
      data["cell_#{cell_num}_currentsubs"] = a['metric']['Current Subs'].to_i
      
      data["cell_#{cell_num}_p1retention"] = (a['metric']['P1 Completes'].to_f / a['metric']['Allocations'].to_f)
      data["cell_#{cell_num}_p2retention"] = (a['metric']['P2 Completes'].to_f / a['metric']['P1 Completes'].to_f)
      data["cell_#{cell_num}_p3retention"] = (a['metric']['P3 Completes'].to_f / a['metric']['P2 Completes'].to_f)
      data["cell_#{cell_num}_cumretention"] = (a['metric']['Current Subs'].to_f / a['metric']['Allocations'].to_f)
    end
    
    # Set the dynamic values, which can toggle between different test cells
    cells.each_with_index do |cell_num,i|
      data["cell_#{cell_num}_p1combrtn"] = ((data["cell_#{cell_num}_p1completes"] + data["cell_#{selection[i]}_p1completes"]).to_f / (data["cell_#{cell_num}_allocations"] + data["cell_#{selection[i]}_allocations"]).to_f)
      data["cell_#{cell_num}_p2combrtn"] = ((data["cell_#{cell_num}_p2completes"] + data["cell_#{selection[i]}_p2completes"]).to_f / (data["cell_#{cell_num}_p1completes"] + data["cell_#{selection[i]}_p1completes"]).to_f)
      data["cell_#{cell_num}_p3combrtn"] = ((data["cell_#{cell_num}_p3completes"] + data["cell_#{selection[i]}_p3completes"]).to_f / (data["cell_#{cell_num}_p2completes"] + data["cell_#{selection[i]}_p2completes"]).to_f)
      data["cell_#{cell_num}_cumcombrtn"] = ((data["cell_#{cell_num}_currentsubs"] + data["cell_#{selection[i]}_currentsubs"]).to_f / (data["cell_#{cell_num}_allocations"] + data["cell_#{selection[i]}_allocations"]).to_f)
      
      data["cell_#{cell_num}_p1zstat"] = Stats.zstat(data["cell_#{cell_num}_p1retention"].to_f, data["cell_#{selection[i]}_p1retention"].to_f, data["cell_#{cell_num}_p1combrtn"].to_f, data["cell_#{cell_num}_allocations"].to_f, data["cell_#{selection[i]}_allocations"].to_f)
      data["cell_#{cell_num}_p2zstat"] = Stats.zstat(data["cell_#{cell_num}_p2retention"].to_f, data["cell_#{selection[i]}_p2retention"].to_f, data["cell_#{cell_num}_p2combrtn"].to_f, data["cell_#{cell_num}_p1completes"].to_f, data["cell_#{selection[i]}_p1completes"].to_f)
      data["cell_#{cell_num}_p3zstat"] = Stats.zstat(data["cell_#{cell_num}_p3retention"].to_f, data["cell_#{selection[i]}_p3retention"].to_f, data["cell_#{cell_num}_p3combrtn"].to_f, data["cell_#{cell_num}_p2completes"].to_f, data["cell_#{selection[i]}_p2completes"].to_f)
      data["cell_#{cell_num}_cumzstat"] = Stats.zstat(data["cell_#{cell_num}_cumretention"].to_f, data["cell_#{selection[i]}_cumretention"].to_f, data["cell_#{cell_num}_cumcombrtn"].to_f, data["cell_#{cell_num}_allocations"].to_f, data["cell_#{selection[i]}_allocations"].to_f)
    
      data["cell_#{cell_num}_p1pvalue"] = Stats.pvalue(data["cell_#{cell_num}_p1zstat"])
      data["cell_#{cell_num}_p2pvalue"] = Stats.pvalue(data["cell_#{cell_num}_p2zstat"])
      data["cell_#{cell_num}_p3pvalue"] = Stats.pvalue(data["cell_#{cell_num}_p3zstat"])
      data["cell_#{cell_num}_cumpvalue"] = Stats.pvalue(data["cell_#{cell_num}_cumzstat"])
    end
    
    return data
  end
  
  ###############################################
  #
  # Data input to slickgrid should look like the following:
  #             cell 1    cell 2    cell 3
  # metric 1    {m1,c1,c2,c3}
  # metric 2    {m2,c1,c2,c3}
  #
  ###############################################
  def self.get_retention_grid(allocations, selection, cells, options={})
    data_retention = []
    highlighted = []
    
    data = {}
    allocation = {}
    p1_complete = {}
    p2_complete = {}
    p3_complete = {}
    curr_subs = {}
    p1_rtn = {} 
    p2_rtn = {} 
    p3_rtn = {}
    cum_rtn = {}
    p1_combn = {}
    p2_combn = {}
    p3_combn = {}
    cum_combn = {}
    p1_zstat = {}
    p2_zstat = {}
    p3_zstat = {}
    cum_zstat = {}
    p1_pvalue = {}
    p2_pvalue = {}
    p3_pvalue = {}
    cum_pvalue = {}
    p1_rtn_style = {}
    p1_pvalue_style = {}
    p2_rtn_style = {}
    p2_pvalue_style = {}
    p3_rtn_style = {}
    p3_pvalue_style = {}
    cum_rtn_style = {}
    cum_pvalue_style = {}
    
    data = MstrReport.calculate_retention(allocations, selection)
    
    # Create array of data (with number formatting) for SlickGrid
    cells.each_with_index do |cell_num,i|
      allocation["metric"] = METRIC_LABELS[:allocations] if i==0
      allocation["cell_id_#{cell_num}"] = number_with_delimiter(data["cell_#{cell_num}_allocations"])
      p1_complete["metric"] = METRIC_LABELS[:p1_completes] if i==0
      p1_complete["cell_id_#{cell_num}"] = number_with_delimiter(data["cell_#{cell_num}_p1completes"])
      p2_complete["metric"] = METRIC_LABELS[:p2_completes] if i==0
      p2_complete["cell_id_#{cell_num}"] = number_with_delimiter(data["cell_#{cell_num}_p2completes"])
      p3_complete["metric"] = METRIC_LABELS[:p3_completes] if i==0
      p3_complete["cell_id_#{cell_num}"] = number_with_delimiter(data["cell_#{cell_num}_p3completes"])
      curr_subs["metric"] = METRIC_LABELS[:current_subs] if i==0
      curr_subs["cell_id_#{cell_num}"] = number_with_delimiter(data["cell_#{cell_num}_currentsubs"])
      
      p1_rtn["metric"] = METRIC_LABELS[:p1_retention] if i==0
      p1_rtn["cell_id_#{cell_num}"] = number_with_precision(data["cell_#{cell_num}_p1retention"]*100, :precision => 1) + "%"
      p2_rtn["metric"] = METRIC_LABELS[:p2_retention] if i==0
      p2_rtn["cell_id_#{cell_num}"] = number_with_precision(data["cell_#{cell_num}_p2retention"]*100, :precision => 1) + "%"
      p3_rtn["metric"] = METRIC_LABELS[:p3_retention] if i==0
      p3_rtn["cell_id_#{cell_num}"] = number_with_precision(data["cell_#{cell_num}_p3retention"]*100, :precision => 1) + "%"
      cum_rtn["metric"] = METRIC_LABELS[:cumulative_retention]
      cum_rtn["cell_id_#{cell_num}"] = number_with_precision(data["cell_#{cell_num}_cumretention"]*100, :precision => 1) + "%"
      
      p1_combn["metric"] = METRIC_LABELS[:p1_combn_retention] if i==0
      p1_combn["cell_id_#{cell_num}"] = number_with_precision(data["cell_#{cell_num}_p1combrtn"]*100, :precision => 1) + "%"
      p2_combn["metric"] = METRIC_LABELS[:p2_combn_retention] if i==0
      p2_combn["cell_id_#{cell_num}"] = number_with_precision(data["cell_#{cell_num}_p2combrtn"]*100, :precision => 1) + "%"
      p3_combn["metric"] = METRIC_LABELS[:p3_combn_retention] if i==0
      p3_combn["cell_id_#{cell_num}"] = number_with_precision(data["cell_#{cell_num}_p3combrtn"]*100, :precision => 1) + "%"
      cum_combn["metric"] = METRIC_LABELS[:cumulative_combn_retention] if i==0
      cum_combn["cell_id_#{cell_num}"] = number_with_precision(data["cell_#{cell_num}_cumcombrtn"]*100, :precision => 1) + "%"
      
      p1_zstat["metric"] = "Z stat" if i==0
      p1_zstat["cell_id_#{cell_num}"] = number_with_precision(data["cell_#{cell_num}_p1zstat"], :precision => 2)
      p2_zstat["metric"] = "Z stat" if i==0
      p2_zstat["cell_id_#{cell_num}"] = number_with_precision(data["cell_#{cell_num}_p2zstat"], :precision => 2)
      p3_zstat["metric"] = "Z stat" if i==0
      p3_zstat["cell_id_#{cell_num}"] = number_with_precision(data["cell_#{cell_num}_p3zstat"], :precision => 2)
      cum_zstat["metric"] = "Z stat" if i==0
      cum_zstat["cell_id_#{cell_num}"] = number_with_precision(data["cell_#{cell_num}_cumzstat"], :precision => 2)
      
      p1_pvalue["metric"] = "p-value" if i==0
      p1_pvalue["cell_id_#{cell_num}"] = number_with_precision(data["cell_#{cell_num}_p1pvalue"], :precision => 3)
      p2_pvalue["metric"] = "p-value" if i==0
      p2_pvalue["cell_id_#{cell_num}"] = number_with_precision(data["cell_#{cell_num}_p2pvalue"], :precision => 3)
      p3_pvalue["metric"] = "p-value" if i==0
      p3_pvalue["cell_id_#{cell_num}"] = number_with_precision(data["cell_#{cell_num}_p3pvalue"], :precision => 3)
      cum_pvalue["metric"] = "p-value" if i==0
      cum_pvalue["cell_id_#{cell_num}"] = number_with_precision(data["cell_#{cell_num}_cumpvalue"], :precision => 3)
      
      p1_rtn_style["cell_id_#{cell_num}"] = highlight_cell(data["cell_#{cell_num}_p1zstat"], data["cell_#{cell_num}_p1pvalue"])
      p2_rtn_style["cell_id_#{cell_num}"] = highlight_cell(data["cell_#{cell_num}_p2zstat"], data["cell_#{cell_num}_p2pvalue"])
      p3_rtn_style["cell_id_#{cell_num}"] = highlight_cell(data["cell_#{cell_num}_p3zstat"], data["cell_#{cell_num}_p3pvalue"])
      cum_rtn_style["cell_id_#{cell_num}"] = highlight_cell(data["cell_#{cell_num}_cumzstat"], data["cell_#{cell_num}_cumpvalue"]) + " text-bold"
      p1_pvalue_style["cell_id_#{cell_num}"] = highlight_cell(data["cell_#{cell_num}_p1zstat"], data["cell_#{cell_num}_p1pvalue"]) + " stats"
      p2_pvalue_style["cell_id_#{cell_num}"] = highlight_cell(data["cell_#{cell_num}_p2zstat"], data["cell_#{cell_num}_p2pvalue"]) + " stats"
      p3_pvalue_style["cell_id_#{cell_num}"] = highlight_cell(data["cell_#{cell_num}_p3zstat"], data["cell_#{cell_num}_p3pvalue"]) + " stats"
      cum_pvalue_style["cell_id_#{cell_num}"] = highlight_cell(data["cell_#{cell_num}_cumzstat"], data["cell_#{cell_num}_cumpvalue"]) + " stats"
      cum_rtn_style["metric"] = "text-bold"
      p1_pvalue_style["metric"] = "stats"
      p2_pvalue_style["metric"] = "stats"
      p3_pvalue_style["metric"] = "stats"
      cum_pvalue_style["metric"] = "stats"
    end
    
    # Each line below represents table rows
    data_retention << allocation
    data_retention << p1_complete if options[:debug]=="true"
    data_retention << p2_complete if options[:debug]=="true"
    data_retention << p3_complete if options[:debug]=="true"
    data_retention << curr_subs
    data_retention << p1_rtn
    data_retention << p1_combn if options[:debug]=="true"
    data_retention << p1_zstat if options[:debug]=="true"
    data_retention << p1_pvalue
    data_retention << p2_rtn
    data_retention << p2_combn if options[:debug]=="true"
    data_retention << p2_zstat if options[:debug]=="true"
    data_retention << p2_pvalue
    data_retention << p3_rtn
    data_retention << p3_combn if options[:debug]=="true"
    data_retention << p3_zstat if options[:debug]=="true"
    data_retention << p3_pvalue
    data_retention << cum_rtn
    data_retention << cum_combn if options[:debug]=="true"
    data_retention << cum_zstat if options[:debug]=="true"
    data_retention << cum_pvalue
    
    # The styles are hard-coded to the rows
    # Change here if row #s change
    if options[:debug] == "true"
      highlighted[5] = p1_rtn_style     
      highlighted[8] = p1_pvalue_style
      highlighted[9] = p2_rtn_style     
      highlighted[12] = p2_pvalue_style
      highlighted[13] = p3_rtn_style
      highlighted[16] = p3_pvalue_style
      highlighted[17] = cum_rtn_style
      highlighted[20] = cum_pvalue_style
    else
      highlighted[2] = p1_rtn_style    
      highlighted[3] = p1_pvalue_style 
      highlighted[4] = p2_rtn_style 
      highlighted[5] = p2_pvalue_style   
      highlighted[6] = p3_rtn_style
      highlighted[7] = p3_pvalue_style        
      highlighted[8] = cum_rtn_style
      highlighted[9] = cum_pvalue_style
    end
    
    return data_retention, highlighted
  end
  
  def self.display_data_from_allocations(allocations)
    Create allocations data array
    allocations.each_with_index do |a,i|
      a['metric'].keys.each_with_index do |m,j|
        if i == 0 # Cell 0
          allocation["metric"] = m # Insert metric name directly from JSON response
          allocation["cell_id_#{a['attribute']['test_cell_id']}"] = a['metric'][m] # Insert cell 0 metric value
          data_retention[j] = allocation
        else # All other cells
          tmp = data_retention[j] # Get original hash
          tmp["cell_id_#{a['attribute']['test_cell_id']}"] = a['metric'][m] # Insert new key / value pair
          data_retention[j] = tmp # Replace original hash
        end
        allocation = {}
      end
      
      # populate all the cell IDs
      @cells << a['attribute']['test_cell_id']
    end
  end
  
  def self.get_streaming
    streaming = JSON.parse(File.read("/Users/wcheung/Desktop/streaming_new.json"))
  end 
end