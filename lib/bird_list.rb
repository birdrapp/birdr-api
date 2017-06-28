class BirdList
  include Enumerable

  def initialize(birds, sightings)
    @seen_bird_ids = sightings.pluck(:bird_id).to_set
    @birds = birds
  end

  def each(&block)
    @birds.each do |bird|
      block.call(BirdList::Item.new(bird, bird.id.in?(@seen_bird_ids)))
    end
  end

  class Item
    attr_reader :bird

    def initialize(bird, seen)
      @bird = bird
      @seen = seen
    end

    def seen?
      @seen
    end

  end
end
