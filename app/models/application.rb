class Application < ApplicationRecord
  has_many :chats

  validates :name, presence: {:message => 'Application should have a name'}
  validates :token, presence: {:message => "Token field can't be blank"}
end
