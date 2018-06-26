class CreateViewIndexCoFiles < ActiveRecord::Migration[5.1]
    def self.up
      execute "
        create view index_co_files as
        select * from (
            select u.id as u_id, f.id as f_id, 'articles' as f_type, f.name as f_name, f.release_id, f.dir_id, f.dir_type, s.id as seed_id, s.editors_count, r.name as role, r.dir_id as r_dir, r.created_at as r_created_at, f.created_at as f_created_at, f.updated_at as f_updated_at, marked_u_ids from index_users as u, index_articles as f, index_file_seeds as s, index_role_edits as r where r.user_id = u.id and r.is_deleted = false and s.id = r.file_seed_id and f.file_seed_id = s.id and f.is_deleted = false
          union
            select u.id as uid, f.id, 'corpuses' , f.name, f.release_id, f.dir_id, f.dir_type, s.id , s.editors_count, r.name, r.dir_id, r.created_at, f.created_at, f.updated_at, marked_u_ids from index_users as u, index_corpus as f, index_file_seeds as s, index_role_edits as r where r.user_id = u.id and r.is_deleted = false and s.id = r.file_seed_id and f.file_seed_id = s.id and f.is_deleted = false
          union
            select u.id as uid, f.id, 'folders', f.name, null, f.dir_id, f.dir_type, s.id, s.editors_count, r.name, r.dir_id, r.created_at, f.created_at, f.updated_at, marked_u_ids from index_users as u, index_folders as f, index_file_seeds as s, index_role_edits as r where r.user_id = u.id and r.is_deleted = false and s.id = r.file_seed_id and f.file_seed_id = s.id and f.is_deleted = false
        ) files;"
    end

    def self.down
      execute "drop view index_co_files;"
    end
end
