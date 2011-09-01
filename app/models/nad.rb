class Nad < ActiveRecord::Base
  #domain_id shouldn't be accessible, it' s automatically inferred from the outboundlink when we create the nad
  attr_accessible :outboundlink, :imgurl, :head, :caption, :approved
  belongs_to :domain
  has_many :views
end
