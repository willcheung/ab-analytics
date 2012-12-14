include ActionView::Helpers::NumberHelper
include ApplicationHelper

class RdsReport
  def self.get_test_md
    tests = []
    test_md = ActiveRecord::Base.connection.select_all("select distinct(test_id) as test_id, 
                                                          test_name 
                                                        from retention_agg;")
                                                        
    test_md.each do |t|
      tests << t['test_id'].to_s + " - " + t['test_name'].to_s
    end
    
    return tests.to_json
  end
  
  def self.get_test_and_cells(test_id)
    cells=[]
    cell_names=[]
    
    test_md = ActiveRecord::Base.connection.select_all("select distinct(test_name), 
                                                          test_cell_id, 
                                                          test_cell_name 
                                                        from retention_agg where test_id="+test_id+";")

    test_md.each do |c|
      cells << c['test_cell_id']
      cell_names << c['test_cell_name']
    end
    
    return test_md[0]['test_name'], cells, cell_names
  end
  
  def self.get_streaming(test_id, period, region, plan, device)
    ActiveRecord::Base.connection.select_all("select 
                                                test_cell_id,
                                                sum(num_allocations_ge_0_hrs) as ge_0_hrs,
                                                sum(num_allocations_ge_1_hr) as ge_1_hr,
                                                sum(num_allocations_ge_5_hrs) as ge_5_hrs,
                                                sum(num_allocations_ge_10_hrs) as ge_10_hrs,
                                                sum(num_allocations_ge_20_hrs) as ge_20_hrs,
                                                sum(num_allocations_ge_40_hrs) as ge_40_hrs,
                                                sum(num_allocations_ge_80_hrs) as ge_80_hrs
                                              from streaming_agg 
                                              where test_id="+test_id+
                                                " and period='"+period+"'"+
                                                " and allocation_region in ("+region+")"+
                                                " and initial_plan in ("+plan+")"+
                                                " and major_device_category in ("+device+")"+
                                              " group by test_cell_id;")
  end
  
  def self.get_retention(test_id, period, region, plan)
    ActiveRecord::Base.connection.select_all("SELECT 
                                                test_cell_id,
                                                sum(num_allocations) as num_allocations,
                                                sum(num_cancels) as num_cancels,
                                                sum(num_period_starts) as num_period_starts,
                                                sum(num_period_completes) as num_period_completes,
                                                sum(sum_predicted_tenure) as sum_predicted_tenure,
                                                sum(sum_predicted_tenure_sq) as sum_predicted_tenure_sq
                                              FROM retention_agg 
                                              WHERE test_id="+test_id+
                                                " and period='"+period+"'"+
                                                " and allocation_region in ("+region+")"+
                                                " and initial_plan in ("+plan+")"+
                                              " GROUP BY test_cell_id;")
  end
  
  def self.calculate_streaming(raw_data_str, raw_data_rtn, selection)
    data = {}
    cells = []
    
    # Still need # of Allocations to calculate % subs streaming
    raw_data_rtn.each_with_index do |a,i|      
      cell_num = a['test_cell_id'].to_s
      data["cell_#{cell_num}_allocations"] = a['num_allocations'].to_i
    end
    
    # Set the static values first
    raw_data_str.each_with_index do |a,i|      
      cell_num = a['test_cell_id'].to_s
      cells << a['test_cell_id'].to_s
      
      # Raw number of allocated subs
      data["cell_#{cell_num}_ge_0h"] = a['ge_0_hrs'].to_i 
      data["cell_#{cell_num}_ge_1h"] = a['ge_1_hr'].to_i
      data["cell_#{cell_num}_ge_5h"] = a['ge_5_hrs'].to_i
      data["cell_#{cell_num}_ge_10h"] = a['ge_10_hrs'].to_i
      data["cell_#{cell_num}_ge_20h"] = a['ge_20_hrs'].to_i
      data["cell_#{cell_num}_ge_40h"] = a['ge_40_hrs'].to_i
      data["cell_#{cell_num}_ge_80h"] = a['ge_80_hrs'].to_i
      
      # Percent over total allocations
      data["cell_#{cell_num}_percent_0h"] = data["cell_#{cell_num}_ge_0h"].to_f / data["cell_#{cell_num}_allocations"].to_f
      data["cell_#{cell_num}_percent_1h"] = data["cell_#{cell_num}_ge_1h"].to_f / data["cell_#{cell_num}_allocations"].to_f
      data["cell_#{cell_num}_percent_5h"] = data["cell_#{cell_num}_ge_5h"].to_f / data["cell_#{cell_num}_allocations"].to_f
      data["cell_#{cell_num}_percent_10h"] = data["cell_#{cell_num}_ge_10h"].to_f / data["cell_#{cell_num}_allocations"].to_f
      data["cell_#{cell_num}_percent_20h"] = data["cell_#{cell_num}_ge_20h"].to_f / data["cell_#{cell_num}_allocations"].to_f
      data["cell_#{cell_num}_percent_40h"] = data["cell_#{cell_num}_ge_40h"].to_f / data["cell_#{cell_num}_allocations"].to_f
      data["cell_#{cell_num}_percent_80h"] = data["cell_#{cell_num}_ge_80h"].to_f / data["cell_#{cell_num}_allocations"].to_f
    end
    
    # Set the dynamic values, which can toggle between different test cells
    cells.each_with_index do |cell_num,i|
      data["cell_#{cell_num}_comb_0h"] = ((data["cell_#{cell_num}_ge_0h"] + data["cell_#{selection[i]}_ge_0h"]).to_f / (data["cell_#{cell_num}_allocations"] + data["cell_#{selection[i]}_allocations"]).to_f)
      data["cell_#{cell_num}_comb_1h"] = ((data["cell_#{cell_num}_ge_1h"] + data["cell_#{selection[i]}_ge_1h"]).to_f / (data["cell_#{cell_num}_allocations"] + data["cell_#{selection[i]}_allocations"]).to_f)
      data["cell_#{cell_num}_comb_5h"] = ((data["cell_#{cell_num}_ge_5h"] + data["cell_#{selection[i]}_ge_5h"]).to_f / (data["cell_#{cell_num}_allocations"] + data["cell_#{selection[i]}_allocations"]).to_f)
      data["cell_#{cell_num}_comb_10h"] = ((data["cell_#{cell_num}_ge_10h"] + data["cell_#{selection[i]}_ge_10h"]).to_f / (data["cell_#{cell_num}_allocations"] + data["cell_#{selection[i]}_allocations"]).to_f)
      data["cell_#{cell_num}_comb_20h"] = ((data["cell_#{cell_num}_ge_20h"] + data["cell_#{selection[i]}_ge_20h"]).to_f / (data["cell_#{cell_num}_allocations"] + data["cell_#{selection[i]}_allocations"]).to_f)
      data["cell_#{cell_num}_comb_40h"] = ((data["cell_#{cell_num}_ge_40h"] + data["cell_#{selection[i]}_ge_40h"]).to_f / (data["cell_#{cell_num}_allocations"] + data["cell_#{selection[i]}_allocations"]).to_f)
      data["cell_#{cell_num}_comb_80h"] = ((data["cell_#{cell_num}_ge_80h"] + data["cell_#{selection[i]}_ge_80h"]).to_f / (data["cell_#{cell_num}_allocations"] + data["cell_#{selection[i]}_allocations"]).to_f)
      
      data["cell_#{cell_num}_zstat_percent_0h"] = Stats.zstat(data["cell_#{cell_num}_percent_0h"].to_f, data["cell_#{selection[i]}_percent_0h"].to_f, data["cell_#{cell_num}_comb_0h"].to_f, data["cell_#{cell_num}_allocations"].to_f, data["cell_#{selection[i]}_allocations"].to_f)
      data["cell_#{cell_num}_zstat_percent_1h"] = Stats.zstat(data["cell_#{cell_num}_percent_1h"].to_f, data["cell_#{selection[i]}_percent_1h"].to_f, data["cell_#{cell_num}_comb_1h"].to_f, data["cell_#{cell_num}_allocations"].to_f, data["cell_#{selection[i]}_allocations"].to_f)
      data["cell_#{cell_num}_zstat_percent_5h"] = Stats.zstat(data["cell_#{cell_num}_percent_5h"].to_f, data["cell_#{selection[i]}_percent_5h"].to_f, data["cell_#{cell_num}_comb_5h"].to_f, data["cell_#{cell_num}_allocations"].to_f, data["cell_#{selection[i]}_allocations"].to_f)
      data["cell_#{cell_num}_zstat_percent_10h"] = Stats.zstat(data["cell_#{cell_num}_percent_10h"].to_f, data["cell_#{selection[i]}_percent_10h"].to_f, data["cell_#{cell_num}_comb_10h"].to_f, data["cell_#{cell_num}_allocations"].to_f, data["cell_#{selection[i]}_allocations"].to_f)
      data["cell_#{cell_num}_zstat_percent_20h"] = Stats.zstat(data["cell_#{cell_num}_percent_20h"].to_f, data["cell_#{selection[i]}_percent_20h"].to_f, data["cell_#{cell_num}_comb_20h"].to_f, data["cell_#{cell_num}_allocations"].to_f, data["cell_#{selection[i]}_allocations"].to_f)
      data["cell_#{cell_num}_zstat_percent_40h"] = Stats.zstat(data["cell_#{cell_num}_percent_40h"].to_f, data["cell_#{selection[i]}_percent_40h"].to_f, data["cell_#{cell_num}_comb_40h"].to_f, data["cell_#{cell_num}_allocations"].to_f, data["cell_#{selection[i]}_allocations"].to_f)
      data["cell_#{cell_num}_zstat_percent_80h"] = Stats.zstat(data["cell_#{cell_num}_percent_80h"].to_f, data["cell_#{selection[i]}_percent_80h"].to_f, data["cell_#{cell_num}_comb_80h"].to_f, data["cell_#{cell_num}_allocations"].to_f, data["cell_#{selection[i]}_allocations"].to_f)
      
      data["cell_#{cell_num}_pvalue_percent_0h"] = Stats.pvalue(data["cell_#{cell_num}_zstat_percent_0h"])
      data["cell_#{cell_num}_pvalue_percent_1h"] = Stats.pvalue(data["cell_#{cell_num}_zstat_percent_1h"])
      data["cell_#{cell_num}_pvalue_percent_5h"] = Stats.pvalue(data["cell_#{cell_num}_zstat_percent_5h"])
      data["cell_#{cell_num}_pvalue_percent_10h"] = Stats.pvalue(data["cell_#{cell_num}_zstat_percent_10h"])
      data["cell_#{cell_num}_pvalue_percent_20h"] = Stats.pvalue(data["cell_#{cell_num}_zstat_percent_20h"])
      data["cell_#{cell_num}_pvalue_percent_40h"] = Stats.pvalue(data["cell_#{cell_num}_zstat_percent_40h"])
      data["cell_#{cell_num}_pvalue_percent_80h"] = Stats.pvalue(data["cell_#{cell_num}_zstat_percent_80h"])
    end
    
    return data
  end
  
  def self.render_streaming_grid(raw_data_str, raw_data_rtn, selection, cells, options={})
    data = {}
    data_streaming = []
    highlighted = []
    row_count = 0
    
    data = self.calculate_streaming(raw_data_str, raw_data_rtn, selection)
    
    STREAMING_METRICS.each do |k,v|
      tmp_perc = {}
      tmp_pval = {}
      tmp_perc_style = {}
      tmp_pval_style = {}
      
      tmp_perc["metric"] = v
      tmp_pval["metric"] = "p-value"
      tmp_pval_style["metric"] = "stats"
      
      cells.each do |cell_num|
        tmp_perc["cell_id_#{cell_num}"] = number_with_precision(data["cell_#{cell_num}_#{k}"]*100, :precision => 1) + "%"
        tmp_pval["cell_id_#{cell_num}"] = number_with_precision(data["cell_#{cell_num}_pvalue_#{k}"], :precision => 3)
        tmp_perc_style["cell_id_#{cell_num}"] = highlight_cell(data["cell_#{cell_num}_zstat_#{k}"], data["cell_#{cell_num}_pvalue_#{k}"])
        tmp_pval_style["cell_id_#{cell_num}"] = highlight_cell(data["cell_#{cell_num}_zstat_#{k}"], data["cell_#{cell_num}_pvalue_#{k}"]) + " stats"
      end
      
      data_streaming << tmp_perc
      highlighted << tmp_perc_style
      data_streaming << tmp_pval
      highlighted << tmp_pval_style
    end
    
    return data_streaming, highlighted
  end
  
  def self.calculate_retention(raw_data, selection)
    data = {}
    cells = []
    
    # Set the static values first
    raw_data.each_with_index do |a,i|      
      cell_num = a['test_cell_id'].to_s
      cells << a['test_cell_id'].to_s
      
      data["cell_#{cell_num}_allocations"] = a['num_allocations'].to_i 
      data["cell_#{cell_num}_pcompletes"] = a['num_period_completes'].to_i
      data["cell_#{cell_num}_currentsubs"] = a['num_allocations'].to_i - a['num_cancels'].to_i
      data["cell_#{cell_num}_periodstarts"] = a['num_period_starts'].to_i
      
      data["cell_#{cell_num}_pretention"] = (a['num_period_completes'].to_f / a['num_period_starts'].to_f)
      data["cell_#{cell_num}_cumretention"] = (data["cell_#{cell_num}_currentsubs"].to_f / data["cell_#{cell_num}_allocations"].to_f)
      
      
      # puts " allocation: " + data["cell_#{cell_num}_allocations"].to_s
      # puts data["cell_#{cell_num}_pcompletes"]
      # puts data["cell_#{cell_num}_currentsubs"] 
      # puts data["cell_#{cell_num}_periodstarts"]
      # 
      # puts data["cell_#{cell_num}_pretention"]
      # puts data["cell_#{cell_num}_cumretention"]
    end
    
    # Set the dynamic values, which can toggle between different test cells
    cells.each_with_index do |cell_num,i|
      data["cell_#{cell_num}_pcombrtn"] = ((data["cell_#{cell_num}_pcompletes"] + data["cell_#{selection[i]}_pcompletes"]).to_f / (data["cell_#{cell_num}_periodstarts"] + data["cell_#{selection[i]}_periodstarts"]).to_f)
      data["cell_#{cell_num}_cumcombrtn"] = ((data["cell_#{cell_num}_currentsubs"] + data["cell_#{selection[i]}_currentsubs"]).to_f / (data["cell_#{cell_num}_allocations"] + data["cell_#{selection[i]}_allocations"]).to_f)
      
      data["cell_#{cell_num}_pzstat"] = Stats.zstat(data["cell_#{cell_num}_pretention"].to_f, data["cell_#{selection[i]}_pretention"].to_f, data["cell_#{cell_num}_pcombrtn"].to_f, data["cell_#{cell_num}_allocations"].to_f, data["cell_#{selection[i]}_allocations"].to_f)
      #data["cell_#{cell_num}_p2zstat"] = Stats.zstat(data["cell_#{cell_num}_p2retention"].to_f, data["cell_#{selection[i]}_p2retention"].to_f, data["cell_#{cell_num}_p2combrtn"].to_f, data["cell_#{cell_num}_p1completes"].to_f, data["cell_#{selection[i]}_p1completes"].to_f)
      #data["cell_#{cell_num}_p3zstat"] = Stats.zstat(data["cell_#{cell_num}_p3retention"].to_f, data["cell_#{selection[i]}_p3retention"].to_f, data["cell_#{cell_num}_p3combrtn"].to_f, data["cell_#{cell_num}_p2completes"].to_f, data["cell_#{selection[i]}_p2completes"].to_f)
      data["cell_#{cell_num}_cumzstat"] = Stats.zstat(data["cell_#{cell_num}_cumretention"].to_f, data["cell_#{selection[i]}_cumretention"].to_f, data["cell_#{cell_num}_cumcombrtn"].to_f, data["cell_#{cell_num}_allocations"].to_f, data["cell_#{selection[i]}_allocations"].to_f)
    
      data["cell_#{cell_num}_ppvalue"] = Stats.pvalue(data["cell_#{cell_num}_pzstat"])
      #data["cell_#{cell_num}_p2pvalue"] = Stats.pvalue(data["cell_#{cell_num}_p2zstat"])
      #data["cell_#{cell_num}_p3pvalue"] = Stats.pvalue(data["cell_#{cell_num}_p3zstat"])
      data["cell_#{cell_num}_cumpvalue"] = Stats.pvalue(data["cell_#{cell_num}_cumzstat"])
    end
    
    return data
  end
  
  def self.render_retention_grid(raw_data, period, selection, cells, options={})
    data_retention = []
    highlighted = []
    
    data = {}
    allocation = {}
    p_complete = {}
    p1_complete = {}
    p2_complete = {}
    p3_complete = {}
    curr_subs = {}
    p_rtn = {}
    p1_rtn = {} 
    p2_rtn = {} 
    p3_rtn = {}
    cum_rtn = {}
    p_combn = {}
    p1_combn = {}
    p2_combn = {}
    p3_combn = {}
    cum_combn = {}
    p_zstat = {}
    p1_zstat = {}
    p2_zstat = {}
    p3_zstat = {}
    cum_zstat = {}
    p_pvalue = {}
    p1_pvalue = {}
    p2_pvalue = {}
    p3_pvalue = {}
    cum_pvalue = {}
    p_rtn_style = {}
    p_pvalue_style = {}
    p1_rtn_style = {}
    p1_pvalue_style = {}
    p2_rtn_style = {}
    p2_pvalue_style = {}
    p3_rtn_style = {}
    p3_pvalue_style = {}
    cum_rtn_style = {}
    cum_pvalue_style = {}
    
    data = self.calculate_retention(raw_data, selection)
    
    # Create array of data (with number formatting) for SlickGrid
    cells.each_with_index do |cell_num,i|
      allocation["metric"] = METRIC_LABELS[:allocations] if i==0
      allocation["cell_id_#{cell_num}"] = number_with_delimiter(data["cell_#{cell_num}_allocations"])
      p_complete["metric"] = period + " Completes"
      p_complete["cell_id_#{cell_num}"] = number_with_delimiter(data["cell_#{cell_num}_pcompletes"])
      # p2_complete["metric"] = METRIC_LABELS[:p2_completes] if i==0
      # p2_complete["cell_id_#{cell_num}"] = number_with_delimiter(data["cell_#{cell_num}_p2completes"])
      # p3_complete["metric"] = METRIC_LABELS[:p3_completes] if i==0
      # p3_complete["cell_id_#{cell_num}"] = number_with_delimiter(data["cell_#{cell_num}_p3completes"])
      curr_subs["metric"] = METRIC_LABELS[:current_subs] if i==0
      curr_subs["cell_id_#{cell_num}"] = number_with_delimiter(data["cell_#{cell_num}_currentsubs"])
      
      p_rtn["metric"] = period + " Retention" if i==0
      p_rtn["cell_id_#{cell_num}"] = number_with_precision(data["cell_#{cell_num}_pretention"]*100, :precision => 1) + "%"
      # p2_rtn["metric"] = METRIC_LABELS[:p2_retention] if i==0
      #  p2_rtn["cell_id_#{cell_num}"] = number_with_precision(data["cell_#{cell_num}_p2retention"]*100, :precision => 1) + "%"
      #  p3_rtn["metric"] = METRIC_LABELS[:p3_retention] if i==0
      #  p3_rtn["cell_id_#{cell_num}"] = number_with_precision(data["cell_#{cell_num}_p3retention"]*100, :precision => 1) + "%"
      cum_rtn["metric"] = METRIC_LABELS[:cumulative_retention]
      cum_rtn["cell_id_#{cell_num}"] = number_with_precision(data["cell_#{cell_num}_cumretention"]*100, :precision => 1) + "%"
      
      p_combn["metric"] = period + " Combined Retention" if i==0
      p_combn["cell_id_#{cell_num}"] = number_with_precision(data["cell_#{cell_num}_pcombrtn"]*100, :precision => 1) + "%"
      # p2_combn["metric"] = METRIC_LABELS[:p2_combn_retention] if i==0
      # p2_combn["cell_id_#{cell_num}"] = number_with_precision(data["cell_#{cell_num}_p2combrtn"]*100, :precision => 1) + "%"
      # p3_combn["metric"] = METRIC_LABELS[:p3_combn_retention] if i==0
      # p3_combn["cell_id_#{cell_num}"] = number_with_precision(data["cell_#{cell_num}_p3combrtn"]*100, :precision => 1) + "%"
      cum_combn["metric"] = METRIC_LABELS[:cumulative_combn_retention] if i==0
      cum_combn["cell_id_#{cell_num}"] = number_with_precision(data["cell_#{cell_num}_cumcombrtn"]*100, :precision => 1) + "%"
      
      p_zstat["metric"] = "Z stat" if i==0
      p_zstat["cell_id_#{cell_num}"] = number_with_precision(data["cell_#{cell_num}_pzstat"], :precision => 2)
      # p2_zstat["metric"] = "Z stat" if i==0
      # p2_zstat["cell_id_#{cell_num}"] = number_with_precision(data["cell_#{cell_num}_p2zstat"], :precision => 2)
      # p3_zstat["metric"] = "Z stat" if i==0
      # p3_zstat["cell_id_#{cell_num}"] = number_with_precision(data["cell_#{cell_num}_p3zstat"], :precision => 2)
      cum_zstat["metric"] = "Z stat" if i==0
      cum_zstat["cell_id_#{cell_num}"] = number_with_precision(data["cell_#{cell_num}_cumzstat"], :precision => 2)
      
      p_pvalue["metric"] = "p-value" if i==0
      p_pvalue["cell_id_#{cell_num}"] = number_with_precision(data["cell_#{cell_num}_ppvalue"], :precision => 3)
      # p2_pvalue["metric"] = "p-value" if i==0
      # p2_pvalue["cell_id_#{cell_num}"] = number_with_precision(data["cell_#{cell_num}_p2pvalue"], :precision => 3)
      # p3_pvalue["metric"] = "p-value" if i==0
      # p3_pvalue["cell_id_#{cell_num}"] = number_with_precision(data["cell_#{cell_num}_p3pvalue"], :precision => 3)
      cum_pvalue["metric"] = "p-value" if i==0
      cum_pvalue["cell_id_#{cell_num}"] = number_with_precision(data["cell_#{cell_num}_cumpvalue"], :precision => 3)
      
      p_rtn_style["cell_id_#{cell_num}"] = highlight_cell(data["cell_#{cell_num}_pzstat"], data["cell_#{cell_num}_ppvalue"])
      # p2_rtn_style["cell_id_#{cell_num}"] = highlight_cell(data["cell_#{cell_num}_p2zstat"], data["cell_#{cell_num}_p2pvalue"])
      # p3_rtn_style["cell_id_#{cell_num}"] = highlight_cell(data["cell_#{cell_num}_p3zstat"], data["cell_#{cell_num}_p3pvalue"])
      cum_rtn_style["cell_id_#{cell_num}"] = highlight_cell(data["cell_#{cell_num}_cumzstat"], data["cell_#{cell_num}_cumpvalue"]) + " text-bold"
      p_pvalue_style["cell_id_#{cell_num}"] = highlight_cell(data["cell_#{cell_num}_pzstat"], data["cell_#{cell_num}_ppvalue"]) + " stats"
      # p2_pvalue_style["cell_id_#{cell_num}"] = highlight_cell(data["cell_#{cell_num}_p2zstat"], data["cell_#{cell_num}_p2pvalue"]) + " stats"
      # p3_pvalue_style["cell_id_#{cell_num}"] = highlight_cell(data["cell_#{cell_num}_p3zstat"], data["cell_#{cell_num}_p3pvalue"]) + " stats"
      cum_pvalue_style["cell_id_#{cell_num}"] = highlight_cell(data["cell_#{cell_num}_cumzstat"], data["cell_#{cell_num}_cumpvalue"]) + " stats"
      cum_rtn_style["metric"] = "text-bold"
      p_pvalue_style["metric"] = "stats"
      # p2_pvalue_style["metric"] = "stats"
      # p3_pvalue_style["metric"] = "stats"
      cum_pvalue_style["metric"] = "stats"
    end
    
    # Each line below represents table rows
    data_retention << allocation
    data_retention << p_complete if options[:debug]=="true"
    # data_retention << p2_complete if options[:debug]=="true"
    # data_retention << p3_complete if options[:debug]=="true"
    # data_retention << curr_subs
    data_retention << p_rtn
    data_retention << p_combn if options[:debug]=="true"
    data_retention << p_zstat if options[:debug]=="true"
    data_retention << p_pvalue
    # data_retention << p2_rtn
    # data_retention << p2_combn if options[:debug]=="true"
    # data_retention << p2_zstat if options[:debug]=="true"
    # data_retention << p2_pvalue
    # data_retention << p3_rtn
    # data_retention << p3_combn if options[:debug]=="true"
    # data_retention << p3_zstat if options[:debug]=="true"
    # data_retention << p3_pvalue
    data_retention << cum_rtn
    data_retention << cum_combn if options[:debug]=="true"
    data_retention << cum_zstat if options[:debug]=="true"
    data_retention << cum_pvalue
    
    # The styles are hard-coded to the rows
    # Change here if row #s change
    # if options[:debug] == "true"
    #   highlighted[5] = p1_rtn_style     
    #   highlighted[8] = p1_pvalue_style
    #   highlighted[9] = p2_rtn_style     
    #   highlighted[12] = p2_pvalue_style
    #   highlighted[13] = p3_rtn_style
    #   highlighted[16] = p3_pvalue_style
    #   highlighted[17] = cum_rtn_style
    #   highlighted[20] = cum_pvalue_style
    # else
      highlighted[1] = p_rtn_style    
      highlighted[2] = p_pvalue_style        
      highlighted[3] = cum_rtn_style
      highlighted[4] = cum_pvalue_style
    # end
    
    return data_retention, highlighted
  end
  
end