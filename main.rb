require 'watir'
require_relative 'accounts'
require_relative 'transactions'

class Bank
  attr_accessor :browser, :accounts_array

  def openAccountPage
    @browser=Watir::Browser.new
    @browser.goto("https://wb.micb.md/way4u-wb/");
    login="Hawell"
    password="Sport5Roma15Vera"
    username=@browser.text_field(:class=>"username")
    username.exists?
    username.set login
    username.value
    pass=@browser.text_field(id:"password")
    pass.exists?
    pass.set password
    pass.value
    @browser.button(:class=>"wb-button").click
  end


  public def accountInfoExtract
    @browser.div(:class=>"block__main-menu").wait_until(&:present?)
    @browser.span(:text=>"Carduri și conturi").click
    @browser.div(:class=>"contracts-section").wait_until(&:present?)
    @accounts_array=Array.new
    @transaction_array= Array.new
    @browser.divs(:class=>"main-info").map do |acc|
      name=acc.link(:class=>"name").title
      currency=acc.div(:class=>["icon", "icon-account "]).text
      amount = acc.span(:class=>"amount").text
      acc.link(:class=>"name").click
      @browser.link(:href=>"#contract-history").wait_until(&:present?).click
      sleep 3

      transactionsInfoByAccountExtract(name)

      @accounts_array.push(Accounts.new(name,currency,amount))
      @browser.span(:text=>"Carduri și conturi").click
      @browser.div(:class=>"contracts-section").wait_until(&:present?)
    end
  end

  def transactionsInfoByAccountExtract(acc)
      if @browser.link(:class=>"operation-details").exists?
        @browser.spans(:class=>"history-item-description").map do |trans|
          data,description,amount,currency=transactionsInfoExtract(trans)
          @transaction_array.push(Transactions.new(data,description,amount,currency,acc))
        end
      end
  end
  def transactionsInfoExtract(trans)
      trans.link(:class=>"operation-details").wait_until(&:present?).click
      @browser.div(:class=>"details-section").wait_until(&:present?)
      i=0
      @browser.divs(:class=>"details-section").map do |details|
        case i
        when 0
          @data=details.div(:class=>"value").text
        when 1
          @account_name=details.div(:class=>"value").text
        when 2
          @description=details.div(:class=>"value").text
        end
        i+=1
      end
      amount=@browser.div(:class=>["details-section","amounts"]).div(:class=>"value").span(:class=>"amount").text
      currency=@browser.div(:class=>["details-section","amounts"]).div(:class=>"value").span(:class=>["amount","currency"]).text
      @browser.send_keys :escape
    return @data,@description,amount,currency,@account_name
  end

  def printAccount
    @accounts_array.each do |account|
      account.print
    end
  end

  def printTransaction
  puts  @transaction_array.length
    @transaction_array.each do |transaction|
      transaction.print
    end
  end
end


bank=Bank.new
bank.openAccountPage
bank.accountInfoExtract
bank.printAccount
bank.printTransaction
