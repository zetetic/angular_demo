class PreferencesController < ApplicationController

  # Cheating here. There should be a user account and an assocation for the preference.
  # We just keep a single list, creating if it does not exist.
  def index
    render :json => (Preference.first.try(:symbols) || [])
  end

  def create
    prefs = Preference.first || Preference.create!(symbols: '[]')
    prefs.symbols = params[:symbols]
    prefs.save!
    head :ok
  end

end
