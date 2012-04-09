module Map 
  class API < Grape::API
    version 'v1', :using => :header, :vendor => 'map', :format => :json
    prefix 'api'
    error_format :json
    logger Rails.logger


    # api/outbreaks
    # api/outbreaks/346
    resource :outbreaks do
      get nil do
        start_date = Date.new(2008, 1, 1)
        end_date = Date.new(2009, 12, 31)
        outbreaks = Outbreak.where("first_illness BETWEEN ? AND ?", start_date, end_date)
        outbreaks_by_fips = []

        outbreaks_by_fips = outbreaks.inject({}) do |hsh, o|
          unless o.reporting_county.nil?
            fips = County.find_by_county(o.reporting_county).fips_code
            hsh[fips] = {
              :first_illness => o.first_illness.to_date,
              :last_illness => o.last_illness.try(:to_date),
              :duration => (o.last_illness && o.first_illness ? (o.last_illness.to_date - o.first_illness.to_date).to_i: "unknown"),
              :adjusted_illnesses => o.adjusted_illnesses, 
              :illnesses => o.illnesses,
              :deaths => o.deaths,
              :hospitalizations => o.hospitalizations,
              :reporting_county => o.reporting_county,
              :commodity_group => o.commodity_group
            }
          end
          hsh
        end
        outbreaks_by_fips
      end

      segment '/:id' do
        get nil, :rabl => 'outbreaks/show' do
          @outbreak = Outbreak.find(params[:id])
        end
      end
    end
  
    
    get :unemployments do
      unemployments = Rails.root.join("lib/data/map/unemployment.json").read
    end

  end
end
