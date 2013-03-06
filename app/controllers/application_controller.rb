class ApplicationController < ArtfullyOseController
  protect_from_forgery
  layout :specify_layout
end