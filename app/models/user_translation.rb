class UserTranslation < ApplicationRecord
  belongs_to :language
  belongs_to :translation, optional: true
end
