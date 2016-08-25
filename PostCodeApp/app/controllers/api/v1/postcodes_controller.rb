module Api
  module V1
    class PostcodesController < ApplicationController
      respond_to :json

      def search
        ransack_param = {
          code_or_suburbs_name_eq: params[:input]
        }

        if !params[:state].nil? && params[:state]['id'].to_i != 0
          ransack_param[:state_id_eq] = params[:state]['id']
        end

        @q = Postcode.ransack(ransack_param)
        postcodes = @q.result.includes(:suburbs, :state)

        if postcodes.empty?
          @postcode = nil
          render json: @postcode
        end

        @postcode = postcodes.first
        @postcode.increment!(:search_count)
         render json: @postcode
      end
=begin
      def check
        @postcodes = Postcode.postcode_from_point(params[:lng], params[:lat])
      end

      def select
        code = params[:postcode]
        postcodes = Postcode.where('code = ?', code)

        head :not_found if postcodes.empty?

        postcodes.first.increment!(:select_count)

        head :ok, content_type: 'text/html'
      end

      def statistics
        @postcodes = Postcode.where('search_count IS NOT NULL OR select_count IS NOT NULL')
                             .select('code, search_count, select_count')
        render json: @postcodes
      end

      def stream_all
        @postcodes = Postcode.where('max_lat < ? AND min_lat > ? AND max_lng < ? AND min_lng > ?',
                                    params[:currentBound]['max_lat'], params[:currentBound]['min_lat'],
                                    params[:currentBound]['max_lng'], params[:currentBound]['min_lng'])
                             .order('((max_lat - min_lat) * (max_lng - min_lng)) DESC')
                             .offset(params[:skip])
                             .limit(params[:take])

        render json: @postcodes
      end
=end
    end
  end
end
