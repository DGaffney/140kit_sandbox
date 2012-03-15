require 'test_helper'

class AnalyticalOfferingVariablesControllerTest < ActionController::TestCase
  setup do
    @analytical_offering_variable = analytical_offering_variables(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:analytical_offering_variables)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create analytical_offering_variable" do
    assert_difference('AnalyticalOfferingVariable.count') do
      post :create, analytical_offering_variable: @analytical_offering_variable.attributes
    end

    assert_redirected_to analytical_offering_variable_path(assigns(:analytical_offering_variable))
  end

  test "should show analytical_offering_variable" do
    get :show, id: @analytical_offering_variable
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @analytical_offering_variable
    assert_response :success
  end

  test "should update analytical_offering_variable" do
    put :update, id: @analytical_offering_variable, analytical_offering_variable: @analytical_offering_variable.attributes
    assert_redirected_to analytical_offering_variable_path(assigns(:analytical_offering_variable))
  end

  test "should destroy analytical_offering_variable" do
    assert_difference('AnalyticalOfferingVariable.count', -1) do
      delete :destroy, id: @analytical_offering_variable
    end

    assert_redirected_to analytical_offering_variables_path
  end
end
