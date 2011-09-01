require 'test_helper'

class NadsControllerTest < ActionController::TestCase
  setup do
    @nad = nads(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:nads)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create nad" do
    assert_difference('Nad.count') do
      post :create, :nad => @nad.attributes
    end

    assert_redirected_to nad_path(assigns(:nad))
  end

  test "should show nad" do
    get :show, :id => @nad.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @nad.to_param
    assert_response :success
  end

  test "should update nad" do
    put :update, :id => @nad.to_param, :nad => @nad.attributes
    assert_redirected_to nad_path(assigns(:nad))
  end

  test "should destroy nad" do
    assert_difference('Nad.count', -1) do
      delete :destroy, :id => @nad.to_param
    end

    assert_redirected_to nads_path
  end
end
