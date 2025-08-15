# db/seeds.rb
require "faker"
require "open-uri"
require "csv"
require "net/http"
require "json"

puts "🌱 Seeding data..."

# === Utilities ===
def download_image(url)
  uri = URI.parse(url)
  response = Net::HTTP.get_response(uri)
  response.is_a?(Net::HTTPSuccess) ? StringIO.new(response.body) : nil
end

def download_realistic_image(gender)
  gender_folder = gender == 0 ? "men" : "women"
  url = "https://randomuser.me/api/portraits/#{gender_folder}/#{rand(1..99)}.jpg"
  URI.open(url)
rescue => e
  puts "⚠️ Error downloading image: #{e}"
  nil
end

# === Admin ===
puts "👤 Seeding Admin..."
admin_avatar = download_image("https://thumbs.dreamstime.com/b/admin-reliure-de-bureau-sur-le-bureau-en-bois-sur-la-table-crayon-color%C3%A9-79046621.jpg")

admin = User.create!(
  type: "Admin", # STI
  email: "admin@example.com",
  firstname: "Admin",
  lastname: "Admin",
  password: "123456",
  password_confirmation: "123456",
  confirmed_at: Time.zone.now
)
admin.avatar.attach(io: admin_avatar, filename: "admin_avatar.jpg", content_type: "image/jpeg") if admin_avatar
puts "✔️ Admin seeded"

# === Subscriptions ===
puts "📦 Seeding Subscriptions..."
subscriptions_data = [
  {
    name: "basic",
    price: 15.0,
    duration_in_days: nil,
    has_access_account: true,
    has_access_agenda: true,
    has_access_patients: true
  },
  {
    name: "premium",
    price: 30.0,
    duration_in_days: nil,
    has_access_account: true,
    has_access_agenda: true,
    has_access_patients: true,
    has_access_hr_module: true,
    has_access_intelligent_prescription: true,
    has_access_manage_notifications: true,
    has_access_manage_documents: true,
    has_access_multilang_platform: true,
    has_access_ia_assistance: true
  },
  {
    name: "trial",
    price: 0.0,
    duration_in_days: 14,
    has_access_account: true,
    has_access_agenda: true,
    has_access_patients: true,
    has_access_hr_module: true,
    has_access_intelligent_prescription: true,
    has_access_manage_notifications: true,
    has_access_manage_documents: true,
    has_access_multilang_platform: true,
    has_access_ia_assistance: true
  }
]

subscriptions_data.each do |attrs|
  Subscription.find_or_initialize_by(name: attrs[:name]).update!(attrs)
end
puts "✔️ Subscriptions seeded"

# === Doctors ===
puts "🩺 Seeding Doctors..."
csv_path = Rails.root.join("app/services/dermatologue_doctors.csv")
starting_order = 1

CSV.foreach(csv_path, headers: true).first(4).each_with_index do |row, index|
  email = "#{row['name'].split.first.downcase}.#{row['name'].split[1].downcase}@dermapro.com"

  doctor = Doctor.create!(
    firstname: row["name"].split.first,
    lastname: row["name"].split[1..].join(" "),
    location: "sousse",
    email: email,
    order: starting_order + index,
    password: "123456",
    password_confirmation: "123456",
    plateform: rand(0..1),
    gender: rand(0..1),
    confirmed_at: Time.zone.now
  )

  if row["avatar_src"].present?
    avatar_file = download_image(row["avatar_src"])
    doctor.avatar.attach(io: avatar_file, filename: File.basename(row["avatar_src"]), content_type: "image/jpeg") if avatar_file
  end

  puts "✔️ Doctor #{doctor.firstname} seeded"
end

# === Patients ===
puts "🧑‍🤝‍🧑 Seeding Patients..."
TUNISIAN_FIRST_NAMES = %w[Amine Mohamed Ahmed Youssef Sami Khalil Rami Wassim Firas Bilel Anis]
TUNISIAN_LAST_NAMES = %w[BenAli Gharbi Trabelsi Bouzid Jaziri BenRomdhane Hammami Ayari Tlili Khlifi]

4.times do |i|
  gender = rand(0..1)
  patient = Patient.create!(
    email: Faker::Internet.unique.email,
    firstname: TUNISIAN_FIRST_NAMES.sample,
    lastname: TUNISIAN_LAST_NAMES.sample,
    password: "123456",
    password_confirmation: "123456",
    order: starting_order + i,
    phone_number: Faker::Number.number(digits: 8),
    plateform: rand(0..1),
    gender: gender,
    location: %w[sousse monastir nabeul bizerte].sample,
    confirmed_at: Time.zone.now
  )

  avatar_file = download_realistic_image(gender)
  patient.avatar.attach(io: avatar_file, filename: "#{patient.firstname}_avatar.jpg", content_type: "image/jpeg") if avatar_file


  puts "✔️ Patient #{patient.firstname} seeded"
end
