class Product < ApplicationRecord

  belongs_to :category
  
  mount_uploader :image, ImageUploader

  acts_as_votable

  belongs_to :user
  has_many :comments

  has_many :photos
  accepts_nested_attributes_for :photos
end
