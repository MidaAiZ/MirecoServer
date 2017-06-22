class DownloadController < ApplicationController
  protect_from_forgery except: :download

  def download
    # redirect_to('/404') && return if @file.nil?
    file_name = params[:filename].split("/").first
    file_path = "#{Rails.root}/public/uploads/#{file_name}"
    file_name += ".#{params[:format]}" if params[:format]
    send_file(file_path, filename: file_name)
    # rescue
    #     redirect_to '/404'
  end

  private

  def set_file
    @file = Manage::Fileworker.find(params[:id])
  end
end
