# Global Constants
METRIC_LABELS = {
  :p1_completes => "# of P1 Completes",
  :p2_completes => "# of P2 Completes",
  :p3_completes => "# of P3 Completes",
  :p4_completes => "# of P4 Completes",
  :allocations => "# of Allocations",
  :current_subs => "# of Current Subs",
  :p1_retention => "P1 Retention",
  :p2_retention => "P2 Retention",
  :p3_retention => "P3 Retention",
  :p4_retention => "P4 Retention",
  :p1_comp_retention => "P1 Comparison Retention",
  :p2_comp_retention => "P2 Comparison Retention",
  :p3_comp_retention => "P3 Comparison Retention",
  :p4_comp_retention => "P4 Comparison Retention",
  :p1_combn_retention => "P1 Combined Retention",
  :p2_combn_retention => "P2 Combined Retention",
  :p3_combn_retention => "P3 Combined Retention",
  :p4_combn_retention => "P4 Combined Retention",
  :cumulative_retention => "Cumulative Retention",
  :cumulative_combn_retention => "Combined Retention"
}.freeze

STREAMING_METRICS = {
  :percent_0h => "% Allocation view > 0 hr",
  :percent_1h => "% Allocation view >= 1 hr",
  :percent_5h => "% Allocation view >= 5 hrs",
  :percent_10h => "% Allocation view >= 10 hrs",
  :percent_20h => "% Allocation view >= 20 hrs",
  :percent_40h => "% Allocation view >= 40 hrs",
  :percent_80h => "% Allocation view >= 80 hrs"
}.freeze

# Key = URL parameter, Value = mapping to content within data
REGION_DATA_MAP = {
  :br => "'Brazil'",
  :ca => "'Canada'",
  :latam => "'Latin America - Other','Brazil','Mexico'",
  :mx => "'Mexico'",
  :us => "'United States'",
  :ukie => "'UK/IE'",
  :all => "'United States','UK/IE','Mexico','Latin America - Other','Canada','Brazil'"
}.freeze

REGION_LABELS = {
  :ca => "CA",
  :latam => "LatAm",
  :us => "US",
  :ukie => "UK/IE",
  :all => "All Regions"
}.freeze

PLAN_DATA_MAP = {
  :streaming => "'Streaming Only'",
  :hybrid => "'Hybrid'",
  :all => "'Streaming Only','DVD Only','Hybrid'"
}.freeze

PLAN_LABELS = {
  :all => "All Plans",
  :streaming => "Streaming Only",
  :hybrid => "Hybrid"
}.freeze

PERIOD_DATA_MAP = {
  :p1 => "P1",
  :p2 => "P2",
  :p3 => "P3",
  :p1p2 => "P1+P2",
  :p1p2p3 => "P1+P2+P3",
  #:recent => "P1+P2+P3"
  :recent => "P1"
}.freeze

PERIOD_LABELS = {
  :p1 => "P1 Only",
  :p2 => "P2 Only",
  :p3 => "P3 Only",
  :p1p2 => "P1+P2",
  :p1p2p3 => "P1+P2+P3",
  :recent => "Most Recent"
}.freeze

DEVICE_DATA_MAP = {
  :mobile => "'Mobile'",
  :other => "'Other CE','STB','Xbox'",
  :pcmac => "'PC/Mac'",
  :ps3 => "'PS3'",
  :wii => "'Wii'",
  :tablet => "'Tablet'",
  :overall => "'Other CE','STB','Xbox','Mobile','PC/Mac','PS3','Wii','Tablet'"
}.freeze