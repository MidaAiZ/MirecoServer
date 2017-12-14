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

ActiveRecord::Schema.define(version: 20171213174533) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "apis", id: :serial, force: :cascade do |t|
    t.string "path"
    t.string "method"
    t.string "tag"
    t.string "prms"
    t.string "response"
    t.string "usage"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "index_article_contents", force: :cascade do |t|
    t.bigint "article_id"
    t.bigint "last_update_user_id"
    t.datetime "last_updated_at"
    t.string "text", default: ""
  end

  create_table "index_articles", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "tag"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_shown"
    t.boolean "is_deleted", default: false
    t.integer "file_seed_id"
    t.integer "dir_id"
    t.string "dir_type"
    t.jsonb "info", default: {}
    t.integer "marked_u_ids", array: true
    t.index ["dir_type", "dir_id"], name: "index_article_on_dir_type_id"
    t.index ["file_seed_id"], name: "index_articles_on_file_seed_id"
    t.index ["info"], name: "index_corpus_on_info", using: :gin
    t.index ["name"], name: "index_articles_on_name"
    t.index ["tag"], name: "index_articles_on_tag"
  end

  create_table "index_comment_replies", id: :serial, force: :cascade do |t|
    t.integer "comment_id"
    t.integer "user_id"
    t.string "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "info"
    t.index ["comment_id"], name: "index_comment_reply_on_com_id"
    t.index ["info"], name: "index_comment_replies_on_info", using: :gin
    t.index ["user_id"], name: "index_comment_reply_on_user_id"
  end

  create_table "index_comments", id: :serial, force: :cascade do |t|
    t.string "content"
    t.integer "user_id"
    t.integer "resource_id"
    t.string "resource_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "info"
    t.index ["info"], name: "index_comments_on_info", using: :gin
    t.index ["resource_type", "resource_id"], name: "index_comment_on_name_rsc"
    t.index ["user_id"], name: "index_comment_on_user_id"
  end

  create_table "index_corpus", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "tag"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_shown"
    t.boolean "is_deleted", default: false
    t.integer "file_seed_id"
    t.integer "dir_id"
    t.string "dir_type"
    t.jsonb "info", default: {}
    t.integer "marked_u_ids", array: true
    t.index ["dir_type", "dir_id"], name: "index_corpus_on_dir_type_id"
    t.index ["file_seed_id"], name: "index_corpus_on_file_seed_id"
    t.index ["info"], name: "index_corpus_on_files", using: :gin
    t.index ["name"], name: "index_corpus_on_name"
    t.index ["tag"], name: "index_corpus_on_tag"
  end

  create_table "index_edit_comment_replies", force: :cascade do |t|
    t.bigint "edit_comment_id"
    t.bigint "user_id"
    t.string "content"
  end

  create_table "index_edit_comments", id: :serial, force: :cascade do |t|
    t.integer "resource_id"
    t.string "resource_type"
    t.string "content"
    t.jsonb "replies", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.string "hash_key"
    t.index ["hash_key"], name: "index_edit_comment_on_hash_key"
    t.index ["replies"], name: "index_edit_comments_on_replys", using: :gin
    t.index ["resource_id", "resource_type"], name: "index_edit_comments_on_resource"
    t.index ["user_id"], name: "index_edit_comment_on_user_id"
  end

  create_table "index_file_seeds", id: :serial, force: :cascade do |t|
    t.integer "root_file_id"
    t.string "root_file_type"
    t.integer "editors_count", default: 0
    t.index ["root_file_type", "root_file_id"], name: "index_file_seed_on_file_type_id"
    t.index ["root_file_type", "root_file_id"], name: "index_file_seeds_on_root_file_type_id"
  end

  create_table "index_folders", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "tag"
    t.boolean "is_shown"
    t.boolean "is_deleted", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "file_seed_id"
    t.integer "dir_id"
    t.string "dir_type"
    t.jsonb "info", default: {}
    t.integer "marked_u_ids", array: true
    t.index ["dir_type", "dir_id"], name: "index_folder_on_dir_type_id"
    t.index ["file_seed_id"], name: "index_folders_on_file_seed_id"
    t.index ["info"], name: "index_folder_on_files", using: :gin
    t.index ["name"], name: "index_folders_on_name"
  end

  create_table "index_history_articles", id: :serial, force: :cascade do |t|
    t.string "name"
    t.text "content"
    t.string "tag"
    t.integer "article_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "index_mark_records", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "file_seed_id"
    t.string "file_type"
    t.bigint "file_id"
    t.index ["file_id", "file_type"], name: "index_mark_records_on_file_id_type"
    t.index ["file_seed_id"], name: "index_mark_records_on_file_seed_id"
    t.index ["user_id"], name: "index_mark_records_on_user_id"
  end

  create_table "index_role_edits", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "nickname"
    t.integer "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "file_seed_id"
    t.jsonb "info"
    t.integer "dir_id"
    t.string "dir_type"
    t.boolean "is_deleted", default: false
    t.index ["dir_id", "dir_type"], name: "index_role_edit_on_dir_id_type"
    t.index ["file_seed_id"], name: "index_role_edits_on_file_seed_id"
    t.index ["info"], name: "index_roles_on_info", using: :gin
    t.index ["name"], name: "index_role_edit_on_name"
    t.index ["user_id"], name: "index_role_edit_on_user_id"
    t.index ["user_id"], name: "index_trashes_on_user_id"
  end

  create_table "index_thumb_ups", id: :serial, force: :cascade do |t|
    t.integer "resource_id"
    t.string "resource_type"
    t.jsonb "thumbs", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "thumbs_count", default: 0
    t.index ["resource_id", "resource_type"], name: "index_thumb_up_on_resource"
    t.index ["thumbs"], name: "index_thumb_up_on_thumbs", using: :gin
  end

  create_table "index_trashes", id: :serial, force: :cascade do |t|
    t.integer "file_seed_id"
    t.integer "user_id"
    t.integer "files_count"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "file_id"
    t.string "file_type"
    t.string "file_name"
    t.index ["file_id", "file_type"], name: "index_trashes_on_file_type_id"
    t.index ["file_seed_id"], name: "index_index_trashes_on_file_seed_id"
    t.index ["user_id"], name: "index_index_trashes_on_user_id"
  end

  create_table "index_users", id: :serial, force: :cascade do |t|
    t.string "number"
    t.string "password_digest"
    t.string "name"
    t.string "phone"
    t.string "email"
    t.string "gender"
    t.date "birthday"
    t.string "address"
    t.boolean "forbidden"
    t.string "avatar"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "intro"
    t.index ["email"], name: "index_users_on_email"
    t.index ["number"], name: "index_users_on_number"
    t.index ["phone"], name: "index_users_on_phone"
  end

end
