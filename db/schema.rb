# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120307193457) do

  create_table "streaming_agg", :force => true do |t|
    t.integer "test_id",                                :null => false
    t.string  "test_name",                              :null => false
    t.integer "test_cell_id",              :limit => 2, :null => false
    t.string  "test_cell_name",                         :null => false
    t.string  "period",                                 :null => false
    t.date    "allocation_date",                        :null => false
    t.string  "allocation_region",                      :null => false
    t.string  "initial_plan",                           :null => false
    t.string  "major_device_category",                  :null => false
    t.date    "as_of_vhs_date",                         :null => false
    t.integer "num_allocations_ge_0_hrs",               :null => false
    t.integer "num_allocations_ge_15_min",              :null => false
    t.integer "num_allocations_ge_1_hr",                :null => false
    t.integer "num_allocations_ge_5_hrs",               :null => false
    t.integer "num_allocations_ge_10_hrs",              :null => false
    t.integer "num_allocations_ge_20_hrs",              :null => false
    t.integer "num_allocations_ge_40_hrs",              :null => false
    t.integer "num_allocations_ge_80_hrs",              :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "email",                            :default => "", :null => false
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                    :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "name"
    t.string   "username",                         :default => "", :null => false
    t.integer  "company_id"
    t.integer  "user_type",           :limit => 2, :default => 1,  :null => false
    t.datetime "created_at",                                       :null => false
    t.datetime "updated_at",                                       :null => false
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["username"], :name => "index_users_on_username", :unique => true

end
