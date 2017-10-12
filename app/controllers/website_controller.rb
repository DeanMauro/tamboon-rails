class WebsiteController < ApplicationController
  def index
    @token = nil
  end

  def donate
    # Get charity or select a random one
    charity = (params[:charity]=="random") ? Charity.random : Charity.find_by(id: params[:charity])

    # Check for valid params
    if params.values_at(:omise_token, :amount).all?(&:present?) &&
       params[:amount].to_i > 20 && 
       charity

      if Rails.env.test?
        charge = OpenStruct.new({
          amount: params[:amount].to_i * 100,
          paid: (params[:amount].to_i != 999),
        })
      else
        charge = Omise::Charge.create({
          amount: params[:amount].to_i * 100,
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
