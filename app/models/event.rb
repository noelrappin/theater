class Event < ActiveRecord::Base

  has_paper_trail

  has_many :performances

end
