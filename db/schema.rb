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

ActiveRecord::Schema.define(:version => 20110819022901) do

  create_table "domains", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "nads", :force => true do |t|
    t.string   "outboundlink"
    t.string   "imgurl"
    t.string   "head"
    t.string   "caption"
    t.integer  "approved"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "domain_id"
  end

  create_table "relationships", :force => true do |t|
    t.integer  "debtor_id"
    t.integer  "creditor_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "relationships", ["creditor_id"], :name => "index_relationships_on_creditor_id"
  add_index "relationships", ["debtor_id"], :name => "index_relationships_on_debtor_id"

  create_table "views", :force => true do |t|
    t.integer  "nad_id"
    t.integer  "viewedon"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
