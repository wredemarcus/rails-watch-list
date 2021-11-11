# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
require 'nokogiri' # gem to handle html
require 'open-uri' # gem to open websites

def fetch_movies_urls(x)
  # define the link where to fetch info from
  imdb_top_movies_url = 'https://www.imdb.com/chart/top'
  html_file = URI.open(imdb_top_movies_url, 'Accept-Language' => 'en-US').read
  # open that link and read the html
  html_doc = Nokogiri::HTML(html_file)
  css_selector = '.lister-list td.titleColumn a'

  # search for the href of the first five movies
  result = []
  html_doc.search(css_selector).first(x).each do |element|
    # p element.text.strip
    href = element.attribute('href').value
    url = "http://www.imdb.com#{href}"
    result << url
  end

  # return an array with the first 5 urls
  result
end

def scrape_movie(movie_url)
  # we open the url
  html_file = URI.open(movie_url, 'Accept-Language' => 'en-US').read
  # we create the html doc
  html_doc = Nokogiri::HTML(html_file)
  # we find the right css for each of the criteria
  title = html_doc.search('h1').text.strip
  storyline = html_doc.search("p[class*='GenresAndPlot__Plot'] span").first.text.strip
  poster_url = html_doc.search('.ipc-media img').first.attribute('src').value
  rating = html_doc.search('.ipc-button__text span').first.text

  {
    title: title,
    overview: storyline,
    poster_url: poster_url,
    rating: rating
  }
end

puts "Fetching movies urls"
top10_movie_urls = fetch_movies_urls(10)

top10_movie_urls.each do |movie_url|
  puts "Creating #{movie_url}"
  Movie.create! scrape_movie(movie_url)
end

puts "All movies created!"
