require 'test_helper'

class AnalyticalOfferingsControllerTest < ActionController::TestCase
  setup do
    @analytical_offering = analytical_offerings(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:analytical_offerings)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create analytical_offering" do
    assert_difference('AnalyticalOffering.count') do
      post :create, analytical_offering: @analytical_offering.attributes
    end

    assert_redirected_to analytical_offering_path(assigns(:analytical_offering))
  end

  test "should show analytical_offering" do
    get :show, id: @analytical_offering
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @analytical_offering
    assert_response :success
  end

  test "should update analytical_offering" do
    put :update, id: @analytical_offering, analytical_offering: @analytical_offering.attributes
    assert_redirected_to analytical_offering_path(assigns(:analytical_offering))
  end

  test "should destroy analytical_offering" do
    assert_difference('AnalyticalOffering.count', -1) do
      delete :destroy, id: @analytical_offering
    end

    assert_redirected_to analytical_offerings_path
  end
end
