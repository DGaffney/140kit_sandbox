require 'test_helper'

class AnalysisMetadatasControllerTest < ActionController::TestCase
  setup do
    @analysis_metadata = analysis_metadatas(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:analysis_metadatas)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create analysis_metadata" do
    assert_difference('AnalysisMetadata.count') do
      post :create, analysis_metadata: @analysis_metadata.attributes
    end

    assert_redirected_to analysis_metadata_path(assigns(:analysis_metadata))
  end

  test "should show analysis_metadata" do
    get :show, id: @analysis_metadata
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @analysis_metadata
    assert_response :success
  end

  test "should update analysis_metadata" do
    put :update, id: @analysis_metadata, analysis_metadata: @analysis_metadata.attributes
    assert_redirected_to analysis_metadata_path(assigns(:analysis_metadata))
  end

  test "should destroy analysis_metadata" do
    assert_difference('AnalysisMetadata.count', -1) do
      delete :destroy, id: @analysis_metadata
    end

    assert_redirected_to analysis_metadatas_path
  end
end
