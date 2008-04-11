require 'rubygems'
require 'yelp'


class SearchController < ApplicationController
  protect_from_forgery :only => [:update, :delete, :create]
  #auto_complete_for :search, :category
  layout 'default' #, :except => 'map'

  @@categories = ['Afghani', 'African', 'American (New)', 'American (Traditional)', 'Argentine', 'Asian Fusion', 'Barbeque', 'Brazilian', 'Breakfast & Brunch', 'British', 'Buffets', 'Burgers', 'Burmese', 'Cajun/Creole', 'Cambodian', 'Caribbean', 'Chicken Wings', 'Chinese', 'Dim Sum', 'Creperies', 'Cuban', 'Delis', 'Diners', 'Ethiopian', 'Fast Food', 'Filipino', 'Fondue', 'Food Stands', 'French', 'German', 'Gluten-Free', 'Greek and Mediterranean', 'Halal', 'Hawaiian', 'Himalayan/Nepalese', 'Hot Dogs', 'Indian/Pakistani', 'Indonesian', 'Irish', 'Italian', 'Japanese', 'Korean', 'Kosher', 'Latin American', 'Live/Raw Food', 'Malaysian', 'Mexican', 'Middle Eastern', 'Mongolian', 'Moroccan', 'Pizza', 'Russian', 'Sandwiches', 'Scandinavian', 'Seafood', 'Singaporean', 'Soul Food', 'Southern', 'Spanish/Basque', 'Steakhouses', 'Sushi Bars', 'Taiwanese', 'Tapas Bars', 'Tex-Mex', 'Thai', 'Turkish', 'Vegan', 'Vegetarian', 'Vietnamese']

  @@categories_short = ['afghani','african','newamerican','tradamerican','argentine','asianfusion','bbq','brazilian','breakfast_brunch','british','buffets','burgers','burmese','cajun','cambodian','caribbean','chicken_wings','chinese','dimsum','creperies','cuban','delis','diners','ethiopian','hotdogs','filipino','fondue','foodstands','french','german','gluten_free','greek','halal','hawaiian','himalayan','hotdog','indpak','indonesian','irish','italian','japanese','korean','kosher','latin','raw_food','malaysian','mexican','mideastern','mongolian','moroccan','pizza','russian','sandwiches','scandinavian','seafood','singaporean','soulfood','southern','spanish','steak','sushi','taiwanese','tapas','tex-mex','thai','turkish','vegan','vegetarian','vietnamese']

  def index
  end
  
  def search
    client = Yelp::Client.new    
    location = params[:search][:location]
    category = params[:search][:category]
    response = nil
  
    # get them to compare correctly
    @@categories.each do |c| c.downcase! end  
    category.downcase!  
        
    category_short = @@categories_short[@@categories.index(category)] if @@categories.index(category)

    p "category: " + category
    p category_short
    
    if category_short
      # try each part of location
      request1 = Yelp::Review::Request::Location.new(
                  :zip => location,                           
                  :radius => 5,
                  :category => category_short,
                  :yws_id => 'IF3x_qHpLu_Wz4f9kh-TqA')
      response1 = client.search(request1)
    
      request2 = Yelp::Review::Request::Location.new(
                  :city => location,
                  :radius => 5,
                  :category => category_short,
                  :yws_id => 'IF3x_qHpLu_Wz4f9kh-TqA')
      response2 = client.search(request2)
    
      request3 = Yelp::Review::Request::Location.new(
                  :neighborhood => location,
                  :radius => 5,
                  :category => category_short,
                  :yws_id => 'IF3x_qHpLu_Wz4f9kh-TqA')
      response3 = client.search(request3)
  
      response = response1['businesses'] if response1['businesses'].length
      response = response2['businesses'] if response2['businesses'].length 
      response = response3['businesses'] if response3['businesses'].length 
      
    end     
    
    render :update do |page|
        page.call 'updateSearch'
        page.call 'toggleLoader'
        if response.nil? || response.empty? || category_short.nil?
          p 'none found'
          page.show 'results'          
          page.replace_html 'results', :partial => 'results',  :locals => { :response => 'SRY, NO RESULTS FINDZ' }
          page.replace_html 'map-wrapper', ''
        else            
          i = rand(response.length)     
          address =  response[i]['address1']
          p address
          @map = GMap.new("map")  
          @map.control_init(:large_map => true, :map_type => true)  
          
          page.replace_html 'results', :partial => 'results', :locals => { :response => response[i] }
          page.show 'results'
          page.replace_html 'map-wrapper', :partial => 'map', :locals => { :map => @map }
          page << "loadMap(#{response[i]['latitude']}, #{response[i]['longitude']}, '#{address}');"
        end
        
    end
  end
  
  def auto_complete_for_search_category
    
    re = Regexp.new("^#{params[:search][:category]}", "i")

    @categories = @@categories.collect().select { |cat| cat.match re }
    render :inline => "<%= content_tag(:ul, @categories.map { |cat| content_tag(:li, h(cat)) }) %>"
  end

end