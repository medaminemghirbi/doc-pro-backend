class Api::V1::ConsultationTypesController < ApplicationController
    
  def index
    @consultation_types = ConsultationType.all
    render json: @consultation_types
  end
end
