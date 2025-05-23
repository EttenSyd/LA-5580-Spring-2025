## ----Install-packages---------------------------------------------------------
#load one at a time
install.packages("tidycensus")
install.packages("tidyverse")
install.packages(c("sf", "tigris"))
install.packages("leaflet") 
install.packages("htmlwidgets")
install.packages("htmltools")

## ----Load Libraries-----------------------------------------------------------
#load one at a time
library(tidycensus)
library(tidyverse)
library(sf)
library(tigris)
library(leaflet)
library(htmlwidgets)
library(htmltools)



#for ACS5 fiund a variable of interest.
ACS5_2023_variables <- load_variables(2023, "acs5", cache = TRUE)
View(ACS5_2023_variables)


#	 Replace the B19013_001 with your own indicator
# note I called the result myVariable
myVariable <- get_acs(geography = "county", 
                          variables = "B19013_001",
                          state = "Iowa", 
                          output = "wide",
                          geometry = TRUE, 
                          survey = "acs5",
                          year = 2023)
#Look at the data frame and notice only 10 results!
view(myVariable)

#optionally if you want to use this in Tableau you can save it as a geoJSON
st_write(myVariable, "WednesdayDemo2.geojson")




## ----Leaflet Mapping-----------------------------------------------------------

# Ensure spatial data is in WGS84 (EPSG:4326) for Leaflet
myVariableTransform <- st_transform(myVariable, crs = 4326)



# Define a color palette to use for the values
# You will need to replace B19013_001E with the column name found in the list
# of the variable you want to map. You need to adjust this throughout 
# the rest of the leaflet mapping code. 

# As for the colors you can adjust the value of the palette =
# "Blues" (Various shades of blue)
# "Reds" (Various shades of red)
# "Greens" (Various shades of green)
# "Oranges" (Various shades of orange)
# "Purples" (Various shades of purple)
# "BuGn" (Blue-Green gradient)
# "RdYlBu" (Red-Yellow-Blue diverging)
# "Viridis" (Colorblind-friendly, yellow to blue)

income_pal <- colorNumeric(
  palette = "YlGnBu", # Yellow-Green-Blue color scheme
  domain = myVariableTransform$B19013_001E
)

# A manually defined color pallete can alos be created
# income_pal <- colorNumeric(
#  palette = c("#440154", "#21908C", "#FDE725"),  # Dark purple → Teal → Yellow
#  domain = myVariableTransform$B19013_001E
# )


# Create Leaflet interactive map
myMap <- leaflet(myVariableTransform) %>%
  addProviderTiles(providers$CartoDB.Positron) %>%  # Use a light basemap
  addPolygons(
    fillColor = ~income_pal(B19013_001E), #replace B19013_001Ewith your  value
    color = "black", #Outline color - you can select a color
    weight = 0.5, #line thinckness is 0 - 1
    smoothFactor = 0.3,
    fillOpacity = 0.6,  #transparency value of 0-1, you can edit this
    #Prof Seeger will provide more detail on this label in an updated version
    #replace B19013_001E with your  value
    label = ~paste0(NAME, " Median Income: $", format(B19013_001E, big.mark = ",")),
    labelOptions = labelOptions(
      sticky = FALSE,  # Ensures tooltips disappear when not hovering
      interactive = TRUE,  # Ensures tooltips respond to mouse hover
      opacity = 1,  # Keeps tooltips visible when hovered
      style = list(
        "background-color" = "white", #optionally change if it fits your design
        "border" = "1px solid black", #You could make this larger, but don't
        "padding" = "5px" #distance from text to edge of box
      )
    ),
    highlightOptions = highlightOptions(
      weight = 2,
      color = "red", #the outline color of the selected feature
      fillOpacity = 0.9, #0-1 transparency
      bringToFront = TRUE
    )
  ) %>%
  addLegend(
    position = "bottomright",
    pal = income_pal,
    values = myVariableTransform$B19013_001E, #replace B19013_001E with your  value
    title = "Median Household Income",   #you will need to edit this!
    labFormat = labelFormat(prefix = "$")
  ) %>%
  addControl("<strong>Iowa Median Household Income (2023)</strong>", position = "topright", className = "leaflet-control-title")
#replace the text above

myMap

# make sure and save and set session to location of local file!!!
# Save the map as an HTML widget
saveWidget(myMap, file = "wednesdayDemo.html") #name the file
