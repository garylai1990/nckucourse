class User < ActiveRecord::Base
  has_many :user_courseships
  has_many :courses, :through => :user_courseships
  has_many :exps

  def self.from_omniauth(auth)
    where(auth.slice(:provider, :uid)).first_or_initialize.tap do |user|
      user.provider = auth.provider
      user.uid = auth.uid
      user.name = auth.info.name
      user.oauth_token = auth.credentials.token
      user.oauth_expires_at = Time.at(auth.credentials.expires_at)
      user.save!
    end
  end

  def graph
    @graph ||= Koala::Facebook::API.new(oauth_token)
  end
  
  def friends
    graph.get_connection("me","friends")
  end

  def gender
    @gender = graph.get_object("me")["gender"]
  end
end