# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
u = Index::User.first
1.times do
  t = Time.now
  3_000_000.times do |i|
    lo = i % 3
    ActiveRecord::Base.transaction do # 出错将回滚
      case lo
      when 0
        a = Index::Workspace::Article.new name: [*('A'..'z')].sample(10).join, content: [*('A'..'z'), *(0..9)].sample(100).join * 100
      when 1
        a = Index::Workspace::Folder.new name: [*('A'..'z')].sample(10).join
      when 2
        a = Index::Workspace::Corpus.new name: [*('A'..'z')].sample(10).join
      end
      a.save
      f = a.build_file_seed
      f.root_file = a
      f.save
      a.save
      u.add_edit_role :own, a
      puts '这是第' + i.to_s + '个'
    end
  end
  puts Time.now - t
end

# 超级无敌的初始化测试数据
# 10.times do |j|
#     t = j % 3
#     case t
#     when 0
#         100.times do |i|
#         j += 1
#         i += 1
#         fs = Index::Workspace::FileSeed.create
#         a = Index::Workspace::Article.offset(i*j*10).first
#         a.file_seed = fs
#         a.is_inner = false
#         a.father_corpus = nil
#         a.father_corpus = nil
#         fs.root_file = a
#         a.save
#         fs.update(files_count: 1)
#         puts "完成第" + j.to_s + "轮第" + i.to_s + "循环"
#         end
#     when 1
#         100.times do |i|
#             i += 1
#             fs = Index::Workspace::FileSeed.create
#             a1 = Index::Workspace::Article.offset(i*j*10).first
#             a2 = Index::Workspace::Article.offset(i*j*17).first
#             a3 = Index::Workspace::Article.offset(i*j*14).first
#             a1.father_folder = a1.father_corpus =nil
#             a2.father_folder = a2.father_corpus =nil
#             a3.father_folder = a3.father_corpus =nil
#             c = Index::Workspace::Corpus.offset(i*j*10).first
#             c.file_seed = fs
#             a1.file_seed = fs
#             a2.file_seed = fs
#             a3.file_seed = fs
#             fs.root_file = c
#             c.son_articles << [a1, a2, a3]
#             c.father_folder = nil
#             c.is_inner = false
#             a1.is_inner = true
#             a2.is_inner = true
#             a3.is_inner = true
#             a1.save
#             a2.save
#             a3.save
#             c.save
#             fs.update(files_count: 4)
#             puts "完成第" + j.to_s + "轮第" + i.to_s + "循环"
#         end
#
#     when 2
#         100.times do |i|
#             i += 1
#             fs = Index::Workspace::FileSeed.create
#             a = Index::Workspace::Article.offset(i*j*10).first
#             a1 = Index::Workspace::Article.offset(i*j*10).first
#             a2 = Index::Workspace::Article.offset(i*j*17).first
#             a3 = Index::Workspace::Article.offset(i*j*14).first
#             f =Index::Workspace::Folder.offset(i*j*10).first
#             f1 =Index::Workspace::Folder.offset(i*j*7*17).first
#             c = Index::Workspace::Corpus.offset(i*j*10).first
#             f.file_seed = fs
#             f1.file_seed = fs
#             c.file_seed = fs
#             a.file_seed = fs
#             a1.file_seed = fs
#             a2.file_seed = fs
#             a3.file_seed = fs
#             a.father_corpus = c
#             a1.father_folder = f1
#             a2.father_folder = f
#             a3.father_corpus = c
#             c.father_folder = f
#             f.father_folder = nil
#             f1.father_folder = f
#             f.is_inner = false
#             fs.root_file = f
#             f1.is_inner = true
#             c.is_inner = true
#             a.is_inner = true
#             a1.is_inner = true
#             a2.is_inner = true
#             a3.is_inner = true
#             a.save
#             a1.save
#             a2.save
#             a3.save
#             f1.save
#             f.save
#             c.save
#             fs.update(files_count: 7)
#             puts "完成第" + j.to_s + "轮第" + i.to_s + "循环"
#         end
#     end
# end
