require 'bird_list'

class BirdListsController < ApplicationController
  def show
    bird = Bird.all
    user_sightings = current_user.sightings

    @bird_list = BirdList.new(bird, user_sightings)
  end
end
