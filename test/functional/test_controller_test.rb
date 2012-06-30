require 'test_helper'

class TestControllerTest < ActionController::TestCase
  test "should get create_assignment" do
    get :create_assignment
    assert_response :success
  end

end
