class SightingsController < ApplicationController
  rescue_from ActiveRecord::RecordNotUnique, with: :duplicate_sighting

  def create
    sighting = Sighting.new({ user_id: current_user.id, bird_id: params[:bird_id] })
    if sighting.save
      render json: sighting, status: 201
    else
      render json: { errors: sighting.errors.messages }, status: 422
    end
  end

  def destroy
    sighting = Sighting.find params[:id]
    if sighting.user == current_user
      sighting.destroy
    else
      head 401
    end
  end

  private

  def duplicate_sighting
    render json: { errors: { bird_id: ["bird already in list of sightings"] }}, status: 422
  end
end
