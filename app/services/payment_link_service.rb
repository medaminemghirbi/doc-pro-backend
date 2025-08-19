class PaymentLinkService
  def self.generate_for(user)
    data = {
      receiverWalletId: "672de5dabe34904520699652",
      token: "TND",
      amount: 50000,
      type: "immediate",
      acceptedPaymentMethods: [
        "wallet",
        "bank_card",
        "e-DINAR"
      ],
      successUrl: "http://localhost:4200",
      failUrl: "http://localhost:4200/fail",
      description: "Payment for Access Account Mr(s) ##{user.firstname} #{user.lastname}"
    }
     uri = URI.parse("https://api.preprod.konnect.network/api/v2/payments/init-payment")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    # Create the POST request
    request = Net::HTTP::Post.new(uri.path) # Corrected class here
    request["x-api-key"] = ENV["X_API_KEY"]
    request["Content-Type"] = "application/json"
    request.body = data.to_json

    # Send the request and parse the response
    response = http.request(request)
    payment_data = JSON.parse(response.body)

    if payment_data.key?("payUrl") && payment_data.key?("paymentRef")
      payment_url = payment_data["payUrl"]
      payment_id = payment_data["paymentRef"]
      UserMailer.send_payment_link(user, payment_url).deliver_now
      # Create the Payment record
      user.create_payment(
        payment_id: payment_id,
        amount: data[:amount],
        status: 0
      )
      render json: {url: payment_url}
    else
      render json: {error: "Failed to generate payment URL"}, status: :unprocessable_entity
    end
  end

  
end