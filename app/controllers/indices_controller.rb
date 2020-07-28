class IndicesController < ApplicationController
  get '/indices/:id' do
    if logged_in?
      @indices = Index.all
      @index = Index.find(params[:id])
      erb :'/indices/index'
    else
      redirect '/login'
    end
  end
end