class Team
  attr_accessor :name, :strength, :points, :goals_scored, :goals_conceded

  def initialize(name, strength)
    @name = name
    @strength = strength
    @points = 0
    @goals_scored = 0
    @goals_conceded = 0
  end
end
