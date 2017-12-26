class Candlesize < ApplicationRecord
  has_many :candledata
  has_many :movings
end
