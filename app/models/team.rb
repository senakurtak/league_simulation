class Team
  attr_accessor :name, :strength, :points, :goals_scored, :goals_conceded, :wins, :draws, :losses

  def initialize(name, strength)
    @name = name
    @strength = strength
    @points = 0
    @goals_scored = 0
    @goals_conceded = 0
    @wins = 0
    @draws = 0
    @losses = 0
  end

  def goal_difference
    @goals_scored - @goals_conceded
  end
end
