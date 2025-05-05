class VerifyPaymentJob < ApplicationJob
  queue_as :default

  def perform
    # Find all payments that are pending
    pending_payments = Payment.where(status: :pending)

    pending_payments.each do |payment|
      # Perform verification for each payment
      verify_payment(payment)
    end
  end

  private

  def verify_payment(payment)
    uri = URI.parse("https://api.preprod.konnect.network/api/v2/payments/#{payment.payment_id}")
    request = Net::HTTP::Get.new(uri)

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(request)
    end

    if response.is_a?(Net::HTTPSuccess)
      data = JSON.parse(response.body)

      if data["payment"] && data["payment"]["transactions"].present?
        first_transaction = data["payment"]["transactions"].first
        transaction_status = first_transaction["status"]

        if transaction_status == "success"
          payment.update(status: :approved)
          payment.consultation.update(is_payed: true)
          ActionCable.server.broadcast "PaymentChannel", {
            message: "Payment for online consultation on ##{payment.consultation.appointment} has been approved.",
            status: "sent",
            subject: "payment success",
            sent_at: Time.current
          }
        elsif transaction_status == "pending"
          payment.update(status: :pending)
        else
          payment.update(status: :failed)
        end
      else
        payment.update(status: :failed)
      end
    else
      payment.update(status: :failed)
    end
  end
end
