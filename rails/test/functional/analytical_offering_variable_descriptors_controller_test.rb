require 'test_helper'

class AnalyticalOfferingVariableDescriptorsControllerTest < ActionController::TestCase
  setup do
    @analytical_offering_variable_descriptor = analytical_offering_variable_descriptors(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:analytical_offering_variable_descriptors)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create analytical_offering_variable_descriptor" do
    assert_difference('AnalyticalOfferingVariableDescriptor.count') do
      post :create, analytical_offering_variable_descriptor: @analytical_offering_variable_descriptor.attributes
    end

    assert_redirected_to analytical_offering_variable_descriptor_path(assigns(:analytical_offering_variable_descriptor))
  end

  test "should show analytical_offering_variable_descriptor" do
    get :show, id: @analytical_offering_variable_descriptor
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @analytical_offering_variable_descriptor
    assert_response :success
  end

  test "should update analytical_offering_variable_descriptor" do
    put :update, id: @analytical_offering_variable_descriptor, analytical_offering_variable_descriptor: @analytical_offering_variable_descriptor.attributes
    assert_redirected_to analytical_offering_variable_descriptor_path(assigns(:analytical_offering_variable_descriptor))
  end

  test "should destroy analytical_offering_variable_descriptor" do
    assert_difference('AnalyticalOfferingVariableDescriptor.count', -1) do
      delete :destroy, id: @analytical_offering_variable_descriptor
    end

    assert_redirected_to analytical_offering_variable_descriptors_path
  end
end
