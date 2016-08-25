module Api
  module V1
    class StatesController < ApplicationController
      respond_to :json

      def list
        @states = State.all.select('id, name')
        render json: @states
      end
    end
  end
end
