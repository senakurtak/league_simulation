class Match
  attr_accessor :home_team, :away_team, :week, :home_goals, :away_goals

  # Initialize a new match with home and away teams and the week number
  def initialize(home_team, away_team, week)
    @home_team = home_team
    @away_team = away_team
    @week = week
    @home_goals = 0
    @away_goals = 0
  end
end
