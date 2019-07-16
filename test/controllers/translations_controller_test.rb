require 'test_helper'

class TranslationsControllerTest < ActionDispatch::IntegrationTest
  test "should get lookup" do
    get translations_lookup_url
    assert_response :success
  end

end
