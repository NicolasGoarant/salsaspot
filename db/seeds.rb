# db/seeds.rb

puts "🧹 Nettoyage de la base de données..."
Event.destroy_all

puts "🎉 Création des événements..."

# NANCY
nancy1 = Event.create!(
  title: "Soirée Salsa Cubaine Nancy",
  description: "Tous les mercredis, soirée salsa cubaine avec initiation gratuite de 20h à 21h. Ambiance conviviale et internationale !",
  event_type: "soiree",
  dance_styles: ["salsa"],
  level: "tous",
  venue_name: "La Manufacture",
  address: "10 Rue Baron Louis",
  city: "Nancy",
  postal_code: "54000",
  latitude: 48.6921,
  longitude: 6.1844,
  starts_at: DateTime.new(2026, 2, 12, 20, 0),
  ends_at: DateTime.new(2026, 2, 12, 1, 0),
  recurrence: "hebdomadaire",
  price: 8.0,
  is_free: false,
  has_lessons: true,
  lessons_time: "20h-21h",
  organizer_name: "Nancy Salsa",
  organizer_email: "contact@nancysalsa.fr",
  phone: "06 12 34 56 78",
  website: "https://nancysalsa.fr",
  is_active: true,
  is_verified: true
)

nancy2 = Event.create!(
  title: "Bachata Sensuelle - Soirée Mensuelle",
  description: "Grande soirée bachata sensuelle le premier samedi du mois. DJ invité, ambiance tamisée, cours d'initiation à 21h.",
  event_type: "soiree",
  dance_styles: ["bachata"],
  level: "intermediaire",
  venue_name: "Le Charmant Som",
  address: "15 Rue des Carmes",
  city: "Nancy",
  postal_code: "54000",
  latitude: 48.6937,
  longitude: 6.1834,
  starts_at: DateTime.new(2026, 3, 1, 21, 0),
  ends_at: DateTime.new(2026, 3, 2, 2, 0),
  recurrence: "mensuel",
  price: 12.0,
  is_free: false,
  has_lessons: true,
  lessons_time: "21h-22h",
  organizer_name: "Bachata Lorraine",
  organizer_email: "contact@bachatalorraine.fr",
  phone: "06 23 45 67 89",
  is_active: true,
  is_verified: true
)

# PARIS
paris1 = Event.create!(
  title: "Soirée Salsa La Felicità",
  description: "Grande soirée salsa/bachata avec cours d'initiation. 3 pistes de danse, ambiance exceptionnelle dans le plus grand restaurant italien de Paris !",
  event_type: "soiree",
  dance_styles: ["salsa", "bachata"],
  level: "tous",
  venue_name: "La Felicità",
  address: "5 Parvis Alan Turing",
  city: "Paris",
  postal_code: "75013",
  latitude: 48.8322,
  longitude: 2.3730,
  starts_at: DateTime.new(2026, 2, 8, 19, 0),
  ends_at: DateTime.new(2026, 2, 9, 1, 0),
  recurrence: "hebdomadaire",
  price: 10.0,
  is_free: false,
  has_lessons: true,
  lessons_time: "19h-20h",
  organizer_name: "Paris Salsa Events",
  organizer_email: "contact@parissalsaevents.fr",
  phone: "01 42 34 56 78",
  website: "https://parissalsaevents.fr",
  facebook_url: "https://facebook.com/parissalsaevents",
  is_active: true,
  is_verified: true
)

paris2 = Event.create!(
  title: "Bachata Night",
  description: "100% Bachata sensuelle, gratuit ! Tous les jeudis au Balajo, temple de la danse parisienne depuis 1936.",
  event_type: "soiree",
  dance_styles: ["bachata"],
  level: "tous",
  venue_name: "Le Balajo",
  address: "9 Rue de Lappe",
  city: "Paris",
  postal_code: "75011",
  latitude: 48.8531,
  longitude: 2.3726,
  starts_at: DateTime.new(2026, 2, 13, 21, 0),
  ends_at: DateTime.new(2026, 2, 14, 2, 0),
  recurrence: "hebdomadaire",
  price: 0,
  is_free: true,
  has_lessons: false,
  organizer_name: "Le Balajo",
  organizer_email: "contact@balajo.fr",
  phone: "01 47 00 07 87",
  website: "https://balajo.fr",
  is_active: true,
  is_verified: true
)

paris3 = Event.create!(
  title: "Kizomba Paradise",
  description: "Soirée 100% kizomba avec les meilleurs DJs de la capitale. Dress code élégant recommandé.",
  event_type: "soiree",
  dance_styles: ["kizomba"],
  level: "intermediaire",
  venue_name: "New Morning",
  address: "7-9 Rue des Petites Écuries",
  city: "Paris",
  postal_code: "75010",
  latitude: 48.8732,
  longitude: 2.3496,
  starts_at: DateTime.new(2026, 2, 15, 22, 0),
  ends_at: DateTime.new(2026, 2, 16, 3, 0),
  recurrence: "mensuel",
  price: 15.0,
  is_free: false,
  has_lessons: false,
  organizer_name: "Kizomba Paris",
  organizer_email: "contact@kizombaparis.fr",
  is_active: true,
  is_verified: true
)

paris4 = Event.create!(
  title: "Sunday Salsa Social",
  description: "Brunch + soirée salsa le dimanche après-midi. Ambiance conviviale, parfait pour rencontrer d'autres danseurs !",
  event_type: "soiree",
  dance_styles: ["salsa"],
  level: "tous",
  venue_name: "La Bellevilloise",
  address: "19-21 Rue Boyer",
  city: "Paris",
  postal_code: "75020",
  latitude: 48.8688,
  longitude: 2.3883,
  starts_at: DateTime.new(2026, 2, 16, 15, 0),
  ends_at: DateTime.new(2026, 2, 16, 21, 0),
  recurrence: "hebdomadaire",
  price: 12.0,
  is_free: false,
  has_lessons: true,
  lessons_time: "15h-16h",
  organizer_name: "Sunday Salsa",
  is_active: true,
  is_verified: true
)

# LYON
lyon1 = Event.create!(
  title: "Soirée Salsa/Bachata Lyon",
  description: "Tous les vendredis, soirée mixte salsa et bachata avec cours tous niveaux. Grande piste de danse et bar.",
  event_type: "soiree",
  dance_styles: ["salsa", "bachata"],
  level: "tous",
  venue_name: "Ninkasi Gerland",
  address: "267 Rue Marcel Mérieux",
  city: "Lyon",
  postal_code: "69007",
  latitude: 45.7267,
  longitude: 4.8372,
  starts_at: DateTime.new(2026, 2, 14, 20, 30),
  ends_at: DateTime.new(2026, 2, 15, 1, 0),
  recurrence: "hebdomadaire",
  price: 8.0,
  is_free: false,
  has_lessons: true,
  lessons_time: "20h30-21h30",
  organizer_name: "Lyon Salsa",
  organizer_email: "contact@lyonsalsa.fr",
  is_active: true,
  is_verified: true
)

lyon2 = Event.create!(
  title: "Festival Bachata Lyon",
  description: "3 jours de stages, shows et soirées avec les plus grands artistes internationaux de bachata !",
  event_type: "festival",
  dance_styles: ["bachata"],
  level: "tous",
  venue_name: "Halle Tony Garnier",
  address: "20 Place Antonin Perrin",
  city: "Lyon",
  postal_code: "69007",
  latitude: 45.7311,
  longitude: 4.8271,
  starts_at: DateTime.new(2026, 4, 10, 18, 0),
  ends_at: DateTime.new(2026, 4, 13, 2, 0),
  recurrence: "ponctuel",
  price: 65.0,
  is_free: false,
  has_lessons: true,
  lessons_time: "Toute la journée",
  organizer_name: "Lyon Bachata Festival",
  website: "https://lyonbachatafestival.com",
  is_active: true,
  is_verified: true
)

# TOULOUSE
toulouse1 = Event.create!(
  title: "Salsa Cubaine Toulouse",
  description: "Soirée casino/rueda tous les mardis. Initiation rueda de casino à 20h, parfait pour les débutants !",
  event_type: "soiree",
  dance_styles: ["salsa"],
  level: "debutant",
  venue_name: "Le Bijou",
  address: "123 Avenue de Muret",
  city: "Toulouse",
  postal_code: "31300",
  latitude: 43.5896,
  longitude: 1.4189,
  starts_at: DateTime.new(2026, 2, 11, 20, 0),
  ends_at: DateTime.new(2026, 2, 11, 23, 30),
  recurrence: "hebdomadaire",
  price: 6.0,
  is_free: false,
  has_lessons: true,
  lessons_time: "20h-21h",
  organizer_name: "Toulouse Salsa",
  is_active: true,
  is_verified: true
)

# MARSEILLE
marseille1 = Event.create!(
  title: "Soirée Salsa du Vieux-Port",
  description: "Tous les samedis, soirée salsa portoricaine avec vue sur le Vieux-Port. Terrasse l'été !",
  event_type: "soiree",
  dance_styles: ["salsa"],
  level: "tous",
  venue_name: "La Caravelle",
  address: "34 Quai du Port",
  city: "Marseille",
  postal_code: "13002",
  latitude: 43.2965,
  longitude: 5.3698,
  starts_at: DateTime.new(2026, 2, 15, 21, 0),
  ends_at: DateTime.new(2026, 2, 16, 1, 30),
  recurrence: "hebdomadaire",
  price: 10.0,
  is_free: false,
  has_lessons: false,
  organizer_name: "Marseille Salsa",
  is_active: true,
  is_verified: true
)

marseille2 = Event.create!(
  title: "Kizomba & Zouk Marseille",
  description: "Soirée afro-latine 100% kizomba et zouk. Cours de kizomba pour débutants à 21h.",
  event_type: "soiree",
  dance_styles: ["kizomba"],
  level: "tous",
  venue_name: "Le Moulin",
  address: "47 Boulevard de Saint-Loup",
  city: "Marseille",
  postal_code: "13010",
  latitude: 43.2755,
  longitude: 5.4197,
  starts_at: DateTime.new(2026, 2, 21, 21, 0),
  ends_at: DateTime.new(2026, 2, 22, 2, 0),
  recurrence: "mensuel",
  price: 12.0,
  is_free: false,
  has_lessons: true,
  lessons_time: "21h-22h",
  organizer_name: "Marseille Kizomba",
  is_active: true,
  is_verified: true
)

# BORDEAUX
bordeaux1 = Event.create!(
  title: "Soirée Latine Bordeaux",
  description: "Mix salsa, bachata, kizomba tous les vendredis. Cours multi-danses à 20h30.",
  event_type: "soiree",
  dance_styles: ["salsa", "bachata", "kizomba"],
  level: "tous",
  venue_name: "I.Boat",
  address: "Quai Armand Lalande",
  city: "Bordeaux",
  postal_code: "33100",
  latitude: 44.8547,
  longitude: -0.5534,
  starts_at: DateTime.new(2026, 2, 14, 20, 30),
  ends_at: DateTime.new(2026, 2, 15, 2, 0),
  recurrence: "hebdomadaire",
  price: 10.0,
  is_free: false,
  has_lessons: true,
  lessons_time: "20h30-21h30",
  organizer_name: "Bordeaux Latino",
  is_active: true,
  is_verified: true
)

puts "📸 Ajout des photos locales..."

# Map des événements avec leur style principal
events_with_photos = {
  nancy1 => 'salsa',
  nancy2 => 'bachata',
  paris1 => 'salsa',
  paris2 => 'bachata',
  paris3 => 'kizomba',
  paris4 => 'salsa',
  lyon1 => 'salsa',
  lyon2 => 'bachata',
  toulouse1 => 'salsa',
  marseille1 => 'salsa',
  marseille2 => 'kizomba',
  bordeaux1 => 'salsa'
}

events_with_photos.each do |event, style|
  # Chemin vers l'image dans app/assets/images
  image_path = Rails.root.join('app', 'assets', 'images', "#{style}.jpg")

  if File.exist?(image_path)
    event.photos.attach(
      io: File.open(image_path),
      filename: "#{style}.jpg",
      content_type: 'image/jpeg'
    )
    puts "   ✅ Photo #{style}.jpg attachée pour #{event.title}"
  else
    puts "   ⚠️  Image #{style}.jpg non trouvée"
  end
end

puts ""
puts "✅ #{Event.count} événements créés !"
puts ""
puts "📊 Répartition :"
puts "   - Salsa : #{Event.where("'salsa' = ANY(dance_styles)").count}"
puts "   - Bachata : #{Event.where("'bachata' = ANY(dance_styles)").count}"
puts "   - Kizomba : #{Event.where("'kizomba' = ANY(dance_styles)").count}"
puts ""
puts "🏙️  Villes :"
Event.group(:city).count.each do |city, count|
  puts "   - #{city} : #{count} événements"
end
puts ""
puts "📸 Photos attachées : #{Event.joins(:photos_attachments).distinct.count} événements"
