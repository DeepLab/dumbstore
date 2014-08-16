# encoding: utf-8

require 'forecast_io'
require 'geocoder'

class Weather < Dumbstore::App
  name 'Weather'
  author 'Allison Burtch'
  author_url 'http://www.allisonburtch.net/'
  description <<-DESCRIPTION
  Forecasts the weather at the given location. For example, text <code>weather 11205</code> or <code>weather Brooklyn, NY</code> to get the weather in Brooklyn.
  DESCRIPTION

  text_id 'weather'

  def text params
  	fragments = [""]
  	max_size = 160
	message_body = params['Body']

	lat = Geocoder.search("#{message_body}").first.geometry["location"]["lat"]
	lng = Geocoder.search("#{message_body}").first.geometry["location"]["lng"]

	ForecastIO.api_key = '49f769efb11fc808363e17f9d04c428f'
	forecast = ForecastIO.forecast(lat, lng)

	forecast_current = "It is currently #{forecast.currently.temperature}. #{forecast.hourly.summary}"
	forecast_future = forecast.daily.summary.gsub(/°/," degrees")
	forecast_string = forecast_current + forecast_future 

	forecast_string.split.each do |word|
		if fragments.last.length + word.length + 1 > max_size
			fragments.push word 
		else
			fragments.last << " #{word}"
		end
	end
	
    "<Response>#{fragments.map { |frags| "<Sms>#{frags.strip}</Sms>" }.join}</Response>"
  end
end

