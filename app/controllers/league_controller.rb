class LeagueController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:simulate_week, :simulate_all]

  # Initialize the league and matches when the controller is created
  def initialize
    super
    @league_manager = LeagueManager.new
    @match_simulator = MatchSimulator.new(@league_manager)
  end

  # Display the initial league table and championship predictions
  def index
    session[:current_week] ||= 0
    @statistics_calculator = StatisticsCalculator.new(@league_manager.teams, @league_manager.matches, session[:current_week])
    @league_table = @statistics_calculator.render_league_table
    @championship_predictions = @statistics_calculator.render_championship_predictions
  end

  # Simulate matches for one week and update the league table
  def simulate_week
    if session[:current_week] < 8
      session[:current_week] += 1
    else
      @league_manager.reset_league
      session[:current_week] = 1
    end
    @match_simulator.simulate_matches_for_week(session[:current_week])
    @statistics_calculator = StatisticsCalculator.new(@league_manager.teams, @league_manager.matches, session[:current_week])
    render json: {
      league_table: @statistics_calculator.render_league_table,
      championship_predictions: @statistics_calculator.render_championship_predictions
    }
  end

  # Simulate matches for all weeks (8 week) until the end of the season
  def simulate_all
    while session[:current_week] < 8
      session[:current_week] += 1
      @match_simulator.simulate_matches_for_week(session[:current_week])
    end
    if session[:current_week] >= 8
      @league_manager.reset_league
      session[:current_week] = 1
    end
    @statistics_calculator = StatisticsCalculator.new(@league_manager.teams, @league_manager.matches, session[:current_week])
    render json: {
      league_table: @statistics_calculator.render_league_table,
      championship_predictions: @statistics_calculator.render_championship_predictions
    }
  end
end
