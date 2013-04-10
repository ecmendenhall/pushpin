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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20130410043518) do

  create_table "comments", force: true do |t|
    t.text     "content"
    t.integer  "user_id"
    t.integer  "link_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "comments", ["user_id", "created_at", "link_id"], name: "index_comments_on_user_id_and_created_at_and_link_id"

  create_table "links", force: true do |t|
    t.string   "url"
    t.string   "title"
    t.text     "description"
    t.datetime "datetime"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "links", ["url"], name: "index_links_on_url"
  add_index "links", ["user_id", "created_at"], name: "index_links_on_user_id_and_created_at"

  create_table "relationships", force: true do |t|
    t.integer  "follower_id"
    t.integer  "followed_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "relationships", ["followed_id"], name: "index_relationships_on_followed_id"
  add_index "relationships", ["follower_id", "followed_id"], name: "index_relationships_on_follower_id_and_followed_id", unique: true
  add_index "relationships", ["follower_id"], name: "index_relationships_on_follower_id"

  create_table "users", force: true do |t|
    t.string   "name"
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "password_digest"
    t.string   "remember_token"
    t.boolean  "admin",                      default: false
    t.string   "pinboard"
    t.string   "api_token"
    t.boolean  "pinboard_confirmed"
    t.string   "pinboard_confirmation_code"
    t.string   "email_confirmation_code"
    t.boolean  "email_confirmed"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["pinboard"], name: "index_users_on_pinboard"
  add_index "users", ["remember_token"], name: "index_users_on_remember_token"

end
