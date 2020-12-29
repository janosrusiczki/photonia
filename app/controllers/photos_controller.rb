class PhotosController < ApplicationController
  include Pagy::Backend

  def index
    photos = if params[:q].present?
      Photo.search(params[:q])
    else
      Photo.all.order(date_taken: :desc)
    end
    @pagy, @photos = pagy(photos)
  end

  def show
    @photo = Photo.friendly.find(params[:id])
    @tags = @photo.tags.not_tagged_by_rekognition
    @rekognition_tags = @photo.tags.tagged_by_rekognition
  end

  def update
    @photo = Photo.friendly.find(params[:id])
    authorize @photo
    @photo.update(photo_params)
  end

  private

  def photo_params
    params.require(:photo).permit(:name, :description)
  end
end
