class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable, :omniauth_providers => [:facebook]

  validates :name, length: { maximum: 30 }, presence: true, format: { with: /\A[a-zA-Z\s]+\z/, message: "英文字と半角空文字のみが使用できます" }
  validates :tel, length: { minimum: 10, maximum: 12 }, presence: true, numericality: { only_integer: true }
  validates :line, format: { with: /\A[a-zA-Z0-9]+\z/i, message: "英数字のみが使用できます" }, allow_blank: true
  validates :facebook, format: /\A#{URI::regexp(%w(https))}\www.facebook.com/, allow_blank: true

  def self.find_for_oauth(auth)
    user = User.find_by(uid: auth.uid, provider: auth.provider)
    unless user
      unless User.exists?(email: User.get_email(auth))
        user = User.new(
          uid: auth.uid,
          provider: auth.provider,
          name: auth.info.name,
          email: User.get_email(auth),
          password: Devise.friendly_token[8, 30])
        user.save(validate: false)
      else
        user = User.find_by(email: User.get_email(auth))
        user.update(uid: auth.uid, provider: auth.provider)
      end
    end
    user
  end

  def update_without_current_password(params, *options)
    params.delete(:current_password)

    if params[:password].blank? && params[:password_confirmation].blank?
      params.delete(:password)
      params.delete(:password_confirmation)
    end

    result = update_attributes(params, *options)
    clean_up_passwords
    result
  end

  private
    def self.get_email(auth)
      email = auth.info.email
      email = "#{auth.provider}-#{auth.uid}@example.com" if email.blank?
      email
    end
end
