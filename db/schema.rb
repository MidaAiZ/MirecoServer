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

ActiveRecord::Schema.define(version: 20170616163254) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "apis", force: :cascade do |t|
    t.string   "path"
    t.string   "method"
    t.string   "tag"
    t.string   "prms"
    t.string   "response"
    t.string   "usage"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "index_articles", force: :cascade do |t|
    t.string   "name"
    t.text     "content"
    t.string   "tag"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.boolean  "is_shown"
    t.boolean  "is_marked"
    t.boolean  "is_deleted",   default: false
    t.integer  "file_seed_id"
    t.integer  "dir_id"
    t.string   "dir_type"
    t.jsonb    "info",         default: {}
  end

  add_index "index_articles", ["dir_type", "dir_id"], name: "index_article_on_dir_type_id", using: :btree
  add_index "index_articles", ["file_seed_id"], name: "index_articles_on_file_seed_id", using: :btree
  add_index "index_articles", ["info"], name: "index_corpus_on_info", using: :gin
  add_index "index_articles", ["name"], name: "index_articles_on_name", using: :btree
  add_index "index_articles", ["tag"], name: "index_articles_on_tag", using: :btree

  create_table "index_comment_replies", force: :cascade do |t|
    t.integer  "comment_id"
    t.integer  "user_id"
    t.string   "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "index_comment_replies", ["comment_id"], name: "index_comment_reply_on_com_id", using: :btree
  add_index "index_comment_replies", ["user_id"], name: "index_comment_reply_on_user_id", using: :btree

  create_table "index_comments", force: :cascade do |t|
    t.string   "content"
    t.integer  "user_id"
    t.integer  "resource_id"
    t.string   "resource_type"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "index_comments", ["resource_type", "resource_id"], name: "index_comment_on_name_rsc", using: :btree
  add_index "index_comments", ["user_id"], name: "index_comment_on_user_id", using: :btree

  create_table "index_corpus", force: :cascade do |t|
    t.string   "name"
    t.string   "tag"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.boolean  "is_shown"
    t.boolean  "is_marked"
    t.boolean  "is_deleted",   default: false
    t.integer  "file_seed_id"
    t.integer  "dir_id"
    t.string   "dir_type"
    t.jsonb    "info",         default: {}
  end

  add_index "index_corpus", ["dir_type", "dir_id"], name: "index_corpus_on_dir_type_id", using: :btree
  add_index "index_corpus", ["file_seed_id"], name: "index_corpus_on_file_seed_id", using: :btree
  add_index "index_corpus", ["info"], name: "index_corpus_on_files", using: :gin
  add_index "index_corpus", ["name"], name: "index_corpus_on_name", using: :btree
  add_index "index_corpus", ["tag"], name: "index_corpus_on_tag", using: :btree

  create_table "index_edit_comments", force: :cascade do |t|
    t.integer  "resource_id"
    t.string   "resource_type"
    t.string   "content"
    t.jsonb    "replies",       default: {}
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.integer  "user_id"
    t.string   "hash_key"
  end

  add_index "index_edit_comments", ["hash_key"], name: "index_edit_comment_on_hash_key", using: :btree
  add_index "index_edit_comments", ["replies"], name: "index_edit_comments_on_replys", using: :gin
  add_index "index_edit_comments", ["resource_id", "resource_type"], name: "index_edit_comments_on_resource", using: :btree
  add_index "index_edit_comments", ["user_id"], name: "index_edit_comment_on_user_id", using: :btree

  create_table "index_file_seeds", force: :cascade do |t|
    t.integer "root_file_id"
    t.string  "root_file_type"
    t.integer "editors_count",  default: 0
    t.boolean "is_deleted",     default: false
  end

  add_index "index_file_seeds", ["root_file_type", "root_file_id"], name: "index_file_seed_on_file_type_id", using: :btree
  add_index "index_file_seeds", ["root_file_type", "root_file_id"], name: "index_file_seeds_on_root_file_type_id", using: :btree

  create_table "index_folders", force: :cascade do |t|
    t.string   "name"
    t.string   "tag"
    t.boolean  "is_shown"
    t.boolean  "is_marked"
    t.boolean  "is_deleted",   default: false
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.integer  "file_seed_id"
    t.integer  "dir_id"
    t.string   "dir_type"
    t.jsonb    "info",         default: {}
  end

  add_index "index_folders", ["dir_type", "dir_id"], name: "index_folder_on_dir_type_id", using: :btree
  add_index "index_folders", ["file_seed_id"], name: "index_folders_on_file_seed_id", using: :btree
  add_index "index_folders", ["info"], name: "index_folder_on_files", using: :gin
  add_index "index_folders", ["name"], name: "index_folders_on_name", using: :btree

  create_table "index_history_articles", force: :cascade do |t|
    t.string   "name"
    t.text     "content"
    t.string   "tag"
    t.integer  "article_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "index_role_edits", force: :cascade do |t|
    t.string   "name"
    t.string   "editor_name"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "file_seed_id"
    t.boolean  "is_root",      default: true
    t.jsonb    "info"
    t.integer  "dir_id"
    t.string   "dir_type"
  end

  add_index "index_role_edits", ["dir_id", "dir_type"], name: "index_role_edit_on_dir_id_type", using: :btree
  add_index "index_role_edits", ["file_seed_id"], name: "index_role_edits_on_file_seed_id", using: :btree
  add_index "index_role_edits", ["info"], name: "index_roles_on_info", using: :gin
  add_index "index_role_edits", ["name"], name: "index_role_edit_on_name", using: :btree
  add_index "index_role_edits", ["user_id"], name: "index_role_edit_on_user_id", using: :btree
  add_index "index_role_edits", ["user_id"], name: "index_trashes_on_user_id", using: :btree

  create_table "index_thumb_ups", force: :cascade do |t|
    t.integer  "resource_id"
    t.string   "resource_type"
    t.jsonb    "thumbs",        default: {}
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.integer  "thumbs_count",  default: 0
  end

  add_index "index_thumb_ups", ["resource_id", "resource_type"], name: "index_thumb_up_on_resource", using: :btree
  add_index "index_thumb_ups", ["thumbs"], name: "index_thumb_up_on_thumbs", using: :gin

  create_table "index_trashes", force: :cascade do |t|
    t.integer  "file_seed_id"
    t.integer  "user_id"
    t.integer  "files_count"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.integer  "file_id"
    t.string   "file_type"
    t.string   "file_name"
  end

  add_index "index_trashes", ["file_id", "file_type"], name: "index_trashes_on_file_type_id", using: :btree
  add_index "index_trashes", ["file_seed_id"], name: "index_index_trashes_on_file_seed_id", using: :btree
  add_index "index_trashes", ["user_id"], name: "index_index_trashes_on_user_id", using: :btree

  create_table "index_users", force: :cascade do |t|
    t.string   "number"
    t.string   "password_digest"
    t.string   "name"
    t.string   "phone"
    t.string   "email"
    t.string   "gender"
    t.date     "birthday"
    t.string   "address"
    t.boolean  "forbidden"
    t.string   "avatar"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.string   "intro"
  end

  add_index "index_users", ["email"], name: "index_users_on_email", using: :btree
  add_index "index_users", ["number"], name: "index_users_on_number", using: :btree
  add_index "index_users", ["phone"], name: "index_users_on_phone", using: :btree

end
