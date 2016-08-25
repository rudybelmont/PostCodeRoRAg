module Api
  module V1
    class SuburbsController < ApplicationController
      respond_to :json

      def list
        suburbs = Suburb.joins(postcode: [:state]).pluck(:name, :'postcodes.code', :'states.name')
        @suburbs = []
        suburbs.each do |suburb|
          @suburbs.push(OpenStruct.new(name: suburb[0], postcode: suburb[1], state: suburb[2]))
        end
        render json: @suburbs
      end
    end
  end
end
