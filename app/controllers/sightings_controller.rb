class SightingsController < ApplicationController
  def create
    @sighting = Sighting.new({ user_id: current_user.id, bird_id: params[:bird_id] })
    if @sighting.save
      render status: 201
    else
      render json: { errors: @sighting.errors.messages }, status: 422
    end
  end

  def destroy
    @sighting = Sighting.find params[:id]
    if @sighting.user == current_user
      @sighting.destroy
    else
      head 401
    end
  end
end
