Geocoder.configure(
  lookup: :nominatim,
  timeout: 5,
  units: :km,
  http_headers: { "User-Agent" => "SalsaSpot" }
)
