class Team
  attr_accessor :name, :strength, :points, :goals_scored, :goals_conceded, :wins, :draws, :losses

  # Initialize a new team with its name and strength
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

  # Calculate the goal difference for the team
  def goal_difference
    @goals_scored - @goals_conceded
  end
end
