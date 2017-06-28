class BirdsController < ApplicationController

  def create
    @bird = Bird.new bird_params

    if @bird.save
      render status: 201
    else
      render json: { errors: @bird.errors }, status: 422
    end
  end

  private

  def bird_params
    params.permit(:common_name, :scientific_name, :sort_order)
  end

end
