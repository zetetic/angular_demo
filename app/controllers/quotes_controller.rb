require 'uri'

class QuotesController < ApplicationController
  def index
    render :json => retrieve_quotes
  end

  protected

  def retrieve_quotes
    base_url    = "http://query.yahooapis.com/v1/public/yql"
    querystring = "q=select * from yahoo.finance.quotes where symbol in "
    symbols     = params[:symbols] || [""]
    querystring += "(#{symbols.map {|s| "\"#{s}\""}.join(",")})"
    querystring += "&env=http://datatables.org/alltables.env&format=json"
    url         = URI.encode([base_url, querystring].join("?"))
    response    = HTTParty.get(url)
    if response["query"]["count"].to_i.zero?
      []
    else
      Array.wrap(response["query"]["results"]["quote"])
    end
  end
end
