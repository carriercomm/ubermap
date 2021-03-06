class Layer < ActiveRecord::Base
  has_many :map_layers
  has_many :maps, through: :map_layers

  dragonfly_accessor :file

  scope :active, ->{ where(active: true) }

  serialize :fields

  before_save :fetch_fields

  def fetch_fields
    case self.file.ext
    when 'geojson'
      set_fields_from_geojson
    end
  end

  def set_fields_from_geojson
    f = []
    JSON.parse(self.file.data)['features'].each do |feature|
      f += feature['properties'].keys
    end

    self.fields = f.uniq.compact
  end

  def leaflet_params
    {
      url: file.try(:remote_url),
      popup: popup,
      style: style.to_json,
      options: options
    }
  end
end
