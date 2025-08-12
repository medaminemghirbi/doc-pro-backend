# db/seeds.rb
require "faker"
require "open-uri"
require "yaml"
require "csv"
require "net/http"
require "json"

puts "🌱 Seeding data..."

# === Constants and Utility Methods ===


## DONE 

def download_image(url)
  uri = URI.parse(url)
  response = Net::HTTP.get_response(uri)
  response.is_a?(Net::HTTPSuccess) ? StringIO.new(response.body) : nil
end

def generate_random_appointment_time
  year = Time.now.year
  start_date = Date.new(year, 7, 17)
  end_date = Date.new(year, 9, 30)
  time_slots = []

  (start_date..end_date).each do |date|
    time = Time.zone.parse("09:00").change(year: date.year, month: date.month, day: date.day)
    while time <= Time.zone.parse("16:00").change(year: date.year, month: date.month, day: date.day)
      time_slots << time
      time += 30.minutes
    end
  end

  time_slots.sample
end

# === Seed Admin ===
puts "👤 Seeding Admin..."
admin_avatar = download_image("https://thumbs.dreamstime.com/b/admin-reliure-de-bureau-sur-le-bureau-en-bois-sur-la-table-crayon-color%C3%A9-79046621.jpg")

if admin_avatar
  admin = Admin.create!(
    email: "Admin@example.com",
    firstname: "Admin",
    lastname: "Admin",
    password: "123456",
    password_confirmation: "123456",
    confirmed_at: Time.zone.now
  )
  admin.avatar.attach(io: admin_avatar, filename: "admin_avatar.jpg", content_type: "image/jpeg")
  puts "✔️ Admin seeded"
else
  puts "⚠️ Failed to download admin avatar"
end

# === Seed Doctors ===
puts "🩺 Seeding Doctors from CSV..."
csv_path = Rails.root.join("app/services/dermatologue_doctors.csv")
starting_order = 1

CSV.foreach(csv_path, headers: true).first(4).each_with_index do |row, index|
  doctor = Doctor.create!(
    firstname: row["name"].split.first,
    lastname: row["name"].split[1..].join(" "),
    location: "sousse",
    email: Faker::Internet.unique.email,
    email: "#{row['name'].split.first.downcase}.#{row['name'].split[1].downcase}@dermapro.com",
    order: starting_order + index,
    password: "123456",
    password_confirmation: "123456",
    plateform: rand(0..1),
    gender: rand(0..1),
    confirmed_at: Time.zone.now
  )

  if row["avatar_src"].present?
    avatar_file = download_image(row["avatar_src"])
    if avatar_file
      doctor.avatar.attach(io: avatar_file, filename: File.basename(row["avatar_src"]), content_type: "image/jpeg")
    else
      puts "⚠️ Failed to download avatar for Doctor #{doctor.firstname}"
    end
  end

  puts "✔️ Doctor #{doctor.firstname} #{doctor.lastname} seeded"
end


# === Seed Patients ===
puts "🧑‍🤝‍🧑 Seeding Patients..."

TUNISIAN_FIRST_NAMES = %w[Amine Mohamed Ahmed Youssef Sami Khalil Rami Wassim Firas Bilel Anis]
TUNISIAN_LAST_NAMES = %w[BenAli Gharbi Trabelsi Bouzid Jaziri BenRomdhane Hammami Ayari Tlili Khlifi]

def download_realistic_image(gender)
  gender_folder = gender == 0 ? "men" : "women"
  url = "https://randomuser.me/api/portraits/#{gender_folder}/#{rand(1..99)}.jpg"
  URI.open(url)
rescue => e
  puts "⚠️ Error downloading image: #{e}"
  nil
end

4.times do |i|
  phone_number = Faker::PhoneNumber.phone_number.gsub(/\D/, "").slice(0, 8)
  gender = rand(0..1)

  patient = Patient.create!(
    email: Faker::Internet.unique.email,
    firstname: TUNISIAN_FIRST_NAMES.sample,
    lastname: TUNISIAN_LAST_NAMES.sample,
    password: "123456",
    password_confirmation: "123456",
    order: starting_order + i,
    phone_number: phone_number,
    plateform: rand(0..1),
    gender: gender,
    location: %w[sousse monastir nabeul bizerte].sample,
    confirmed_at: Time.zone.now
  )

  avatar_file = download_realistic_image(gender)
  if avatar_file
    patient.avatar.attach(io: avatar_file, filename: "#{patient.firstname}_avatar.jpg", content_type: "image/jpeg")
  else
    puts "⚠️ Failed to download avatar for Patient #{patient.firstname}"
  end

  puts "✔️ Patient #{patient.firstname} #{patient.lastname} seeded"
end



