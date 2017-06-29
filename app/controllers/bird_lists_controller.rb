require 'bird_list'

class BirdListsController < ApplicationController
  def show
    birds = Bird.all
    user_sightings = current_user.sightings

    @bird_list = BirdList.new(birds, user_sightings)
  end
end
