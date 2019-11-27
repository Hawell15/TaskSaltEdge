require 'json'

class Accounts
  attr_accessor :name, :currency, :balance

  def initialize(name, currency, balance)
    @name=name
    @currency=currency
    @balance=balance
  end

  def to_hash
    {
      :name=>@name, :currency=>@currency, :balance=>@balance
    }
  end

  def to_json
    to_hash.to_json
  end

end
