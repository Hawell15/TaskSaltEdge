require 'json'

class Transactions
  attr_accessor :date, :description, :amount, :currency, :account_name

  def initialize(date,description,amount,currency,account_name)
    @date=date
    @description=description
    @amount=amount
    @currency=currency
    @account_name=account_name
  end

  def to_hash
      {
        :date=>@date, :description=>@description, :amount=>@amount, :currency=>@currency, :account_name=>@account_name
      }
  end

  def to_json
    to_hash.to_json
  end

public  def print
    puts("    Transaction: date:#{@date}, description:#{@description}, amount:#{@amount}, currency:#{@currency},account name:#{@account_name}")
end
end
