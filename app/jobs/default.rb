# class Email < ApplicationJob
#   include Sidekiq::Worker
#   include Sidetiq::Schedulable
#
#   # self.queue_adapter = :sidekiq
#   queues_as :default
#
#   # before_enqueue :foo1
#   # around_enqueue :foo2
#   # after_enqueue :foo3
#   # before_perform :foo4
#   # around_perform :foo5
#   # after_perform :foo6
#
#   recurrence do
#     # minutely(1)
#     secondly(1)
#   end
#
#   def perform editor, file, user
#     puts '测试'
#   end
# end
