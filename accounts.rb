require 'json'

class Accounts
  attr_accessor :name, :currency, :balance,  :transactions

  def initialize(name, currency, balance)
    @name=name
    @currency=currency
    @balance=balance
    @transactions= []
  end

  def to_hash
    {
      :name=>@name, :currency=>@currency, :balance=>@balance
    }
  end

  def to_json
    to_hash.to_json
  end

  def print
    puts("Account: name:#{@name}, currency:#{@currency}, balance:#{@balance}")
    if @transactions.length() != 0
      @transactions.each do |transaction|
      transaction.print
      end
    end
  end
end
