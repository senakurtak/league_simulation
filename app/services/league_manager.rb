class LeagueManager
  attr_reader :teams, :matches

# Initialize the league manager, setting up teams and matches
  def initialize
    @teams = []
    @matches = []
    initialize_league
    generate_matches
  end

  # Create and add teams to the league
  def initialize_league
    team1 = Team.new("Chelsea", 10)
    team2 = Team.new("Arsenal", 8)
    team3 = Team.new("Manchester City", 6)
    team4 = Team.new("Liverpool", 4)
    team5 = Team.new("Everton", 2)
    team6 = Team.new("Newcastle", 3)
    team7 = Team.new("Sheffield Utd", 6)
    team8 = Team.new("Bournemouth", 4)

    add_team(team1)
    add_team(team2)
    add_team(team3)
    add_team(team4)
    add_team(team5)
    add_team(team6)
    add_team(team7)
    add_team(team8)
  end

# Reset the league to start a new season
  def reset_league
    @teams.each do |team|
      team.points = 0
      team.goals_scored = 0
      team.goals_conceded = 0
      team.wins = 0
      team.draws = 0
      team.losses = 0
    end
    @matches = []
    generate_matches
  end

# Add a team to the league
  def add_team(team)
    @teams << team
  end

# Generate the schedule for the matches
  def generate_matches
    team_pairs = @teams.combination(2).to_a
    team_pairs.each_with_index do |pair, index|
      create_match(pair[0], pair[1], (index / 4) + 1) # limitation as 2 matches per week
    end
  end

# Create a match for a given week
  def create_match(home_team, away_team, week)
    match = Match.new(home_team, away_team, week)
    @matches << match
  end
end
