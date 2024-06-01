class Match
  attr_accessor :home_team, :away_team, :home_goals, :away_goals, :week

  def initialize(home_team, away_team, week)
    @home_team = home_team
    @away_team = away_team
    @week = week
    @home_goals = 0
    @away_goals = 0
  end
end
