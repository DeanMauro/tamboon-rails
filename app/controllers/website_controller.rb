class WebsiteController < ApplicationController
  def index
    @token = nil
  end

  def donate
    # Get charity or select a random one
    charity = (params[:charity]=="random") ? Charity.random : Charity.find_by(id: params[:charity])

    # Format amount in satang
    params[:amount] = params[:amount].baht_to_satang

    # Check for valid params
    if params[:omise_token].present? &&
       params[:amount] > 2000 && 
       charity

      if Rails.env.test?
        charge = OpenStruct.new({
          amount: params[:amount],
          paid: (params[:amount] != 99900),
        })
      else
        charge = Omise::Charge.create({
          amount: params[:amount],
          currency: "THB",
          card: params[:omise_token],
          description: "Donation to #{charity.name} [#{charity.id}]",
        })
      end

      if charge.paid
        charity.credit_amount(charge.amount)
        flash.notice = t(".success")
        render :index
        return
      end
    end

    # Failure if invalid params, nonexistent charity, or unpaid charge
    @token = retrieve_token(params[:omise_token])
    flash.now.alert = t(".failure")
    render :index
  end

  private

  def retrieve_token(token)
    return nil if token.blank?

    if Rails.env.test?
      OpenStruct.new({
        id: "tokn_X",
        card: OpenStruct.new({
          name: "J DOE",
          last_digits: "4242",
          expiration_month: 10,
          expiration_year: 2020,
          security_code_check: false,
        }),
      })
    else
      Omise::Token.retrieve(token)
    end
  end
end
